# Session 13 — Kubernetes Storage, HPA & Probes (Assignment Submission)

All work was done on a local **minikube** cluster (Kubernetes v1.37) with the **metrics-server** addon enabled.
Every screenshot here comes from real commands I ran. The plain-text output is also saved in [`transcripts/`](./transcripts/).

I did **not** change any existing files in this session. Everything new is inside this `task/` folder.

---

## Tasks

| # | Task | Where |
| :--- | :--- | :--- |
| 1 | Kubernetes Volumes — emptyDir, hostPath, PV, PVC, StorageClass, dynamic provisioning | [`01-kubernetes-volumes/README.md`](./01-kubernetes-volumes/README.md) |
| 2 | HPA hands-on — deploy, configure HPA, load generator, CPU usage, scaling up and down | [`02-hpa-hands-on/README.md`](./02-hpa-hands-on/README.md) |
| 3 | Mini project — app with PVC + HPA + startup/readiness/liveness probes | [`03-mini-project/README.md`](./03-mini-project/README.md) |

## Deliverables checklist

| Deliverable | File |
| :--- | :--- |
| Volume documentation | [`01-kubernetes-volumes/README.md`](./01-kubernetes-volumes/README.md) |
| HPA YAML | [`../04-hpa/hpa.yaml`](../04-hpa/hpa.yaml) (existing), [`../mini-project/hpa.yaml`](../mini-project/hpa.yaml) (existing) |
| Load generator | [`02-hpa-hands-on/load-generator.yaml`](./02-hpa-hands-on/load-generator.yaml) (new) + `kubectl run` commands in the READMEs |
| HPA output | [`02-hpa-hands-on/README.md`](./02-hpa-hands-on/README.md), [`transcripts/`](./transcripts/) |
| Screenshots | [`screenshots/`](./screenshots/) |
| Mini-project implementation | [`../mini-project/`](../mini-project/) (existing YAML), deployed and tested in [`03-mini-project/README.md`](./03-mini-project/README.md) |
| README documentation | this file + the 3 task READMEs |

## Folder layout

```text
task/
├── README.md                          # this file
├── 01-kubernetes-volumes/
│   ├── README.md                      # Task 1 notes + practical examples
│   └── manifests/static-pvc.yaml      # PVC with storageClassName: "" (binds to a hand-made PV)
├── 02-hpa-hands-on/
│   ├── README.md                      # Task 2 steps + output
│   └── load-generator.yaml            # busybox load generator Pod
├── 03-mini-project/
│   └── README.md                      # Task 3 results
├── screenshots/                       # PNG screenshots of each step
└── transcripts/                       # same output as plain text
```

## Results in short

- **emptyDir** data was lost when the Pod was recreated. **hostPath** and **PVC** data survived.
- A PVC with **no** `storageClassName` used minikube's **default** class and got a new dynamic PV instead of my hand-made PV. Fixed with `storageClassName: ""`.
- **HPA (04-hpa):** 1 → 2 → 3 Pods as load increased (68% and 62% CPU vs a 50% target). It went back down 3 → 1 after the 5-minute stabilization window.
- **Mini project:** 2 → 3 Pods under load (56% vs 50%). PVC data was shared by all Pods and survived Pod deletion. Startup, readiness and liveness probes all worked.

## Setup used

```bash
minikube start
minikube addons enable metrics-server
kubectl top nodes        # check that metrics work
```
