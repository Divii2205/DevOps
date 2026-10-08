# Session 21 – Final DevOps Project: TaskBoard (Submission)

**TaskBoard** is a small project-management web app (React + FastAPI + PostgreSQL).
This project takes it all the way from code to a monitored Kubernetes cluster that is managed with GitOps:

```text
Application → Git → GitHub → CI pipeline → Build & Test → Security scanning → Docker image
  → Container registry → Kubernetes → Helm → Monitoring → GitOps   (+ Terraform for the cloud infrastructure)
```

It is based on the session's TaskBoard reference project. This folder (`session21-python/`) now holds the **final, fixed project** in the layout the task asks for. The original reference files are kept in git history (commit `d07887f`), and the original session guide is kept as [`SESSION-README.md`](SESSION-README.md) next to [`GRADING.md`](GRADING.md). The [Troubleshooting](#15-troubleshooting) section lists **10 real problems** I found in the reference project, with the logs, root cause, fix and proof that each fix works.

> **Zero cost.** Nothing paid was created:
> - **Kubernetes:** a local **kind** cluster `session21` (Kubernetes v1.37.0) stands in for EKS.
> - **AWS:** Terraform ran against **Moto**, a free local AWS emulator (same as Session 19).
> - **Registry and GitHub:** images are tagged exactly as CI tags them for GHCR (`ghcr.io/divii2205/...:<commit-sha>`) and loaded into kind. A small local Git server plays GitHub for Argo CD.
> - **Scanners:** each one ran as a throwaway Docker container (gitleaks, bandit, Trivy, npm audit), so nothing was installed on the laptop.

## Table of contents

1. [Project overview](#1-project-overview)
2. [Architecture diagram](#2-architecture-diagram)
3. [Technologies used](#3-technologies-used)
4. [Folder structure](#4-folder-structure)
5. [Application setup](#5-application-setup)
6. [Testing](#6-testing)
7. [Docker setup](#7-docker-setup)
8. [Terraform infrastructure](#8-terraform-infrastructure)
9. [Kubernetes deployment](#9-kubernetes-deployment)
10. [Helm deployment](#10-helm-deployment)
11. [CI/CD pipeline](#11-cicd-pipeline)
12. [DevSecOps implementation](#12-devsecops-implementation)
13. [Monitoring](#13-monitoring)
14. [GitOps](#14-gitops)
15. [Troubleshooting](#15-troubleshooting)
16. [Lessons learned](#16-lessons-learned)
17. [Grading checklist](#17-grading-checklist)

Screenshots are inside each section, next to the step they prove.

---

## 1. Project overview

| | |
|---|---|
| **What the app does** | Teams create tasks, give them a priority (LOW/MEDIUM/HIGH) and an owner, and move them through TODO → IN_PROGRESS → DONE. The dashboard shows totals per status. |
| **Frontend** | React + Vite, served by an **unprivileged nginx**, which also proxies `/api/` to the backend. |
| **Backend** | FastAPI REST API with `/health`, `/ready` and `/metrics` (Prometheus) endpoints. |
| **Database** | PostgreSQL 16. The `tasks` table is created by an **Alembic** migration. |
| **Delivery** | GitHub Actions: tests → 4 security gates → Docker build → Trivy image gate → push to GHCR → GitOps commit → Argo CD deploys with Helm. |
| **Runs on** | Kubernetes (kind locally, EKS on AWS through Terraform), with Ingress, HPA, probes, ConfigMap, Secret and a PVC. |
| **Observed by** | Prometheus (ServiceMonitor) and a Grafana dashboard, plus logs with `kubectl logs`. |

REST API (10 routes, so more than the 4 the rubric asks for):

```text
GET /  GET /health  GET /ready  GET /metrics
GET /api/tasks   POST /api/tasks   GET /api/tasks/stats
GET /api/tasks/{id}   PUT /api/tasks/{id}   DELETE /api/tasks/{id}
```

## 2. Architecture diagram

```text
 Developer laptop
   │ git commit / git push
   ▼
 GitHub repo ───────────────► GitHub Actions  (.github/workflows/ci-cd.yml)
   ▲                           ├─ test:        pytest (8 tests) + npm build
   │                           ├─ secret-scan: gitleaks          ┐
   │                           ├─ sast:        bandit            ├─ security gates (fail = stop)
   │                           ├─ sca:         trivy fs + npm audit ┘
   │                           ├─ build-scan-push: docker build → trivy image (gate) → push GHCR :<sha>
   │  "gitops: deploy <sha>"   └─ gitops-deploy: write <sha> into gitops/values-gitops.yaml
   └───────────────────────────────────┘
                                        GHCR (container registry)
 Terraform (terraform/) ──► AWS: VPC (2 public + 2 private subnets, NAT) + EKS + node group
                                        │
            Argo CD (watches Git) ──────┤ helm template helm/taskboard + gitops/values-gitops.yaml
                                        ▼
 ┌──────────────────────────── Kubernetes namespace "taskboard" ─────────────────────────────┐
 │  Ingress (nginx) taskboard.local                                                          │
 │     ├── /     → Service taskboard-frontend:80 → Deployment frontend (2 pods, nginx :8080)  │
 │     └── /api  → Service backend:8000         → Deployment backend  (2-6 pods, HPA on CPU)  │
 │                                                  │ envFrom ConfigMap taskboard-config      │
 │                                                  │ DATABASE_URL from Secret                │
 │                                                  ▼                                         │
 │                                  Service taskboard-postgres → postgres (PVC 5Gi)           │
 └────────────────────────────────────────────────────────────────────────────────────────────┘
        │ /metrics (ServiceMonitor)
        ▼
 Prometheus ──► Grafana dashboard "TaskBoard API"       logs: kubectl logs
```

## 3. Technologies used

| Area | Tool (version used) |
|---|---|
| Application | React + Vite 8, FastAPI 0.142.4, SQLAlchemy 2.0, Alembic 1.14, PostgreSQL 16 |
| Testing | pytest 8.3 with FastAPI TestClient and a separate SQLite test DB |
| Version control | Git, GitHub |
| Containers | Docker 29.4, Docker Compose, multi-stage builds, non-root users |
| CI/CD | GitHub Actions, GitHub Container Registry (GHCR) |
| DevSecOps | gitleaks 8.24 (secrets), bandit 1.8 (SAST), Trivy 0.67 (SCA + image scan), npm audit |
| Infrastructure as Code | Terraform 1.16.4, AWS provider 5.100, modules `terraform-aws-modules/vpc` 5.8.1 + `eks` 20.37.1, Moto (local AWS) |
| Kubernetes | kind 0.33 (Kubernetes v1.37.0), ingress-nginx v1.12.1, metrics-server |
| Packaging | Helm v4.3.0 |
| Monitoring | kube-prometheus-stack chart 92.1.0 (Prometheus v3.15.0, Grafana 13.2.3) |
| GitOps | Argo CD v3.5.4 |

## 4. Folder structure

```text
session21-python/
├── application/
│   ├── backend/            FastAPI app, Alembic migration, pytest tests, Dockerfile
│   └── frontend/           React app, nginx.conf, multi-stage Dockerfile
├── docker/                 docker-compose.yml (frontend + backend + postgres)
├── kubernetes/             namespace.yaml, kind-config.yaml, troubleshooting/ (broken manifests)
├── helm/taskboard/         Helm chart: Deployments, Services, ConfigMap, Secret, PVC, Ingress, HPA, ServiceMonitor
├── terraform/              VPC + EKS (main.tf, variables.tf, outputs.tf, versions.tf, terraform.tfvars.example, moto_override.tf)
├── .github/workflows/      ci-cd.yml (CI/CD + DevSecOps + GitOps)
├── security/reports/       real scan outputs (gitleaks, bandit, trivy fs/image, npm audit; before + after)
├── monitoring/             prometheus-values.yaml, grafana-dashboard.yaml, load-test.sh
├── gitops/                 argocd-application.yaml, values-gitops.yaml (desired image tags)
├── screenshots/            all screenshots used below
├── .gitignore              .env, __pycache__, node_modules, .venv, tfstate, ...
├── GRADING.md              session grading rubric
├── SESSION-README.md       original session guide
└── README.md               this submission
```

What changed compared with the original reference project (commit `d07887f`), and why:

| File | Change | Why |
|---|---|---|
| `application/backend/tests/test_api.py` | creates the tables + **5 new tests** (8 in total) | the original tests failed, and the rubric needs ≥ 5 tests (issue 1) |
| `application/backend/requirements.txt` | FastAPI 0.115.6 → 0.142.4, Starlette 1.7.0, instrumentator 8.1.0 | 3 HIGH CVEs in Starlette failed the Trivy gate (issue 3) |
| `application/frontend/Dockerfile`, `nginx.conf` | `nginx-unprivileged:1.29-alpine` + `apk upgrade`, listen on 8080 | runs as non-root, and 42 HIGH/CRITICAL CVEs are fixed (issue 3) |
| `application/frontend/src/main.jsx` | user name "Divii" | my own submission |
| `docker/docker-compose.yml` | paths, Postgres healthcheck, `service_healthy`, `restart: on-failure` | the backend exited at startup (issue 2) |
| `terraform/*.tf` | rewritten as valid multi-line HCL, + `terraform.tfvars.example`, `moto_override.tf` | `terraform init` failed (issue 4) |
| `helm/taskboard/templates/*` | Service `backend`, fixed Ingress, ConfigMap, DB URL in the Secret, `startupProbe`, port 8080 | issues 6, 7 and 10, plus the ConfigMap and Secret requirements |
| `monitoring/load-test.sh` | URL `/api/health` → `/api/tasks` | `/api/health` does not exist |
| new | `.github` (4 security jobs + GitOps job), `gitops/`, `monitoring/grafana-dashboard.yaml`, `kubernetes/kind-config.yaml`, `.gitignore` | requirements of the task |

---

## 5. Application setup

Run the whole stack with one command (details in [Docker setup](#7-docker-setup)):

```bash
cd docker
docker compose -p session21 up --build -d
# UI  http://localhost:3000    API docs  http://localhost:8000/docs
```

**The TaskBoard UI.** KPI cards, task table, filters and badges. The data comes from PostgreSQL through `/api`:

![TaskBoard UI](screenshots/01-taskboard-ui.png)

**Swagger docs** at `/docs`, listing all 10 routes:

![Swagger](screenshots/01-swagger-docs.png)

**CRUD with the REST API.** Create 4 tasks, update one (PUT), delete one (DELETE → 204, then GET → 404), read the stats, and call the same API through the frontend's nginx proxy:

![API CRUD](screenshots/01-api-crud.png)

**Database.** The `tasks` table was created by Alembic migration `0001` (`alembic_version` = `0001`). The backend runs `alembic upgrade head` before it starts Uvicorn:

![Postgres + Alembic](screenshots/01-postgres-alembic.png)

To run the backend without Docker (from the session README):

```bash
cd application/backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL='postgresql+psycopg://taskboard:taskboard@localhost:5432/taskboard'
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

## 6. Testing

```bash
cd application/backend
pytest -v
```

There are 8 tests covering `/health`, `/`, `POST`, `GET` list, `GET /{id}`, `PUT`, `DELETE`, `/stats` and validation (an empty title gives 422).
The tests use a **separate SQLite test database** (`sqlite:///./test.db`), never the real PostgreSQL. `pytest.ini` sets `pythonpath = .`.

![pytest](screenshots/02-pytest-passing.png)

Tests are the **first gate** in CI. If one test fails, the pipeline stops and no image is built or pushed.

## 7. Docker setup

| Image | Dockerfile | Notes |
|---|---|---|
| backend | `application/backend/Dockerfile` | `python:3.12-slim`, runs as **user 10001 (appuser)**, runs `alembic upgrade head` and then `uvicorn` |
| frontend | `application/frontend/Dockerfile` | **multi-stage**: `node:22-alpine` runs `npm run build`, and only `dist/` is copied into `nginx-unprivileged` (runs as **user 101**, port 8080). No Node.js in the final image (74 MB). |

```bash
docker build -t taskboard-backend:local  application/backend
docker build -t taskboard-frontend:local application/frontend
cd docker && docker compose -p session21 up --build -d     # postgres → (healthy) → backend → frontend
```

`docker compose up --build` starts all 3 services. Postgres turns `healthy` first, and only then does the backend start. Both app containers run as non-root (`id` output):

![docker compose](screenshots/04-docker-compose.png)

---

## 8. Terraform infrastructure

`terraform/` describes the AWS infrastructure for production (region `ap-south-1`):

```text
module "vpc"  (terraform-aws-modules/vpc 5.8.1)
  VPC 10.20.0.0/16 · public 10.20.101.0/24 + 10.20.102.0/24 · private 10.20.1.0/24 + 10.20.2.0/24
  Internet gateway · 1 NAT gateway
module "eks"  (terraform-aws-modules/eks 20.37.1)
  EKS 1.31 in the private subnets · managed node group "main": t3.medium, min 2 / desired 2 / max 4
outputs: vpc_id, public_subnets, cluster_name, cluster_endpoint, configure_kubectl
```

`terraform.tfvars.example` shows the variables. No AWS keys are ever stored in files (gitleaks found 0 leaks).

```bash
cd terraform
terraform init && terraform fmt -check && terraform validate
terraform plan
terraform apply
aws eks update-kubeconfig --region ap-south-1 --name taskboard-eks
terraform destroy
```

> **Where it ran:** Moto, a free local AWS emulator (`moto_server -p 5055`, with `MOTO_IAM_LOAD_MANAGED_POLICIES=true` so the AWS-managed EKS policies exist). The only extra file is `moto_override.tf`, which points the provider at `http://127.0.0.1:5055`. **Delete that file and the same code runs on real AWS.** A real EKS cluster + NAT gateway costs money, which is why Moto was used.

**init / fmt / validate:**

![terraform init validate](screenshots/07-terraform-init-validate.png)

**plan: 56 resources to add**, including the VPC, 2 public + 2 private subnets, NAT, EKS cluster and node group:

![terraform plan](screenshots/07-terraform-plan.png)

**apply on Moto** created 51 resources. The "console" view (boto3 calls against Moto) shows the VPC, the 4 subnets, the NAT gateway, EKS `taskboard-eks` **ACTIVE** and node group `main` **ACTIVE** (t3.medium, 2/2/4).
5 resources fail **only because Moto does not emulate them**: EC2 tags on the EKS-managed security group, EKS access entries, and a module check that needs the cluster's service CIDR. On real AWS these exist.

![terraform apply on Moto](screenshots/07-terraform-apply-moto.png)

**destroy** removed all 51 resources, so nothing is left running:

![terraform destroy](screenshots/07-terraform-destroy.png)

---

## 9. Kubernetes deployment

Local cluster (free stand-in for EKS). Ports 80/443 of the kind node go to ingress-nginx:

```bash
kind create cluster --config kubernetes/kind-config.yaml                 # cluster "session21"
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl apply -f kubernetes/namespace.yaml
# images (CI pushes them to GHCR; locally they are loaded into kind)
kind load docker-image --name session21 ghcr.io/divii2205/taskboard-backend:<sha> ghcr.io/divii2205/taskboard-frontend:<sha>
```

Every object the task asks for is in the Helm chart:

| Object | Where | What it does |
|---|---|---|
| **Deployment** | `backend-deployment.yaml`, `frontend-deployment.yaml`, `postgres.yaml` | 2 backend + 2 frontend pods + 1 postgres pod, with self-healing |
| **Service** (ClusterIP) | `backend` :8000, `taskboard-frontend` :80, `taskboard-postgres` :5432 | stable names; nginx proxies `/api/` to `http://backend:8000` |
| **ConfigMap** | `configmap.yaml` → `taskboard-config` (`APP_NAME`, `ENVIRONMENT`) | non-secret settings, loaded with `envFrom` |
| **Secret** | `postgres.yaml` → `taskboard-postgres` (`username`, `password`, `database-url`) | the DB password is used by postgres **and** by the backend (`secretKeyRef`), never written in plain text in the Deployment |
| **Ingress** | `ingress.yaml` | host `taskboard.local`: `/api` → `backend:8000`, `/` → `taskboard-frontend:80` |
| **HPA** | `hpa.yaml` | backend 2 → 6 pods at 60 % CPU (needs the resource requests + metrics-server) |
| **Probes** | backend: `startupProbe` + `readinessProbe /ready` (checks the DB) + `livenessProbe /health`; frontend: HTTP `/`; postgres: `pg_isready` | traffic only goes to pods that are ready, and hung pods are restarted |
| **Storage** | `PersistentVolumeClaim taskboard-postgres-data` 5Gi (RWO, `standard` StorageClass) | database data survives pod restarts |

**Pods: all Running.** Backend 2/2 and frontend 2/2 (2 replicas each), plus postgres:

![kubectl get pods](screenshots/08-kubectl-get-pods.png)

**ClusterIP Services** with their endpoints (pod IPs):

![kubectl get svc](screenshots/08-kubectl-get-svc.png)

**ConfigMap, Secret, PVC (Bound 5Gi), Ingress and HPA:**

![objects](screenshots/08-configmap-secret-pvc-ingress-hpa.png)

**Probes, resources, ConfigMap and Secret** as seen inside the backend Pod:

![probes](screenshots/08-probes-config.png)

**Ingress routing:** `/` → frontend, `/api` → backend, each with real pod endpoints:

![ingress routing](screenshots/08-ingress-routing.png)

**The app through the Ingress host** `http://taskboard.local` (in `hosts`: `127.0.0.1 taskboard.local`). The tasks were created through `/api` on the Ingress:

![TaskBoard through ingress](screenshots/08-taskboard-via-ingress.png)

**HPA in action.** A load generator (4 busybox pods looping over `GET /api/tasks`) pushed backend CPU to 205 % of the request. The HPA scaled **2 → 3 → 6** pods (its max), and `kubectl top` shows the load spread over 6 pods:

```bash
kubectl create deployment load-generator --image=busybox:1.37 --replicas=4 -n taskboard -- \
  sh -c 'while true; do wget -q -O- http://backend:8000/api/tasks >/dev/null; done'
kubectl get hpa taskboard-backend -n taskboard --watch
```

![HPA scaling](screenshots/08-hpa-scaling.png)

## 10. Helm deployment

The chart `helm/taskboard` (`Chart.yaml`, `values.yaml`, `values-dev.yaml`, `values-prod.yaml`, `templates/`) packages everything above. `helm lint` passes.

```bash
helm lint helm/taskboard
helm upgrade --install taskboard ./helm/taskboard -n taskboard \
  -f gitops/values-gitops.yaml --set backend.tag=<sha> --set frontend.tag=<sha>
helm list -n taskboard
helm history taskboard -n taskboard
helm rollback taskboard 1 -n taskboard     # if a release is bad
```

![helm list](screenshots/08-helm-list.png)

> After this first manual Helm install, the release was uninstalled and **Argo CD took over** ([GitOps](#14-gitops)). Argo CD renders the same chart with `helm template`, so from then on nobody runs `helm` or `kubectl apply` by hand.

---

## 11. CI/CD pipeline

`.github/workflows/ci-cd.yml` runs on every **push to `main`** (and on pull requests):

```text
 test ──────────────┐
 secret-scan ───────┤
 sast ──────────────┼──► build-scan-push ──► gitops-deploy ──► (Argo CD) ──► Kubernetes
 sca ───────────────┘     docker build x2       sed tag=<sha>
                          trivy image x2 (gate) git commit + push
                          push GHCR :<sha>
```

| Job | Steps | Stops the pipeline when |
|---|---|---|
| `test` | setup Python 3.12 → `pip install` → **`pytest -v`** → setup Node 22 → **`npm run build`** | a test fails or the frontend does not build |
| `secret-scan`, `sast`, `sca` | see [DevSecOps](#12-devsecops-implementation) | a finding is found |
| `build-scan-push` | `docker build` backend + frontend, tagged with **`${{ github.sha }}`** (never `latest`) → **Trivy** on both images → `docker login ghcr.io` with `GITHUB_TOKEN` → `docker push` | an image has a fixable HIGH/CRITICAL CVE |
| `gitops-deploy` | writes the new SHA into `gitops/values-gitops.yaml`, then commits and pushes | – |

The commit SHA in the tag gives **traceability**: commit `27fcca4` → image `taskboard-backend:27fcca4` → the pods running in the cluster.
`paths-ignore: gitops/**` stops the bot's GitOps commit from starting the pipeline again.

Every pipeline step was run locally on the same code (screenshots in sections 6, 7 and 12). The GitHub-hosted run is [step 1 of "what is left"](#what-is-left-for-me-to-do).

## 12. DevSecOps implementation

| Layer | Tool | Command (same as in CI) | Result |
|---|---|---|---|
| **Secret scanning** | gitleaks | `gitleaks dir . -v` (CI: `gitleaks-action` over the full git history) | **no leaks found** |
| **SAST** | bandit | `bandit -r application/backend/app -ll` (fails on MEDIUM+) | **No issues identified** (121 lines) |
| **SCA** | Trivy fs + npm audit | `trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 application/` and `npm audit --audit-level=high` | **0** vulnerable Python packages, **0** npm vulnerabilities |
| **Container image scanning** | Trivy image | `trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 <image>` | **0** on both images (after the fix) |
| **Security gates** | `exit-code: 1` / `-ll` / `--audit-level=high` | each security job must pass before `build-scan-push` runs (`needs:`) | the gate **really blocked** the original images, see issue 3 |

![gitleaks](screenshots/06-secret-scan-gitleaks.png)

![bandit](screenshots/06-sast-bandit.png)

![trivy fs](screenshots/06-sca-trivy-fs.png)

![trivy image clean](screenshots/06-trivy-image-clean.png)

**What Trivy scanned and what the result means.** Trivy reads the OS packages (Debian for the backend, Alpine for the frontend) and the Python packages inside each image, and checks them against CVE databases. The first scan **failed the gate**. The backend had **CVE-2025-62727** (HIGH): Starlette 0.41.3 can be pushed into a denial of service with crafted HTTP `Range` headers, and the fix is Starlette ≥ 0.49.1. The frontend had 42 fixable OpenSSL/c-ares CVEs. After upgrading FastAPI/Starlette and the nginx base image, both scans are clean, which means there is **no known HIGH/CRITICAL CVE with a fix available**. It does not mean the images are perfectly safe.

All raw scan outputs, including the "before" reports, are in [`security/reports/`](security/reports/).

---

## 13. Monitoring

Install (uses `monitoring/prometheus-values.yaml`, which makes Prometheus pick up ServiceMonitors from all namespaces):

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace -f monitoring/prometheus-values.yaml
kubectl apply -f monitoring/grafana-dashboard.yaml        # dashboard as code (Grafana sidecar loads it)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3001:80
```

**Metrics: the `/metrics` endpoint** (Prometheus text format, from `prometheus-fastapi-instrumentator`):

![metrics endpoint](screenshots/09-metrics-endpoint.png)

**Prometheus scrapes the backend.** The chart's ServiceMonitor finds Service `backend` (port `http`, path `/metrics`, every 15 s). All **6/6 targets are UP** (the HPA had scaled to 6), and PromQL shows about **149 req/s** on `/api/tasks` during the load test:

![prometheus targets UI](screenshots/09-prometheus-targets.png)

![prometheus scrape + query](screenshots/09-prometheus-scrape-and-query.png)

**Grafana dashboard "TaskBoard API"** (`monitoring/grafana-dashboard.yaml`) with live data: requests per second by handler, p95 latency, 5xx error rate (0), backend pods UP (6) and CPU per pod. The two load-test bursts and the scale-out are easy to see:

![grafana dashboard](screenshots/09-grafana-dashboard.png)

**Logs:** `kubectl logs` shows the backend's Uvicorn access log (probes and API calls):

![logs](screenshots/09-backend-logs.png)

## 14. GitOps

**Git is the source of truth.** CI only writes the desired image tag into `gitops/values-gitops.yaml`. **Argo CD** watches the repo and makes the cluster match: Helm chart `helm/taskboard` + `values-gitops.yaml`, `automated` sync, `prune` and `selfHeal` (`gitops/argocd-application.yaml`).

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f gitops/argocd-application.yaml
kubectl get applications -n argocd
```

> **Local Git server.** So that nothing is pushed to my online account without asking, a small Git server container (`gitops-server`, Python + `git http-backend`, the same idea as Session 20) runs on the kind Docker network and plays GitHub. For the demo, `repoURL` was swapped to `http://gitops-server/final-devops-project.git` when applying. To use GitHub, push this folder as its own repo and keep the GitHub URL.

**Step 1: CI writes the new tag into Git** (the `gitops-deploy` job). App commit `27fcca4` → `gitops: deploy 27fcca4`:

![gitops commit](screenshots/10-gitops-ci-commit.png)

**Step 2: Argo CD syncs from Git.** The Application is **Synced + Healthy** at the latest Git revision `f19b611`, the images are `:27fcca4` (written into Git by CI), and `helm list` is empty because no manual release exists any more:

![argocd synced](screenshots/10-argocd-synced.png)

**Step 3: a change goes live just by `git push`** (this is also the live demo for M10). The fix for issue 10 (startupProbe) was **committed and pushed only**:

```text
[+160s] git-rev=f19b611  app=OutOfSync/Degraded   ← Argo CD found the new commit
[+211s] git-rev=f19b611  app=Synced/Degraded      ← synced: new backend ReplicaSet with startupProbe
[+275s] git-rev=f19b611  backend-ready=2/2
[+290s] git-rev=f19b611  app=Synced/Healthy       ← new pods, 0 restarts
```

![gitops fix rollout](screenshots/10-gitops-fix-rollout.png)

> To be honest about the timing: right before this push the kind node had to be restarted (issue 10 and lesson 9), and `argocd-repo-server` was still recovering. So I ran one `kubectl annotate application taskboard -n argocd argocd.argoproj.io/refresh=hard` to make Argo CD re-read Git at once. The sync itself (`initiatedBy: automated`) was done by Argo CD. The frontend restart counts in these screenshots also come from that node restart.

---

## 15. Troubleshooting

I deployed the **original reference project, unchanged** (commit `d07887f`: chart, manifests, compose file, Terraform, tests) and fixed everything that broke. For each issue I followed the same steps: **identify → investigate logs/resources → root cause → fix → verify**.
The Kubernetes ones ran in a separate namespace `taskboard-lab` (original chart, with only the image names set through `--set`), together with the session's two broken manifests.

| # | Where | Symptom | Root cause | Fix | Verified |
|---|---|---|---|---|---|
| 1 | CI tests | `pytest`: **1 failed** – `no such table: tasks` | `TestClient(app)` without `with` never runs the startup event, so no tables are created | create the tables in the test module, add 5 tests | 8 passed |
| 2 | Docker Compose | backend container **exits** right after `up` | `depends_on` only waits for the container to **start**, not for Postgres to be **ready**. psycopg gets `Connection refused` | Postgres `healthcheck` + `condition: service_healthy` + `restart: on-failure` | all 3 up, postgres `(healthy)` |
| 3 | Security gate | **Trivy failed** the pipeline: backend 3 HIGH, frontend 42 (40 HIGH + 2 CRITICAL) | old Starlette 0.41.3 (pulled in by FastAPI 0.115.6), old Alpine 3.21.3 in `nginx:1.27-alpine` | FastAPI 0.142.4 / Starlette 1.7.0, `nginx-unprivileged:1.29-alpine` + `apk upgrade` | both scans 0, tests still pass |
| 4 | Terraform | `terraform init`: **Invalid single-argument block definition** | `main.tf`/`versions.tf` put many arguments on one line `{ a = 1 b = 2 }`, and HCL allows only one per line | rewrite as normal multi-line HCL | init + fmt + validate + plan OK |
| 5 | Kubernetes | pod **ImagePullBackOff** (`broken-image.yaml`) | image `ghcr.io/example/taskboard-backend:does-not-exist` does not exist (403 from ghcr.io) | `kubectl set image` to an existing tag (+ DB URL) | pod Running 1/1 |
| 6 | Kubernetes | frontend **CrashLoopBackOff** | nginx: `host not found in upstream "backend"`. nginx needs a Service named `backend`, but the chart named it `<release>-taskboard-backend` | chart: Service name `backend` | frontend 2/2 Running |
| 7 | Kubernetes | Ingress **503** on `/api` | Ingress points to `taskboard-backend:8080`, but the Service is `lab-taskboard-backend:8000` (ingress-nginx log: `Error obtaining Endpoints for Service "taskboard-lab/taskboard-backend"`) | Ingress → `backend:8000` | `/api/tasks/stats` 200 through Ingress |
| 8 | Kubernetes | `broken-service` has **no endpoints** (`<none>`) | selector `app: label-that-does-not-exist` matches no pod, and targetPort 8080 is not the app port | selector `app: taskboard-backend`, targetPort 8000 | 2 endpoints, `/health` → `{"status":"UP"}` |
| 9 | Kubernetes | backend CrashLoopBackOff for the first ~3 min of the lab | same race as #2 in Kubernetes: the backend started before postgres was ready | Kubernetes restarts it until postgres is up; the `/ready` probe keeps traffic away until then | pods Running after Postgres was ready |
| 10 | Kubernetes | backend killed again and again: **`Container backend failed liveness probe, will be restarted`**, exit 137 | on a busy node, migrations + Uvicorn took longer than `initialDelaySeconds: 20` + 3 × 15 s, so liveness killed the pod **while it was still starting** (this also caused the 1 restart on each new HPA pod) | add a **`startupProbe`** (up to 150 s; liveness only starts after it succeeds), and set `timeoutSeconds: 3` | pushed through GitOps, then 0 new restarts |

Commands used for the investigation:

```bash
kubectl get pods -n taskboard-lab                      # what is failing
kubectl describe pod <pod> -n taskboard-lab             # events: pull errors, probe failures, kills
kubectl logs <pod> -n taskboard-lab --previous          # logs of the crashed container
kubectl get events -n taskboard-lab --sort-by=.lastTimestamp
kubectl get svc,endpoints -n taskboard-lab ; kubectl get pods --show-labels
kubectl describe ingress taskboard -n taskboard-lab ; kubectl logs -n ingress-nginx deploy/ingress-nginx-controller
```

### Issue 1 – pytest fails in CI

![pytest failed](screenshots/12-pytest-failed-before.png)

Fixed (see [Testing](#6-testing)): 8 passed.

### Issue 2 – backend container exits under Docker Compose

![compose before](screenshots/12-compose-backend-exited-before.png)

Fixed (see [Docker setup](#7-docker-setup)): Postgres turns `healthy` first, then the backend starts.

### Issue 3 – the security gate blocks the images

![trivy before](screenshots/12-trivy-gate-failed-before.png)

Fixed (see [DevSecOps](#12-devsecops-implementation)): 0 HIGH/CRITICAL.

### Issue 4 – terraform init fails

![terraform before](screenshots/12-terraform-init-failed-before.png)

Fixed (see [Terraform](#8-terraform-infrastructure)): `Success! The configuration is valid.`

### Issues 5–9 – Kubernetes lab (original chart + broken manifests)

Overview: ImagePullBackOff, two CrashLoopBackOffs, and Postgres the only pod Running:

![lab pods](screenshots/12-k8s-pods-broken.png)

**5 – ImagePullBackOff.** `describe` shows `Failed to pull image ... does-not-exist ... 403 Forbidden`:

![imagepullbackoff](screenshots/12-k8s-imagepullbackoff.png)

Fix + verify: set the image to a tag that exists, then the pod is Running:

![fix image](screenshots/12-k8s-fix-image.png)

**6 – frontend CrashLoopBackOff.** `logs --previous` shows `host not found in upstream "backend"`, and `get svc` shows there is no Service called `backend`:

![frontend crashloop](screenshots/12-k8s-frontend-crashloop.png)

**7 – Ingress points to a Service and port that do not exist.** `/api` → `taskboard-backend:8080` gives HTTP 503, and the ingress-nginx log shows the missing Service:

![ingress wrong backend](screenshots/12-k8s-ingress-wrong-backend.png)

Issues 6 and 7 are fixed in the chart (Service `backend`, Ingress → `backend:8000`). The proof is in [section 9](#9-kubernetes-deployment): frontend pods Running, and the Ingress has real endpoints for both paths.

**8 – Service without endpoints.** The selector `{"app":"label-that-does-not-exist"}` matches none of the pod labels:

![no endpoints](screenshots/12-k8s-service-no-endpoints.png)

Fix + verify: correct the selector and targetPort, after which there are 2 endpoints and the request answers `{"status":"UP"}`:

![fix service](screenshots/12-k8s-fix-service.png)

### Issue 10 – liveness probe kills a slow-starting backend

This showed up after the HPA load test. With Prometheus, Argo CD, ingress-nginx and 6 backend pods on one kind node, the node ran out of CPU, the API server stopped answering (`Unable to connect to the server: EOF`), and I restarted the node container (`docker start session21-control-plane`). After that, every backend start was slow, and the old liveness settings killed each pod before it was ready, which made the CPU load even worse:

![liveness restart loop](screenshots/12-k8s-liveness-restart-loop.png)

Fixed with a `startupProbe`, delivered by `git push` and Argo CD (see [GitOps step 3](#14-gitops)). The new pods became Ready with **0 restarts**.

---

## 16. Lessons learned

1. **"It works on my machine" is not enough.** The reference project looked complete, but its tests, Compose file, Terraform, Ingress and Services all failed the first time they really ran. Running every step is the only proof.
2. **Order matters at startup.** `depends_on`, `initialDelaySeconds` and "the DB is up" are not the same thing. Health checks, readiness probes and startup probes describe *ready*, not just *started*.
3. **Liveness probes can cause outages.** A liveness probe without a startup probe killed healthy pods that were just slow. Liveness should mean "this pod is stuck", not "this pod is still starting".
4. **Labels are the glue of Kubernetes.** Service → Pods (selectors), Ingress → Service (names and ports), ServiceMonitor → Service (labels and port name). One wrong name means no traffic, with no error until you look at endpoints.
5. **Security gates must really block.** Trivy found 45 fixable HIGH/CRITICAL CVEs. Because `exit-code: 1` was set, the images were never pushed. A scan that only warns is easy to ignore.
6. **Tag images with the commit SHA, never `latest`.** Each pod can be traced back to one commit, and a rollback is just one Git revert.
7. **GitOps removes manual deploys.** After Argo CD took over, the probe fix went live with only `git push`. Git history is the deployment history.
8. **IaC can be tested for free.** Moto showed that the Terraform code plans, applies and destroys cleanly before spending money on EKS. It also showed where an emulator differs from real AWS.
9. **Small clusters run out of resources.** Prometheus, Argo CD, ingress, HPA load and the app all on one kind node pushed it to 100 % CPU. The API server stopped answering and the node had to be restarted. Requests, limits and capacity planning matter even in a lab.

## 17. Grading checklist

| Module | Evidence in this README |
|---|---|
| M1 Application (10) | [section 5](#5-application-setup): UI, Swagger, 10 REST routes (GET/POST/PUT/DELETE), Alembic migration `0001`, `docker-compose.yml` |
| M2 Testing (10) | [section 6](#6-testing): 8 tests, SQLite test DB, `pytest.ini`, all passing |
| M3 Git/GitHub (5) | `.gitignore` (`.env`, `__pycache__`, `node_modules`, `.venv`), commit history, see "what is left" |
| M4 Docker (10) | [section 7](#7-docker-setup): backend builds, multi-stage frontend, non-root (uid 10001 / 101), compose starts 3 services |
| M5 CI/CD (15) | [section 11](#11-cicd-pipeline): push to `main`, pytest gate, frontend build, 2 images, GHCR push, SHA tags |
| M6 DevSecOps (5) | [section 12](#12-devsecops-implementation): Trivy on both images with `exit-code 1`, CVE explained, + secrets/SAST/SCA |
| M7 Terraform (15) | [section 8](#8-terraform-infrastructure): valid HCL, init, plan (56), VPC + 2 public subnets, EKS + node group, destroy, `tfvars.example` |
| M8 Kubernetes + Helm (15) | [sections 9–10](#9-kubernetes-deployment): namespace, chart, `helm upgrade --install`, 2 replicas each, ClusterIP Services, Ingress `/` + `/api`, all Running |
| M9 Observability (10) | [section 13](#13-monitoring): `/metrics`, Prometheus targets UP, Grafana with live panels |
| M10 Documentation (5) | this README + the GitOps live change in [section 14](#14-gitops) |

### What is left for me to do

These steps need my GitHub account, so they were not done automatically:

1. GitHub only runs workflows from `.github/workflows/` at a **repo root**, so the pipeline does not run inside the `DevOps` repo's `session21-python/` folder. Create a public GitHub repo `final-devops-project`, copy the contents of `session21-python/` into it, and push to `main`. Then the real Actions run turns green and the images appear in GHCR with SHA tags. Add the run URL and a GHCR screenshot to the submission.
2. Make at least 10 meaningful commits there (the rubric asks for a commit-history screenshot).
3. Point `gitops/argocd-application.yaml` at that repo (it already uses `https://github.com/Divii2205/final-devops-project.git`).

Clean-up of the local demo:

```bash
kind delete cluster --name session21
docker rm -f gitops-server
docker compose -p session21 -f docker/docker-compose.yml down -v
```
