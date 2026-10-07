# Session 14 — Kubernetes Troubleshooting (Assignment Submission)

**Cluster:** minikube (Kubernetes v1.37, 1 node) with metrics-server.
**Namespace:** I did all the work in a separate namespace, `s14-lab`, so old demos in `default` don't get mixed in:

```bash
kubectl create namespace s14-lab
kubectl config set-context --current --namespace=s14-lab
```

All commands are run from the `session-14-kubernetes-troubleshooting` folder.
I used **only the YAML files that already exist in this session** and did not edit any of them. Wherever a fix was needed, I either:
- fixed the live object (`kubectl patch`, `kubectl set image`), or
- changed the YAML **on the fly** in a pipe (`sed ... file.yaml | kubectl apply -f -`), so the file on disk stays the same.

Every screenshot comes from real commands I ran.

---

## My troubleshooting method

I followed the same steps for every problem:

```text
GET  ->  DESCRIBE  ->  EVENTS  ->  LOGS  ->  EXEC / TEST  ->  ROOT CAUSE  ->  FIX  ->  VERIFY
```

| Step | Command | Question it answers |
| :--- | :--- | :--- |
| 1 | `kubectl get pods` | What is the status? |
| 2 | `kubectl describe pod <name>` | What details and events explain it? |
| 3 | `kubectl events --for pod/<name>` | What did Kubernetes try to do? |
| 4 | `kubectl logs <name>` (`--previous`) | What is the app saying? |
| 5 | `kubectl exec <name> -- <cmd>` | What does it look like from inside? |

---

# Task 1 — Kubernetes troubleshooting commands

I used the demo Pods in `01-kubectl-get` to `05-events`:

```bash
kubectl apply -f 01-kubectl-get/pod.yaml
kubectl apply -f 02-kubectl-describe/demo-pod.yaml
kubectl apply -f 03-kubectl-logs/pod.yaml
kubectl apply -f 04-kubectl-exec/pod.yaml
kubectl apply -f 05-events/pod.yaml
```

### `kubectl get` and `kubectl get -o wide`

Gives a quick overview: name, ready, status, restarts, age. `-o wide` adds the **Pod IP and node**, `--show-labels` shows labels, and `-o jsonpath` pulls out exactly one field.

```bash
kubectl get pods
kubectl get pods -o wide
kubectl get pods --show-labels
kubectl get pod get-demo -o jsonpath='{.status.phase} {.status.podIP} {.spec.nodeName}'
kubectl get all
kubectl get nodes -o wide
```

![kubectl get](./screenshots/t1-01-kubectl-get.png)

### `kubectl describe`

Shows the full details of one object. The most useful parts are **State / Last State / Exit Code / Restart Count** and the **Events** at the bottom.

```bash
kubectl describe pod describe-demo
```

![kubectl describe](./screenshots/t1-02-kubectl-describe.png)

### `kubectl logs`

Shows what the app printed (stdout/stderr).

```bash
kubectl logs logs-demo --tail=8          # last 8 lines
kubectl logs logs-demo --timestamps      # with time
kubectl logs logs-demo --since=10s       # only recent lines
kubectl logs <pod> --previous            # logs of the container BEFORE it crashed
```

![kubectl logs](./screenshots/t1-03-kubectl-logs.png)

### `kubectl exec`

Runs a command **inside** a running container. Good for checking files, env vars, DNS config, and testing the app from inside.

```bash
kubectl exec exec-demo -- hostname
kubectl exec exec-demo -- curl -s -o /dev/null -w '%{http_code}' localhost
kubectl exec exec-demo -- env
kubectl exec exec-demo -- cat /etc/resolv.conf
kubectl exec -it exec-demo -- bash        # interactive shell
```

![kubectl exec](./screenshots/t1-04-kubectl-exec.png)

### `kubectl events`

Shows what Kubernetes did: scheduled, pulled image, started, back-off, failed mount, and so on.

```bash
kubectl events --for pod/events-demo
kubectl get events --sort-by=.lastTimestamp
kubectl get events --field-selector type=Warning     # only problems
```

![kubectl events](./screenshots/t1-05-kubectl-events.png)

### `kubectl explain`

Built-in documentation for any YAML field. Handy when you don't remember what a field does.

```bash
kubectl explain pod.spec.containers.imagePullPolicy
kubectl explain pod.spec.restartPolicy
kubectl explain service.spec.selector
```

![kubectl explain](./screenshots/t1-06-kubectl-explain.png)

### `kubectl top`

Live CPU and memory use (needs metrics-server).

```bash
kubectl top nodes
kubectl top pods
kubectl top pods --sort-by=memory
kubectl top pods -n kube-system --containers
```

![kubectl top](./screenshots/t1-07-kubectl-top.png)

---

# Task 2 — Troubleshooting common issues

| # | Issue | Files used |
| :--- | :--- | :--- |
| 1 | CrashLoopBackOff | `06-crashloopbackoff/` |
| 2 | ErrImagePull / ImagePullBackOff | `07-imagepullbackoff/`, `scenarios/scenario-2-imagepull/`, plus a **real bug** in `09-.../dns-test-pod.yaml` |
| 3 | Pending | `08-pending-pods/`, `scenarios/scenario-3-pending/` |
| 4 | ContainerCreating | made with `kubectl run` (no file for it in the session) |
| 5 | Service connectivity | `09-service-dns-troubleshooting/` (**real bug** in `service.yaml`) |
| 6 | DNS | `scenarios/scenario-4-dns-failure/` + dns-test Pod |
| 7 | Pod networking | `09-service-dns-troubleshooting/` (I broke the targetPort on purpose) |
| 8 | Configuration | `scenarios/scenario-1-crashloop/` (missing env var) |
| 9 | Configuration (memory limit) | `scenarios/scenario-5-oomkilled/` |

---

## Issue 1 — CrashLoopBackOff

**Problem statement:** Pod `crash-demo` keeps restarting and never stays Running.

**Investigation:**

```bash
kubectl apply -f 06-crashloopbackoff/broken-pod.yaml
kubectl get pod crash-demo -w
kubectl describe pod crash-demo
kubectl logs crash-demo
kubectl events --for pod/crash-demo
```

![crashloop before](./screenshots/t2-01a-crashloop-investigate.png)

What I saw:
- Status keeps cycling `Running → Error → CrashLoopBackOff`. The wait between restarts gets longer each time (~10s, 20s, 40s… up to 5 min). That growing wait is what "back-off" means.
- `describe` shows `Last State: Terminated, Reason: Error, Exit Code: 1`.
- `logs` shows `Something went wrong!`.
- Events show `Back-off restarting failed container`.

**Root cause:** the container's command runs `exit 1`. The app ends with an error every time it starts, and Kubernetes keeps restarting it.

**Solution:** run the fixed command, which keeps the app running. Most Pod fields can't be changed after creation, so delete and re-create it:

```bash
kubectl delete pod crash-demo
kubectl apply -f 06-crashloopbackoff/fixed-pod.yaml
```

**Verify (after):**

![crashloop after](./screenshots/t2-01b-crashloop-fix.png)

`1/1 Running`, 0 restarts, and the log says `Application is healthy`.

---

## Issue 2 — ErrImagePull / ImagePullBackOff

### 2a. Wrong image tag (`07-imagepullbackoff`)

**Problem statement:** Pod `image-demo` never starts.

```bash
kubectl apply -f 07-imagepullbackoff/broken-pod.yaml
kubectl get pod image-demo -w
kubectl describe pod image-demo
kubectl events --for pod/image-demo
kubectl logs image-demo
```

![image pull before](./screenshots/t2-02a-imagepull-investigate.png)

What I saw:
- `ErrImagePull` = the pull **just failed**. `ImagePullBackOff` = Kubernetes is **waiting before it tries again**. They keep switching back and forth.
- Event: `docker.io/library/nginx:this-image-does-not-exist: not found`.
- `kubectl logs` doesn't help here. The container never started, so there are no logs. **Events are the key.**

**Root cause:** the tag `this-image-does-not-exist` doesn't exist on Docker Hub.

**Solution / verify:**

```bash
kubectl delete pod image-demo
kubectl apply -f 07-imagepullbackoff/fixed-pod.yaml     # image: nginx:1.27
```

![image pull after](./screenshots/t2-02b-imagepull-fix.png)

### 2b. Repository does not exist (`scenario-2`)

A different error message: `pull access denied, repository does not exist or may require authorization`. This means the **image name** is wrong (or it's a private image that needs login), not just the tag.

The image is one of the few Pod fields that **can** be changed in place, so I fixed it without deleting the Pod:

```bash
kubectl apply -f scenarios/scenario-2-imagepull/broken.yaml
kubectl describe pod fail-2-imagepull-pod
kubectl set image pod/fail-2-imagepull-pod web-app=nginx:alpine
```

![scenario 2](./screenshots/t2-02c-imagepull-scenario2.png)

### 2c. ⚠️ Real bug I found in this session's files

`09-service-dns-troubleshooting/dns-test-pod.yaml` uses `registry.k8s.io/e2e-test-images/dnsutils:1.3`. **That image doesn't exist**, so the Pod was stuck in `ImagePullBackOff`. I fixed the live Pod with `busybox:1.36`, which has `nslookup`, `wget` and `ping`:

```bash
kubectl set image pod/dns-test dns-test=busybox:1.36
```

![dns-test image bug](./screenshots/t2-05-real-bug-dnstest-image.png)

> Note: busybox `nslookup` prints a few extra `NXDOMAIN` lines for short names while it tries each search domain. DNS still works. Using the full name (`<svc>.<namespace>.svc.cluster.local`) gives clean output.

---

## Issue 3 — Pending

**Problem statement:** Pods `pending-demo` and `fail-3-pending-pod` stay `Pending` with no IP and no node.

```bash
kubectl apply -f 08-pending-pods/broken-pod.yaml
kubectl apply -f scenarios/scenario-3-pending/broken.yaml
kubectl get pods -o wide
kubectl describe pod pending-demo
kubectl describe pod fail-3-pending-pod
kubectl get nodes --show-labels
kubectl describe node minikube
```

![pending before](./screenshots/t2-03a-pending-investigate.png)

What I saw (`FailedScheduling` event from the scheduler):
- `pending-demo`: `1 node(s) didn't match Pod's node affinity/selector`.
- `fail-3-pending-pod`: `1 Insufficient cpu, 1 Insufficient memory`.

**Root cause:**
- `pending-demo` has `nodeSelector: kubernetes.io/hostname=node-that-does-not-exist`, but the only node is `minikube`.
- `fail-3-pending-pod` requests **500 CPUs and 1000Gi memory**, but the node only has **8 CPUs and ~8Gi**.

Pending means "the scheduler can't find a node". **Logs are empty** because the container never started. The answer is in `describe` → Events.

**Solution / verify:**

```bash
kubectl delete pod pending-demo fail-3-pending-pod
kubectl apply -f 08-pending-pods/fixed-pod.yaml          # no nodeSelector
kubectl apply -f scenarios/scenario-3-pending/broken.yaml --dry-run=client -o yaml \
  | sed -e 's/cpu: "500"/cpu: 100m/' -e 's/memory: 1000Gi/memory: 64Mi/' \
  | kubectl apply -f -                                   # realistic requests
```

![pending after](./screenshots/t2-03b-pending-fix.png)

Both Pods are `Running` with an IP and a node.

---

## Issue 4 — Stuck in ContainerCreating

**Problem statement:** a Pod stays in `ContainerCreating` and never moves on.

There is no file for this in the session, so I created the problem with one command: a Pod that mounts a ConfigMap called `app-config` that doesn't exist.

```bash
kubectl run cc-demo --image=nginx:1.27 --overrides='{"spec":{"containers":[{"name":"cc-demo","image":"nginx:1.27","volumeMounts":[{"name":"cfg","mountPath":"/etc/app"}]}],"volumes":[{"name":"cfg","configMap":{"name":"app-config"}}]}}'
kubectl get pod cc-demo
kubectl describe pod cc-demo
kubectl events --for pod/cc-demo
kubectl get configmap app-config
```

![containercreating before](./screenshots/t2-04a-containercreating-investigate.png)

What I saw: event `FailedMount: MountVolume.SetUp failed for volume "cfg" : configmap "app-config" not found`.

**Root cause:** the Pod was scheduled, but the kubelet **can't prepare the volume**, so the container can't be created. Other common causes of ContainerCreating: a missing Secret, a PVC that isn't bound, CNI (network) problems, or a very slow image pull.

**Solution:** create the missing ConfigMap. No need to touch the Pod, because the kubelet keeps retrying:

```bash
kubectl create configmap app-config --from-literal=APP_MODE=production
```

![containercreating after](./screenshots/t2-04b-containercreating-fix.png)

The Pod became `Running` by itself, and the file `/etc/app/APP_MODE` contains `production`.

---

## Issue 5 — Service connectivity (⚠️ real bug in `09/service.yaml`)

**Problem statement:** the `web` Pods are Running, but calling `http://web-service` from another Pod fails.

```bash
kubectl apply -f 09-service-dns-troubleshooting/deployment.yaml
kubectl apply -f 09-service-dns-troubleshooting/service.yaml
kubectl apply -f 09-service-dns-troubleshooting/dns-test-pod.yaml

kubectl exec dns-test -- wget -qO- -T 5 http://web-service
kubectl exec dns-test -- nslookup web-service.s14-lab.svc.cluster.local
kubectl get endpointslices -l kubernetes.io/service-name=web-service
kubectl describe service web-service
kubectl get pods --show-labels -l app=web
```

![service before](./screenshots/t2-05a-service-investigate.png)

What I saw:
- `wget`: **Connection refused**.
- DNS **works** (the name resolves to the ClusterIP `10.111.94.103`), so DNS is not the problem.
- Endpoints: **empty** (`<unset>`).
- Service selector: `app=web-ahsgdf`. Pod labels: `app=web`.

**Root cause:** the selector in `09-service-dns-troubleshooting/service.yaml` has a typo (`web-ahsgdf` instead of `web`). The Service matches no Pods, so it has no endpoints, and traffic has nowhere to go.

**Solution:** fix the selector on the live Service (the file itself still needs `app: web`):

```bash
kubectl patch service web-service -p '{"spec":{"selector":{"app":"web"}}}'
```

![service after](./screenshots/t2-05b-service-fix.png)

Endpoints now list both Pod IPs, and `wget` returns `Welcome to nginx!`.

(`09/broken-service.yaml`, with `app: does-not-exist`, is exactly the same kind of problem. The mini project below shows it again.)

---

## Issue 6 — DNS

**Problem statement:** Pod `fail-4-dns-failure-pod` is `Running`, but it can't reach its database.

```bash
kubectl apply -f scenarios/scenario-4-dns-failure/broken.yaml
kubectl logs fail-4-dns-failure-pod
kubectl exec fail-4-dns-failure-pod -- curl -sS --connect-timeout 3 http://postgres-db-wrong-name.production.svc.cluster.local:5432
kubectl exec dns-test -- nslookup postgres-db-wrong-name.production.svc.cluster.local
kubectl exec dns-test -- nslookup kubernetes.default.svc.cluster.local
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get namespace production
kubectl get svc -A | grep postgres
kubectl exec fail-4-dns-failure-pod -- cat /etc/resolv.conf
```

![dns before](./screenshots/t2-06a-dns-investigate.png)

What I saw:
- The logs **hide** the error, because the script uses `curl -s ... || true`. A "Running" Pod can still be broken.
- Running curl myself: `Could not resolve host`.
- `nslookup` of that name gives `NXDOMAIN` (the name does not exist).
- But `kubernetes.default.svc.cluster.local` resolves fine, CoreDNS is `Running`, and `resolv.conf` points at `10.96.0.10`. **DNS itself is healthy.**
- The namespace `production` doesn't exist, and there is no postgres Service anywhere.

**Root cause:** the app uses a **wrong hostname**. DNS name format is `<service>.<namespace>.svc.cluster.local`, and both the service name and the namespace here are wrong.

**Solution:** point the app at the correct Service name. There is no real database in this lab, so I used the existing `web-service` to prove name lookup now works:

```bash
kubectl delete pod fail-4-dns-failure-pod
kubectl apply -f scenarios/scenario-4-dns-failure/broken.yaml --dry-run=client -o yaml \
  | sed 's#postgres-db-wrong-name.production.svc.cluster.local:5432#web-service.s14-lab.svc.cluster.local:80#' \
  | kubectl apply -f -
```

![dns after](./screenshots/t2-06b-dns-fix.png)

The log now shows the nginx page title, and curl returns `HTTP 200`.

---

## Issue 7 — Pod networking (wrong targetPort)

**Problem statement:** the Service **has** endpoints this time, but connections are still refused.

To create this, I changed the live Service's `targetPort` from 80 to 8080:

```bash
kubectl patch service web-service --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":8080}]'
```

**Investigation:** test the network one layer at a time:

```bash
kubectl exec dns-test -- wget -qO- -T 5 http://web-service           # through the Service
kubectl get endpointslices -l kubernetes.io/service-name=web-service # endpoints + port
kubectl get pods -o wide -l app=web                                  # Pod IPs
kubectl exec dns-test -- ping -c 2 <pod-ip>                          # can Pods reach each other?
kubectl exec dns-test -- wget -qO- http://<pod-ip>:8080              # the port the Service uses
kubectl exec dns-test -- wget -qO- http://<pod-ip>:80                # the port the app uses
kubectl exec <web-pod> -- grep listen /etc/nginx/conf.d/default.conf
```

![network before](./screenshots/t2-07a-network-investigate.png)

What I saw:
- Pod-to-Pod **ping works**, so the Pod network (CNI) is fine.
- `<pod-ip>:8080` is **refused**, but `<pod-ip>:80` **works**.
- nginx is `listen 80`, `containerPort` is 80, but the Service has `targetPort: 8080`.

**Root cause:** the Service sends traffic to port 8080, but nothing in the Pod is listening there.

**Solution / verify:**

```bash
kubectl patch service web-service --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":80}]'
```

![network after](./screenshots/t2-07b-network-fix.png)

---

## Issue 8 — Configuration issue (missing environment variable)

**Problem statement:** Pod `fail-1-crashloop-pod` keeps crashing.

```bash
kubectl apply -f scenarios/scenario-1-crashloop/broken.yaml
kubectl get pod fail-1-crashloop-pod
kubectl logs fail-1-crashloop-pod
kubectl describe pod fail-1-crashloop-pod
```

![config before](./screenshots/t2-08a-config-investigate.png)

What I saw: `[FATAL ERROR]: DATABASE_URL environment variable is MISSING!`, Exit Code 1, and `Environment: <none>`.

**Root cause:** the app needs the setting `DATABASE_URL`, but nobody gave it one.

**Solution, part 1:** store the setting in a **ConfigMap** and load it into the container with `envFrom`:

```bash
kubectl create configmap db-config --from-literal=DATABASE_URL=postgres://app:app@db.s14-lab.svc.cluster.local:5432/app
sed '/image: python:3.11-alpine/a\      envFrom:\n        - configMapRef:\n            name: db-config' \
    scenarios/scenario-1-crashloop/broken.yaml | kubectl apply -f -
```

![config fix](./screenshots/t2-08b-config-fix.png)

Two lessons from this screenshot:
- Applying over the old Pod failed with `Forbidden: pod updates may not change fields other than ...image...`. **Most Pod fields can't be changed after creation**, so you must delete and re-create the Pod. (A Deployment does this for you.)
- After the fix, the log says `Application started successfully!` with **exit code 0**, but **Restarts was still going up**.

**Solution, part 2:** this script runs once and then stops. A Pod's default `restartPolicy: Always` restarts it even after it **succeeds**. For a run-once task, use `restartPolicy: OnFailure` (or a Kubernetes **Job**):

```bash
kubectl delete pod fail-1-crashloop-pod
sed -e '/image: python:3.11-alpine/a\      envFrom:\n        - configMapRef:\n            name: db-config' \
    -e 's/^spec:/spec:\n  restartPolicy: OnFailure/' \
    scenarios/scenario-1-crashloop/broken.yaml | kubectl apply -f -
```

![config restartPolicy](./screenshots/t2-08c-config-restartpolicy.png)

**Verify:** `Completed`, **0 restarts**, exit code 0. ✅

---

## Issue 9 — OOMKilled (memory limit too small)

**Problem statement:** Pod `fail-5-oomkilled-pod` restarts again and again.

```bash
kubectl apply -f scenarios/scenario-5-oomkilled/broken.yaml
kubectl get pod fail-5-oomkilled-pod
kubectl describe pod fail-5-oomkilled-pod
```

![oom before](./screenshots/t2-09a-oomkilled-investigate.png)

What I saw: `Last State: Terminated, Reason: OOMKilled, Exit Code: 137`, with `Limits: memory: 20Mi`.
Exit code **137** = the process was killed by the system (128 + signal 9) because it used more memory than its limit.

**Root cause:** the memory limit (20Mi) is much smaller than what the program uses.

**Solution:** my first try with 256Mi was **still OOMKilled**. Reading the code showed why: the YAML comment says "200MB", but `100 × 10 MB` is about **1000 MB**. With a 1200Mi limit (plus `restartPolicy: OnFailure`, because it's a run-once script) it finished:

```bash
kubectl delete pod fail-5-oomkilled-pod
sed -e 's/memory: "20Mi"/memory: "1200Mi"/' -e 's/^spec:/spec:\n  restartPolicy: OnFailure/' \
    scenarios/scenario-5-oomkilled/broken.yaml | kubectl apply -f -
```

![oom after](./screenshots/t2-09b-oomkilled-fix.png)

**Verify:** `Completed`, `exitCode=0`. In a real app, the better fix is to stop the code from using so much memory. A bigger limit is only right if the app truly needs that much.

---

# Task 3 — Mini project (`mini-project/`)

### Step 1 — Deploy

```bash
kubectl apply -f mini-project/deployment.yaml
kubectl apply -f mini-project/service.yaml
```

![deploy](./screenshots/t3-01-deploy.png)

### Step 2 — Check the application

```bash
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec <pod-name> -- curl -s localhost
```

![check app](./screenshots/t3-02-check-app.png)

### Steps 3–4 — Check the Service, endpoints and DNS

```bash
kubectl describe service troubleshooting-service
kubectl get endpoints troubleshooting-service
kubectl exec dns-test -- nslookup troubleshooting-service.s14-lab.svc.cluster.local
kubectl exec dns-test -- wget -qO- http://troubleshooting-service
```

![check service](./screenshots/t3-03-check-service.png)

Selector `app=troubleshooting-app`, targetPort 80, and 2 endpoints. DNS resolves and HTTP works.

### Steps 5–6 — Broken Pod

Following the project rule, I investigated **before** changing anything:

```bash
kubectl apply -f mini-project/broken-pod.yaml
kubectl get pod project-broken-pod
kubectl describe pod project-broken-pod      # -> Events
```

![broken pod](./screenshots/t3-04-broken-pod-investigate.png)

**Fix and verify:**

```bash
kubectl set image pod/project-broken-pod app=nginx:1.27
```

![broken pod fixed](./screenshots/t3-05-broken-pod-fix.png)

### Step 7 — Answers

| Question | Answer |
| :--- | :--- |
| **1. What is the Pod status?** | `ErrImagePull`, switching with `ImagePullBackOff`. `READY 0/1`. |
| **2. What is the actual error?** | `Failed to pull image "nginx:this-tag-does-not-exist": ... not found` |
| **3. Which command helped find the reason?** | `kubectl describe pod project-broken-pod`, in the **Events** section. (`kubectl logs` can't help because the container never started.) |
| **4. What is wrong with the image?** | The image `nginx` exists, but the **tag** `this-tag-does-not-exist` doesn't. |
| **5. How would you fix it?** | Use a real tag, e.g. `nginx:1.27`: edit the YAML and re-apply, or run `kubectl set image pod/project-broken-pod app=nginx:1.27` (done above). |

### Steps 8–9 — Service selector challenge

I broke the selector on the **live** Service, so `service.yaml` stays correct:

```bash
kubectl patch service troubleshooting-service -p '{"spec":{"selector":{"app":"wrong-app"}}}'
kubectl get endpoints troubleshooting-service           # <none>
kubectl get pods --show-labels                          # app=troubleshooting-app
kubectl describe service troubleshooting-service        # Selector: app=wrong-app
```

![selector broken](./screenshots/t3-06-selector-break.png)

**Root cause:** the selector `app=wrong-app` doesn't match the Pod label `app=troubleshooting-app`, so there are no endpoints and the connection is refused.
**Fix:** re-apply the correct file:

```bash
kubectl apply -f mini-project/service.yaml
```

![selector fixed](./screenshots/t3-07-selector-fix.png)

### Final state

![final](./screenshots/t3-08-final-state.png)

```text
                 troubleshooting-service (ClusterIP)
                    selector: app=troubleshooting-app
                    /                         \
        troubleshooting-app Pod 1     troubleshooting-app Pod 2
              (nginx:1.27)                 (nginx:1.27)
```

### Step 11 — Troubleshooting table

| Problem | What I saw | Command I used | Root cause | Fix |
| :--- | :--- | :--- | :--- | :--- |
| **Broken Pod** | `project-broken-pod` `0/1 ErrImagePull` | `kubectl get pod`, `kubectl describe pod` | Image tag does not exist | `kubectl set image ... app=nginx:1.27` |
| **Service Problem** | Endpoints `<none>`, wget `Connection refused` | `kubectl get endpoints`, `kubectl get pods --show-labels`, `kubectl describe service` | Selector `app=wrong-app` ≠ Pod label `app=troubleshooting-app` | `kubectl apply -f mini-project/service.yaml` |
| **Image Problem** | Event `Failed to pull image ... not found` | `kubectl describe pod` (Events) | `nginx:this-tag-does-not-exist` is not on Docker Hub | Use a real tag (`nginx:1.27`) |

### Step 12 — README questions

1. **What does `kubectl get` tell us?** A quick summary of resources: name, ready count, status, restarts and age. With `-o wide` you also get the IP and node. It answers "*what* is happening?"
2. **Difference between `get` and `describe`?** `get` is a one-line summary of many objects. `describe` is the full detail of one object, including its **Events**. It answers "*why* is it happening?"
3. **Why do we use `kubectl logs`?** To read what the application itself printed, like errors and stack traces. Use `--previous` to see the logs of a container that already crashed.
4. **When would you use `kubectl exec`?** When the container is running and you need to look inside: check files, env vars, `resolv.conf`, or test with `curl`/`nslookup` from inside the cluster.
5. **What does `CrashLoopBackOff` mean?** The container starts, exits, gets restarted, and exits again. Kubernetes waits a bit longer before each new restart (the "back-off").
6. **What does `ImagePullBackOff` mean?** Kubernetes couldn't download the image (wrong name or tag, private registry without login, or network problem), and it's waiting before trying again.
7. **Why can a Pod remain `Pending`?** The scheduler can't find a node for it: not enough CPU or memory, a `nodeSelector`/affinity that matches no node, taints, or a PVC that isn't bound.
8. **Why can a Service have no endpoints?** Its selector matches no Pods (typo or wrong label), or the matching Pods aren't Ready yet.
9. **Service selector vs Pod labels?** The Service sends traffic to every **Ready** Pod whose labels match its selector. Those Pods become its endpoints. If they don't match, there is no traffic.
10. **What is Kubernetes DNS?** CoreDNS, running in `kube-system`, gives every Service a name like `<service>.<namespace>.svc.cluster.local`, so Pods can find Services by name instead of by IP. Each Pod's `/etc/resolv.conf` points to it.

---

## Things I learned (gotchas)

- **Pending, ContainerCreating and ImagePullBackOff have no logs.** Look at `describe` → Events.
- **A "Running" Pod can still be broken.** Scenario 4 hid its error with `curl -s || true`.
- **Most Pod fields can't be changed after creation.** You have to delete and re-create the Pod, except for `image`, which `kubectl set image` can change.
- **`restartPolicy: Always` restarts even successful scripts.** Use `OnFailure` or a Job for one-time tasks.
- **Don't trust comments, read the code.** Scenario 5 said 200MB but really used about 1000MB.
- **Two real bugs in this session's files:** `09/service.yaml` has the selector typo `app: web-ahsgdf`, and `09/dns-test-pod.yaml` uses an image tag that doesn't exist (`dnsutils:1.3`).
- **Windows Git Bash** rewrites `/paths` in commands. Run `export MSYS_NO_PATHCONV=1` before `kubectl exec ... /etc/...`.

## Cleanup

```bash
kubectl delete namespace s14-lab
kubectl config set-context --current --namespace=default
```
