# DevOps Assignment Season 2

> All tasks from Lec 9 - Lec 12
> 

---

# Lecture 9

In the lecture (specifically at **07:15–08:45** and **105:20–108:45**), Mam outlined the exact deliverables for **Session 9**:

1. **Folder & Repository**:
    - Repository: `devops-heros`
    - Target Directory: `session9-k8s/`
    - Target File: Exactly **one** `README.md` inside `session9-k8s/`.
2. **Task 1: Minikube Installation & Environment Setup**:
    - Install `minikube` and `kubectl` on your machine.
    - Verify the installation with version checks.
3. **Task 2: Minikube Cluster Lifecycle Execution**:
    - Start your cluster: `minikube start`
    - Verify components are running: `minikube status`
    - Stop the cluster cleanly: `minikube stop`
4. **Task 3: Kubernetes Architecture & Core Components (Study & Documentation)**:
    - Mam explicitly mandated reading the [official Kubernetes Architecture documentation](https://kubernetes.io/docs/concepts/architecture/) and documenting the **Control Plane (Master)** and **Worker Node** components, explaining what each does and how they interact before next class.
5. **Submission Format**:
    - Each task must have a **one-line description**, the **exact command**, the **terminal output**, and a **screenshot placeholder**.
    - Submit the raw link of `session9-k8s/README.md` on GitHub into your section's Google Form.

---

### Quick Execution Steps (Run These in Your Terminal)

```bash
# 1. Navigate to your repository and create the session9 folder
cd devops-heros
mkdir -p session9-k8s/screenshots
cd session9-k8s

# 2. Check Minikube & Kubectl installation
minikube version
kubectl version --client

# 3. Start the local Kubernetes cluster
minikube start

# 4. Check cluster status (Take a screenshot here!)
minikube status
kubectl get nodes

# 5. Stop the cluster
minikube stop
```

---

### Complete, Ready-to-Submit `session9-k8s/README.md`

Copy the markdown content below directly into `session9-k8s/README.md` in your repository:

```markdown
# Session 9: Kubernetes Fundamentals & Cluster Architecture

**Author:** [Your Name]
**Course:** SST DevOps & Cloud [SWE]
**Session:** 09 - Kubernetes Fundamentals
**Repository:** devops-heros / session9-k8s

---

## Task 1: Minikube & CLI Installation Verification

Verify that Minikube and the Kubernetes CLI (`kubectl`) are successfully installed on the local system.

**Commands:**
```bash
minikube version
kubectl version --client
```

**Output:**
> (SS daal dena)

( cotinue for other tasks )
```

**Output:**

```
minikube version: v1.33.1
commit: e32c234d1081dc36b5c3b10b0a0714b9b9886ac0

Client Version: v1.30.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bd390ce3
```

**Screenshot:**

`![Minikube and Kubectl Version](./screenshots/01-version-check.png)`

---

## Task 2: Starting the Minikube Kubernetes Cluster

Initialize the local single-node Kubernetes cluster using the containerized runtime environment.

**Command:**

```bash
minikube start
```

**Output:**

```
😄  minikube v1.33.1 on Darwin 14.5 (arm64)
✨  Automatically selected the docker driver. Other choices: qemu2, ssh
📌  Using Docker Desktop driver with root permissions
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.44 ...
🔥  Creating docker container (CPUs=2, Memory=4000MB) ...
🐳  Preparing Kubernetes v1.30.0 on containerd 1.7.15 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Network Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

**Screenshot:**

`![Minikube Start](./screenshots/02-minikube-start.png)`

---

## Task 3: Verifying Cluster Status & Node Health

Inspect the status of the local cluster control plane, kubelet, API server, and verify the node is in `Ready` state.

**Commands:**

```bash
minikube status
kubectl get nodes -o wide
```

**Output:**

```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

NAME       STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
minikube   Ready    control-plane   2m15s   v1.30.0   192.168.49.2   <none>        Ubuntu 22.04.4 LTS   6.6.137+rpt-rpi-v8 containerd://1.7.15
```

**Screenshot:**

`![Minikube Status and Nodes](./screenshots/03-minikube-status.png)`

---

## Task 4: Stopping the Minikube Cluster

Gracefully power down the Minikube cluster VM/container to release system resources.

**Command:**

```bash
minikube stop
minikube status
```

**Output:**

```
✋  Stopping node "minikube" ...
🛑  Powering off "minikube" via SSH ...
🛑  1 node stopped.

minikube
type: Control Plane
host: Stopped
kubelet: Stopped
apiserver: Stopped
kubeconfig: Configured
```

**Screenshot:**

`![Minikube Stop](./screenshots/04-minikube-stop.png)`

---

## Task 5: Kubernetes Cluster Architecture & Component Analysis

> **Khud se short me kar/karwa lena, as itna bada nahi daalna hai.**
> 

Comprehensive breakdown of the core components powering a Kubernetes cluster based on official documentation and classroom discussion.

```
+-------------------------------------------------------------------------------+
|                               CONTROL PLANE (MASTER)                          |
|                                                                               |
|   +-------------------+       +--------------------+       +--------------+   |
|   |       etcd        |<----->|  kube-apiserver    |<----->|kube-scheduler|   |
|   | (State Database)  |       |    (Front Door)    |       +--------------+   |
|   +-------------------+       +---------+----------+                          |
|                                         |                                     |
|                                         v                                     |
|                             +------------------------+                        |
|                             | kube-controller-manager|                        |
|                             +------------------------+                        |
+-----------------------------------------+-------------------------------------+
                                          |
                        +-----------------+-----------------+
                        |                                   |
                        v                                   v
+------------------------------------+ +------------------------------------+
|          WORKER NODE 1             | |          WORKER NODE 2             |
|                                    | |                                    |
|   +------------+  +------------+   | |   +------------+  +------------+   |
|   |  kubelet   |  | kube-proxy |   | |   |  kubelet   |  | kube-proxy |   |
|   +-----+------+  +-----+------+   | |   +-----+------+  +-----+------+   |
|         |               |          | |         |               |          |
|         v               v          | |         v               v          |
|   +----------------------------+   | |   +----------------------------+   |
|   | CRI (containerd runtime)   |   | |   | CRI (containerd runtime)   |   |
|   +----------------------------+   | |   +----------------------------+   |
|         |                          | |         |                          |
|         v                          | |         v                          |
|   +------------+  +------------+   | |   +------------+  +------------+   |
|   |   Pod 1    |  |   Pod 2    |   | |   |   Pod 3    |  |   Pod 4    |   |
|   | [Container]|  | [Container]|   | |   | [Container]|  | [Container]|   |
|   +------------+  +------------+   | |   +------------+  +------------+   |
+------------------------------------+ +------------------------------------+
```

### 1. Control Plane (Master Node) Components

- **`kube-apiserver` (The Front Door)**:
    - Acts as the single entry point for all administrative tasks and internal communications.
    - Exposes the Kubernetes HTTP/JSON REST API.
    - Every command (`kubectl`, web dashboard, internal controllers) must authenticate and communicate through the API server. No component directly accesses `etcd` except the API server.
- **`etcd` (The Brain & State Storage)**:
    - A distributed, highly available, consistent key-value store.
    - Stores the entire cluster state, specifications, secrets, and metadata.
    - *Important Concept:* In Kubernetes, everything is treated as an API object, and its declarative desired state is persisted in `etcd`.
- **`kube-scheduler` (The Placement Engine)**:
    - Continuously watches for newly created Pods that have no assigned worker node.
    - Analyzes resource requirements (CPU, memory, storage), affinity/anti-affinity specifications, taints, and tolerations to pick the optimal worker node to run the Pod.
- **`kube-controller-manager` (The Enforcer / Reconciliation Loop)**:
    - Executes continuous control loops that check: **Current State == Desired State**.
    - Contains sub-controllers such as:
        - *Node Controller*: Detects when nodes go offline and handles eviction.
        - *ReplicaSet Controller*: Ensures the requested number of pod replicas are running at all times.
        - *EndpointSlice / Service Controller*: Links Services to live Pod IPs.

---

### 2. Worker Node (Data Plane) Components

- **`kubelet` (The Node Captain)**:
    - The primary agent running on every worker node.
    - Receives `PodSpec` objects from `kube-apiserver` and instructs the Container Runtime to pull images and start containers.
    - Continuously monitors container health and reports heartbeats and status back to the API server.
- **`kube-proxy` (The Network Router)**:
    - Network proxy running on each node that maintains network rules (`iptables` / `IPVS`).
    - Enables Kubernetes Services to route TCP/UDP packets across pods, handling internal cluster routing and load balancing.
- **`Container Runtime Interface (CRI)`**:
    - The software responsible for actually running containers.
    - *Evolution:* While early Kubernetes versions relied directly on the Docker daemon, modern Kubernetes utilizes standardized, lightweight runtimes such as **`containerd`** or **`CRI-O`**.
- **`Pod` (The Smallest Deployable Unit)**:
    - The fundamental unit of execution in Kubernetes.
    - Encapsulates one or more tightly coupled containers sharing the same network namespace (IP address and port space) and storage volumes.
    - In standard enterprise patterns, most pods run a single primary application container with optional helper sidecar/init containers.

---

### Submission Steps for Today:

1. Capture screenshots of your terminal running `minikube version`, `minikube start`, `minikube status`, and `minikube stop`.
2. Save the screenshots inside `session9-k8s/screenshots/`.
3. Push to your GitHub:
    
    ```bash
    git add session9-k8s/
    git commit -m "Submit Session 9 Kubernetes fundamentals and Minikube setup"
    git push origin main
    ```
    
4. Copy the URL of `session9-k8s/README.md` from your GitHub repo and paste it into your Google Form submission link.

---

# Lecture 10

# All Tasks

> **Isme tasks Lec 11, 12 me se bhi hai cuz Lec 11, 12 me mam ne Lec 10 ki bhi cheeze karayi hai**
> 
- **Task 1: Cluster Health Verification & Baseline Environment Checks**
    - Start the local Kubernetes cluster (`minikube`, `kind`, or Docker Desktop).
    - Verify client/server versions, cluster control plane and CoreDNS endpoints, and node readiness states using `kubectl cluster-info`, `kubectl version`, and `kubectl get nodes`.
- **Task 2: Standard Pod Deployment, Extended Inspection & Teardown (`pod.yml`)**
    - Deploy a standalone Nginx pod manifest specifying the 4 mandatory top-level fields (`apiVersion`, `kind`, `metadata`, `spec`).
    - Verify pod readiness (`1/1 Running`), inspect IP assignment and node placement with `o wide`, view container execution logs, and execute pod deletion.
- **Task 3: Error State Simulation — `ErrImagePull` & `ImagePullBackOff`**
    - Modify a pod definition to reference an invalid/non-existent container image tag.
    - Apply the manifest, observe the container state transition from `ErrImagePull` to `ImagePullBackOff`, and describe why the API object creation succeeds in `etcd` while the runtime container fails.
- **Task 4: Capturing Transient Pod Lifecycle Stages (`hello.yml`)**
    - Deploy a batch container using `busybox` with `restartPolicy: Never` running a short-lived command.
    - Rapidly poll `kubectl get pods` to capture all 3 transient phases: `ContainerCreating` $\rightarrow$ `Running` $\rightarrow$ `Completed` (Phase: `Succeeded`).
- **Task 5: Exhaustive Pod Lifecycle States & Probes Lab (`pod-lifecycle/`)**
    - Execute and document the 12 lifecycle manifests from `session10-k8s-core-objects/pod-lifecycle/`:
        1. `01-running.yaml` (Active running state).
        2. `02-pending.yaml` (Resource request pressure / unschedulable pod).
        3. `03-succeeded.yaml` (`restartPolicy: Never`, exit code 0).
        4. `04-failed.yaml` (`restartPolicy: Never`, exit code 1).
        5. `05-crashloopbackoff.yaml` (Repeated container crash and exponential backoff).
        6. `06-imagepullbackoff.yaml` (Invalid image registry tag).
        7. `07-readiness.yaml` (Differentiating between container `Running` and `Ready` for traffic).
        8. `08-liveness.yaml` (Automated self-healing restart triggered by probe failure).
        9. `09-startup.yaml` (Protecting slow-starting legacy applications).
        10. `10-init-container.yaml` (Sequential prerequisite setup container execution).
        11. `11-multi-container.yaml` (Pod multi-tenancy: App container + logging sidecar).
        12. `12-termination.yaml` (Graceful shutdown handling via `SIGTERM` trap and `terminationGracePeriodSeconds`).
- **Task 6: Core Controller Objects Exploration (ReplicaSet & StatefulSet)**
    - **ReplicaSet (`replicaset.yml`):** Verify desired replica count enforcement and test automated self-healing by manually deleting a pod.
    - **StatefulSet (`statefulset.yml`):** Deploy a stateful workload (MySQL), verify deterministic ordinal pod naming (`mysql-0`, `mysql-1`), and inspect persistent volume claim bindings.
- **Task 7: DaemonSet Architecture & Host Agent Deployment (`daemonset/`)**
    - Deploy a DaemonSet workload (`deamonset.yml` or `daemonset/node-agent-ds.yaml`) representing a host-level telemetry/security collector (e.g., node-exporter or Falco).
    - Verify that exactly one pod instance runs per available worker node.
- **Task 8: Deployment Upgrades, Rolling Updates & Instant Rollbacks (`deployment/`)**
    - Deploy `deployment-v1.yaml` (v1 app with 3 replicas) and observe healthy rollout status.
    - Upgrade to `deployment-v2.yaml` configured with `maxSurge: 1` and `maxUnavailable: 0`.
    - Monitor zero-downtime rolling updates in real time using `kubectl rollout status` and watch pod replacement churn.
    - Execute an immediate rollback to v1 using `kubectl rollout undo` and inspect revision history.
- **Task 9: Real-World Troubleshooting Scenarios Lab (`troubleshooting/`)**
    - **Drill 1 (`broken-image.yaml`):** Diagnose a halted rollout caused by an unresolvable image tag on newly surged pods, verify that old pods remain healthy, and resolve the deployment.
    - **Drill 2 (`selector-mismatch.yaml`):** Diagnose why the Kubernetes API server rejects an invalid deployment due to an immutable label selector mismatch between `spec.selector.matchLabels` and `spec.template.metadata.labels`, then correct it.
- **Task 10: Theoretical & Architectural Conceptual Writeup**
    - Document the exact differences between `containerPort`, `targetPort`, `port`, and `nodePort`.
    - Differentiate between `Labels` and `Selectors`.
    - Explain the 4 primary deployment strategies (RollingUpdate, Blue-Green, Canary, Recreate).
    - Detail `maxSurge` vs `maxUnavailable` percentage calculations.
    - Differentiate between Resource Requests vs Limits and memory units (GB vs GiB).
- **Task 11: Blue-Green Deployment Execution & Instant Selector Cutover (`02-blue-green/`)**
    - Deploy two isolated, identical environments simultaneously: Blue (`app-blue`, v1, 3 replicas) and Green (`app-green`, v2, 3 replicas) from `session10-k8s-core-objects/02-blue-green/`.
    - Route initial live traffic to Blue using `service-blue.yaml` (`selector: slot: blue`).
    - Execute the cutover switch by applying `service-green.yaml` (`selector: slot: green`), verifying that 100% of user traffic flips to Green in milliseconds without intermediate mixed-version traffic.
    - Test instant rollback to Blue by flipping the selector back, and clean up the inactive Blue deployment.
- **Task 12: Canary Deployment Execution & Pod-Ratio Traffic Splitting (`03-canary/`)**
    - Deploy the stable production baseline of 9 pods (v1) using `03-canary/deployment-stable.yaml` and expose it via `03-canary/service.yaml`.
    - Introduce the canary release by deploying 1 pod (v2) using `03-canary/deployment-canary.yaml`, creating an approximate 9:1 (90% stable / 10% canary) traffic split across shared service endpoints.
    - Verify the traffic distribution in real time using a curl loop.
    - Shift traffic dynamically by scaling the canary deployment to 3 replicas (30%) and stable to 7 replicas (70%), then test canary rollback by scaling canary replicas down to 0.
- **Task 13: Recreate Deployment Execution & Downtime Outage Demonstration (`04-recreate/`)**
    - Deploy 3 replicas of v1 using `04-recreate/deployment-v1.yaml` and expose them via `04-recreate/service.yaml`.
    - Trigger the recreate update by applying `04-recreate/deployment-v2.yaml` (`strategy.type: Recreate`).
    - Run a continuous curl loop during the update to capture the deliberate **service downtime / connection refused outage window** while all v1 pods are terminated before any v2 pods start.
    - Verify v2 restoration once new pods pass their readiness checks, and execute a rollback with `kubectl rollout undo`.

---

# Aise Karna Hai

---

### Task 1: Cluster Health Verification & Baseline Environment Checks

- **Description:** Verify that the local Kubernetes cluster control plane, DNS components, and worker nodes are operational prior to workload deployments.
- **Commands to Run:**
    
    ```bash
    # Check Kubernetes client and server versions
    kubectl version --output=yaml
    
    # Check control plane and CoreDNS status
    kubectl cluster-info
    
    # Verify all nodes are in Ready status
    kubectl get nodes -o wide
    ```
    
- **Expected Terminal Output:**
    
    ```
    Kubernetes control plane is running at <https://127.0.0.1:52554>
    CoreDNS is running at <https://127.0.0.1:52554/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy>
    
    NAME                   STATUS   ROLES           AGE   VERSION
    demo-cluster-control   Ready    control-plane   6d    v1.29.1
    demo-cluster-worker    Ready    <none>          6d    v1.29.1
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `01-cluster-health.png`
    - **Content:** Terminal showing successful execution of `kubectl cluster-info` and `kubectl get nodes` showing `Ready` nodes.

---

### Task 2: Standard Pod Deployment, Extended Inspection & Teardown (`pod.yml`)

- **Description:** Create an individual Pod running Nginx, inspect its labels, runtime IP, node assignment, and container logs, then cleanly delete it.
- **File Reference:** `session10-k8s-core-objects/pod.yml`
- **Commands to Run:**
    
    ```bash
    # Deploy Nginx pod
    kubectl apply -f pod.yml
    
    # Verify Pod readiness (1/1 Running)
    kubectl get pods
    
    # Inspect IP address and assigned worker node
    kubectl get pods -o wide
    
    # Inspect live container logs
    kubectl logs nginx-pod
    
    # Delete pod and confirm termination
    kubectl delete -f pod.yml
    kubectl get pods
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `02-nginx-pod-operations.png`
    - **Content:** Output of `kubectl get pods -o wide` showing `1/1 Running` with IP and Node, followed by `kubectl logs nginx-pod`.

---

### Task 3: Error State Simulation — `ErrImagePull` & `ImagePullBackOff`

- **Description:** Demonstrate Kubernetes error handling when pulling a non-existent container image, observing the exponential backoff loop.
- **File Reference:** `session10-k8s-core-objects/pod-lifecycle/06-imagepullbackoff.yaml` (or manually edited `pod.yml`)
- **Commands to Run:**
    
    ```bash
    # Apply broken image manifest
    kubectl apply -f pod-lifecycle/06-imagepullbackoff.yaml
    
    # Observe failure state
    kubectl get pods lifecycle-image-error
    
    # Inspect failure events recorded by the Kubelet
    kubectl describe pod lifecycle-image-error | grep -A 10 Events:
    
    # Clean up
    kubectl delete -f pod-lifecycle/06-imagepullbackoff.yaml
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `03-imagepullbackoff-error.png`
    - **Content:** Terminal displaying `STATUS ImagePullBackOff` or `ErrImagePull`, and the `Failed to pull image` event from `kubectl describe`.

---

### Task 4: Capturing Transient Pod Lifecycle Stages (`hello.yml`)

- **Description:** Deploy a batch execution container (`busybox`) configured with `restartPolicy: Never` and capture all three lifecycle states in real time.
- **File Reference:** `session10-k8s-core-objects/hello.yml`
- **Commands to Run:**
    
    ```bash
    # In Terminal 1: Watch pods continuously
    kubectl get pods -w
    
    # In Terminal 2: Apply batch job
    kubectl apply -f hello.yml
    
    # Rapidly observe states:
    # Stage 1: ContainerCreating (runtime pulling image & configuring netns)
    # Stage 2: Running (process executing)
    # Stage 3: Completed (process terminated with exit code 0)
    kubectl get pods hello-pod
    
    # Verify exit code and logs
    kubectl logs hello-pod
    kubectl delete -f hello.yml
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `04-pod-lifecycle-stages.png`
    - **Content:** Terminal history capturing the progression: `ContainerCreating` $\rightarrow$ `Running` $\rightarrow$ `Completed` for `hello-pod`.

---

### Task 5: Exhaustive Pod Lifecycle States & Probes Lab (`pod-lifecycle/`)

- **Description:** Navigate to `session10-k8s-core-objects/pod-lifecycle/` and validate core lifecycle states, health checks, multi-container pods, and graceful termination.
- **Commands to Run:**
    
    ```bash
    cd session10-k8s-core-objects/pod-lifecycle/
    
    # 1. Pending State (Unschedulable due to impossible memory request)
    kubectl apply -f 02-pending.yaml
    kubectl get pod lifecycle-pending
    kubectl describe pod lifecycle-pending | grep -A 5 Events:
    kubectl delete -f 02-pending.yaml
    
    # 2. CrashLoopBackOff (Container exit code 1 restart loop)
    kubectl apply -f 05-crashloopbackoff.yaml
    kubectl get pod lifecycle-crashloop -w
    kubectl logs lifecycle-crashloop --previous
    kubectl delete -f 05-crashloopbackoff.yaml
    
    # 3. Readiness Probe (Validating Running != Ready)
    kubectl apply -f 07-readiness.yaml
    kubectl get pod lifecycle-readiness
    kubectl delete -f 07-readiness.yaml
    
    # 4. Liveness Probe (Automated restart on health failure)
    kubectl apply -f 08-liveness.yaml
    # Watch for 25-30s until RESTARTS increments to 1
    kubectl get pod lifecycle-liveness -w
    kubectl delete -f 08-liveness.yaml
    
    # 5. Startup Probe (Handling slow bootstrap without premature liveness death)
    kubectl apply -f 09-startup.yaml
    kubectl get pod lifecycle-startup
    kubectl delete -f 09-startup.yaml
    
    # 6. Init Container (Sequential setup completion prior to app start)
    kubectl apply -f 10-init-container.yaml
    kubectl describe pod lifecycle-init | grep -A 8 "Init Containers:"
    kubectl delete -f 10-init-container.yaml
    
    # 7. Multi-Container Pod (Main App + Logging Sidecar)
    kubectl apply -f 11-multi-container.yaml
    kubectl get pod lifecycle-multi-container # Shows READY 2/2
    kubectl logs lifecycle-multi-container -c sidecar
    kubectl delete -f 11-multi-container.yaml
    
    # 8. Graceful Termination (SIGTERM trap handling)
    kubectl apply -f 12-termination.yaml
    kubectl delete -f 12-termination.yaml # Notice 10s delay while handling cleanup
    ```
    
- **Screenshots to Attach:**
    - **Filename:** `05-lifecycle-probes-crashloop.png`
        - **Content:** Terminal showing `lifecycle-pending` (FailedScheduling event), `lifecycle-crashloop` (`CrashLoopBackOff`), and `lifecycle-liveness` (`RESTARTS: 1`).
    - **Filename:** `05-lifecycle-init-multicontainer.png`
        - **Content:** `lifecycle-multi-container` showing `2/2 Ready` and logs from `c sidecar`.

---

### Task 6: Core Controller Objects Exploration (ReplicaSet & StatefulSet)

- **Description:** Deploy self-healing stateless replication via a ReplicaSet and predictable stateful storage via a StatefulSet.
- **Commands to Run:**
    
    #### Part A: ReplicaSet
    
    ```bash
    # Deploy ReplicaSet
    kubectl apply -f session10-k8s-core-objects/replicaset.yml
    kubectl get rs nginx-rs
    kubectl get pods -l app=nginx
    
    # Test Self-Healing: Delete 1 pod manually
    POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
    kubectl delete pod $POD_NAME
    
    # Verify ReplicaSet instantly created a new pod to maintain desired count: 3
    kubectl get pods -l app=nginx
    kubectl delete -f session10-k8s-core-objects/replicaset.yml
    ```
    
    #### Part B: StatefulSet
    
    ```bash
    # Deploy StatefulSet
    kubectl apply -f session10-k8s-core-objects/k8s-core-objects/statefulset.yml
    kubectl get statefulset mysql
    
    # Notice ordinal names: mysql-0, mysql-1, mysql-2
    kubectl get pods -l app=mysql
    kubectl delete -f session10-k8s-core-objects/k8s-core-objects/statefulset.yml
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `06-controllers-rs-statefulset.png`
    - **Content:** ReplicaSet self-healing in action (terminating pod followed by an immediate replacement) and StatefulSet pods showing ordinal indices (`mysql-0`, `mysql-1`).

---

### Task 7: DaemonSet Architecture & Host Agent Deployment

- **Description:** Deploy a host agent DaemonSet (`node-exporter` or `node-agent-ds.yaml`), demonstrating that exactly one pod runs on each eligible cluster node.
- **Commands to Run:**
    
    ```bash
    # Deploy DaemonSet
    kubectl apply -f session10-k8s-core-objects/k8s-core-objects/deamonset.yml
    
    # Verify DaemonSet status
    kubectl get ds node-exporter
    
    # Inspect pod distribution across nodes
    kubectl get pods -l app=node-exporter -o wide
    kubectl delete -f session10-k8s-core-objects/k8s-core-objects/deamonset.yml
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `07-daemonset-verification.png`
    - **Content:** `kubectl get ds` and `kubectl get pods -o wide` proving 1 pod is scheduled per worker node.

---

### Task 8: Deployment Upgrades, Rolling Updates & Instant Rollbacks

- **Description:** Demonstrate declarative zero-downtime rolling updates using `maxSurge: 1` and `maxUnavailable: 0`, and execute an immediate rollback.
- **Commands to Run:**
    
    ```bash
    cd session10-k8s-core-objects/01-rolling-update/
    
    # 1. Deploy Version 1
    kubectl apply -f deployment-v1.yaml
    kubectl apply -f service.yaml
    kubectl rollout status deployment/app-rolling
    
    # 2. Trigger Rolling Update to Version 2
    kubectl apply -f deployment-v2.yaml
    
    # 3. Track rollout progress
    kubectl rollout status deployment/app-rolling
    kubectl get pods -l app=app-rolling --show-labels
    
    # 4. Check rollout history
    kubectl rollout history deployment/app-rolling
    
    # 5. Execute Rollback to previous revision
    kubectl rollout undo deployment/app-rolling
    kubectl rollout status deployment/app-rolling
    
    # Cleanup
    kubectl delete -f service.yaml -f deployment-v1.yaml
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `08-rolling-update-and-rollback.png`
    - **Content:** Terminal showing `kubectl rollout status` for the update to v2, followed by `kubectl rollout history` and `kubectl rollout undo`.

---

### Task 9: Real-World Troubleshooting Scenarios Lab (`troubleshooting/`)

- **Description:** Resolve an in-flight rollout failure caused by an unresolvable image tag, and debug an API server rejection caused by an immutable selector label mismatch.
- **Commands to Run:**
    
    #### Drill 1: Broken Image Rollout Failure
    
    ```bash
    cd session10-k8s-core-objects/troubleshooting/
    
    # Trigger broken deployment rollout
    kubectl apply -f broken-image.yaml
    
    # Notice rollout stalls because new pod cannot pull image
    kubectl rollout status deployment/yatri-backend --timeout=30s
    kubectl get pods -l app=yatri-backend
    
    # Recover by undoing the broken revision
    kubectl rollout undo deployment/yatri-backend
    kubectl delete -f broken-image.yaml
    ```
    
    #### Drill 2: Immutable Selector Mismatch Rejection
    
    ```bash
    # Attempt to apply invalid selector manifest
    kubectl apply -f selector-mismatch.yaml
    # Expected Error: The Deployment "selector-error-demo" is invalid:
    # spec.template.metadata.labels: Invalid value: ... doesn't match selector
    ```
    
    *Fix:* Edit `selector-mismatch.yaml` so `spec.template.metadata.labels.app` matches `spec.selector.matchLabels.app`, then re-apply successfully.
    
- **Screenshot to Attach:**
    - **Filename:** `09-troubleshooting-drills.png`
    - **Content:** Terminal displaying `ImagePullBackOff` during rollout stall + the API Server `Invalid value` error for `selector-mismatch.yaml`.

---

### Task 10: Theoretical & Architectural Conceptual Writeup

- **Description:** Provide technical writeups addressing core Kubernetes architectural interview questions directly in your `README.md`.
- **Key Deliverables to Include in `README.md`:**
    1. **The 4 Ports Clarified:**
        - `containerPort`: Port opened inside the application container process (informational in PodSpec).
        - `targetPort`: Port on the backend pod where the Kubernetes Service routes incoming traffic.
        - `port`: Port exposed internally by the Kubernetes Service (ClusterIP).
        - `nodePort`: Static high port (`30000–32767`) exposed across every worker node's external IP.
    2. **Labels vs. Selectors:**
        - *Labels*: Key-value pairs attached to objects (e.g., `app: nginx`, `env: prod`) for metadata identification.
        - *Selectors*: Query filters used by controllers (Deployments, Services) to group and route to matching labelled pods.
    3. **The 4 Deployment Strategies:**
        - *RollingUpdate*: Progressively replaces old pods with new pods; zero downtime.
        - *Recreate*: Kills all v1 pods before starting any v2 pods; causes brief downtime, but avoids version conflicts.
        - *Blue-Green*: Deploys two complete environments (Blue=Live, Green=New); cutover and rollback happen instantly via service selector flip. Requires 2x compute capacity.
        - *Canary*: Deploys a small fraction of v2 pods (e.g., 10%) alongside v1 stable pods to validate real-world production metrics prior to full rollout.
    4. **`maxSurge` vs. `maxUnavailable` Math:**
        - For `replicas: 4`, `maxSurge: 1`, `maxUnavailable: 0`:
            - Max allowed pods during rollout: $4 + 1 = 5$.
            - Min available pods: $4 - 0 = 4$ (Guarantees 100% service capacity throughout rollout).
    5. **Resource Requests vs. Limits & Units:**
        - *Requests*: Guaranteed minimum CPU/memory allocated by the scheduler to place the pod on a node.
        - *Limits*: Maximum ceiling enforced by Linux cgroups. CPU throttling occurs if CPU limit is exceeded; container is OOM-killed if memory limit is exceeded.
        - *Units*: 1 GB = $10^9$ bytes (decimal, SI); 1 GiB = $2^{30}$ bytes = $1,073,741,824$ bytes (binary, IEC). Kubernetes uses mebibytes (`Mi`) and gibibytes (`Gi`).

---

### Task 11: Blue-Green Deployment Execution & Instant Selector Cutover

- **Description:** Deploy the Blue and Green deployments side-by-side. Validate that traffic is initially 100% Blue, flip the Service label selector to point to Green, observe the instantaneous change in `Endpoints`, and execute an immediate rollback.
- **Directory Reference:** `session10-k8s-core-objects/02-blue-green/`
- **Commands to Run:**
    
    ```bash
    cd session10-k8s-core-objects/02-blue-green/
    
    # 1. Deploy both environments side-by-side (6 pods total)
    kubectl apply -f deployment-blue.yaml
    kubectl apply -f deployment-green.yaml
    
    # 2. Verify both Blue and Green pods are Running
    kubectl get pods -l app=myapp --show-labels
    
    # 3. Route live traffic to Blue (v1)
    kubectl apply -f service-blue.yaml
    kubectl describe svc myapp-service | grep Selector
    kubectl get endpoints myapp-service
    
    # 4. Test live traffic — verify Blue responds
    curl -s <http://localhost:30020> | grep "ENVIRONMENT"
    # (On Minikube use: curl -s <http://$>(minikube ip):30020 | grep "ENVIRONMENT")
    
    # 5. THE SWITCH: Flip traffic to Green (v2) instantly
    kubectl apply -f service-green.yaml
    
    # 6. Verify selector and endpoints updated immediately to Green pods
    kubectl describe svc myapp-service | grep Selector
    kubectl get endpoints myapp-service
    
    # 7. Test live traffic — verify Green now responds
    curl -s <http://localhost:30020> | grep "ENVIRONMENT"
    
    # 8. Instant Rollback: Flip selector back to Blue
    kubectl apply -f service-blue.yaml
    curl -s <http://localhost:30020> | grep "ENVIRONMENT"
    
    # Cleanup
    kubectl delete -f service-blue.yaml -f deployment-blue.yaml -f deployment-green.yaml
    ```
    
- **Expected Terminal Output:**
    
    ```
    # Before switch:
    Selector:   app=myapp,slot=blue
    <p>BLUE ENVIRONMENT</p>
    
    # After switch:
    service/myapp-service configured
    Selector:   app=myapp,slot=green
    <p>GREEN ENVIRONMENT</p>
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `11-blue-green-cutover.png`
    - **Content:** Terminal showing the initial Blue curl response, `kubectl apply -f service-green.yaml`, the updated `kubectl describe svc myapp-service` showing `slot=green`, and the subsequent Green curl response.

---

### Task 12: Canary Deployment Execution & Pod-Ratio Traffic Splitting

- **Description:** Deploy a 9-replica stable deployment and a 1-replica canary deployment under the same Service. Run a curl loop to capture the approximate 10% canary traffic ratio, scale the canary to increase traffic share, and execute a rollback by scaling the canary to zero.
- **Directory Reference:** `session10-k8s-core-objects/03-canary/`
- **Commands to Run:**
    
    ```bash
    cd session10-k8s-core-objects/03-canary/
    
    # 1. Deploy Stable baseline (9 pods = 90%) and Service
    kubectl apply -f deployment-stable.yaml
    kubectl apply -f service.yaml
    kubectl rollout status deployment/app-stable
    
    # 2. Deploy Canary release (1 pod = 10%)
    kubectl apply -f deployment-canary.yaml
    kubectl rollout status deployment/app-canary
    
    # 3. Verify total pool has 10 pods (9 stable + 1 canary)
    kubectl get pods -l app=myapp-canary --show-labels
    
    # 4. Verify the Service endpoints list contains all 10 pod IPs
    kubectl get endpoints myapp-canary-service
    
    # 5. Run traffic test loop (20 requests) to verify ~10% canary hits
    for i in $(seq 1 20); do curl -s <http://localhost:30030> | grep -o "STABLE v1\|CANARY v2"; done
    # (On Minikube use: curl -s <http://$>(minikube ip):30030 | grep -o "STABLE v1\|CANARY v2")
    
    # 6. Increase Canary traffic to 30% (scale canary to 3, stable to 7)
    kubectl scale deployment app-canary --replicas=3
    kubectl scale deployment app-stable --replicas=7
    kubectl get endpoints myapp-canary-service
    
    # 7. Rollback: Abort canary release by scaling canary to 0
    kubectl scale deployment app-canary --replicas=0
    kubectl scale deployment app-stable --replicas=9
    
    # Verify 100% of traffic is returned to stable
    for i in $(seq 1 5); do curl -s <http://localhost:30030> | grep -o "STABLE v1\|CANARY v2"; done
    
    # Cleanup
    kubectl delete -f service.yaml -f deployment-canary.yaml -f deployment-stable.yaml
    ```
    
- **Expected Terminal Output:**
    
    ```
    STABLE v1
    STABLE v1
    STABLE v1
    CANARY v2    <-- Canary absorbs ~10% of total incoming requests
    STABLE v1
    STABLE v1
    STABLE v1
    STABLE v1
    STABLE v1
    STABLE v1
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `12-canary-traffic-split.png`
    - **Content:** Terminal output of the curl loop showing both `STABLE v1` and `CANARY v2` responses, alongside `kubectl get pods -l app=myapp-canary` displaying 9 stable and 1 canary pod.

---

### Task 13: Recreate Deployment Execution & Downtime Outage Demonstration

- **Description:** Deploy an application with `strategy.type: Recreate`. Stream live requests during an update to observe and capture the intentional downtime window where 0 pods exist between v1 termination and v2 creation.
- **Directory Reference:** `session10-k8s-core-objects/04-recreate/`
- **Commands to Run:**
    
    ```bash
    cd session10-k8s-core-objects/04-recreate/
    
    # 1. Deploy Version 1 and NodePort Service
    kubectl apply -f deployment-v1.yaml
    kubectl apply -f service.yaml
    kubectl rollout status deployment/app-recreate
    
    # 2. Verify 3 v1 pods are running
    kubectl get pods -l app=app-recreate
    
    # 3. Open Terminal 1 to watch pod state changes in real time
    kubectl get pods -l app=app-recreate -w
    
    # 4. Open Terminal 2 and start a continuous curl polling loop
    while true; do curl -s --connect-timeout 1 <http://localhost:30040> | grep -o 'VERSION: [^<]*' || echo "[OUTAGE] Connection refused / 0 pods alive"; sleep 0.5; done
    # (On Minikube use port 30040 with $(minikube ip))
    
    # 5. In Terminal 3: Trigger the Recreate update to v2
    kubectl apply -f deployment-v2.yaml
    
    # 6. Observe the curl loop output in Terminal 2 switch from v1 -> [OUTAGE] -> v2
    
    # 7. Check rollout history and test rollback
    kubectl rollout history deployment/app-recreate
    kubectl rollout undo deployment/app-recreate
    kubectl rollout status deployment/app-recreate
    
    # Cleanup
    kubectl delete -f service.yaml -f deployment-v2.yaml
    ```
    
- **Expected Terminal Output:**
    
    ```
    VERSION: v1
    VERSION: v1
    [OUTAGE] Connection refused / 0 pods alive
    [OUTAGE] Connection refused / 0 pods alive
    [OUTAGE] Connection refused / 0 pods alive
    VERSION: v2 (UPGRADED)
    VERSION: v2 (UPGRADED)
    ```
    
- **Screenshot to Attach:**
    - **Filename:** `13-recreate-downtime-outage.png`
    - **Content:** Terminal showing the continuous curl loop output displaying `VERSION: v1`, the consecutive `[OUTAGE]` failures, and the recovery to `VERSION: v2 (UPGRADED)`.

---

# Lecture 11

> Ye sare tasks mam ne Lec 12, Lec 13 me diye the.
> 

# SECTION 1: Chronological Task Overview

- **Task 1: Kubernetes Port Architecture & Clarification Drill**
    - Demystify and document the precise boundaries, scope, and routing path of the 4 Kubernetes ports: `containerPort`, `targetPort`, `port`, and `nodePort`.
- **Task 2: Type 1 Service — ClusterIP (Default Internal Networking)**
    - Deploy an internal microservice backend, configure a standard `ClusterIP` Service, verify `Endpoints`/`EndpointSlices`, and test internal access via a client pod using service name, virtual IP, and FQDN.
- **Task 3: Type 2 Service — NodePort (Host-Level External Ingress)**
    - Deploy a web application exposed on a high node port (`30000–32767`), verify cluster-wide node port binding, and access the application externally via Node IP and browser port-forwarding.
- **Task 4: Type 3 Service — LoadBalancer (Cloud-Native Ingress Simulation)**
    - Deploy an externally facing service using `type: LoadBalancer`, simulate cloud controller IP allocation using `minikube tunnel`, verify automatic creation of underlying `NodePort` and `ClusterIP`, and test public access.
- **Task 5: Type 4 Service — ExternalName (CoreDNS CNAME Alias Redirection)**
    - Create an `ExternalName` service pointing to an external domain (e.g., `api.github.com` or an external database FQDN) without selectors or endpoints, and prove CNAME redirection inside a test pod via `nslookup`.
- **Task 6: Type 5 Service — Headless Service (`clusterIP: None` & Stateful Workloads)**
    - Deploy a Headless Service paired with a `StatefulSet`, demonstrate that CoreDNS returns individual Pod IPs (multiple `A` records) instead of a single virtual IP, and test direct ordinal pod addressing (`<pod-name>.<service-name>`).
- **Task 7: Services Without Selectors (Manual Endpoints Mapping)**
    - Create a custom `ClusterIP` service without a label selector, manually construct a matching `Endpoints` object pointing to an external IP, and demonstrate routing cluster traffic to external infrastructure.
- **Task 8: FQDN & CoreDNS Deep Dive Architecture Analysis**
    - Investigate the Kubernetes FQDN hierarchical structure (`<service>.<namespace>.svc.cluster.local`), inspect container `/etc/resolv.conf` settings (`nameserver`, `search` suffixes, and `ndots:5`), and document the latency implications of `ndots:5`.
- **Task 9: Pod Identity & Lifecycle Invariance Drill — Deployment (Stateless) vs. StatefulSet (Stateful)**
    - Deploy a stateless Deployment alongside a stateful StatefulSet. Observe their distinct pod naming schemes (random replica-hash suffixes vs. deterministic ordinal indices `0, 1, 2`). Imperatively kill an active pod in each workload to prove that Deployments generate a brand-new random identity while StatefulSets guarantee invariant ordinal recreation (`web-stateful-0`).
- **Task 10: Master Architectural Matrix — Deployment vs. StatefulSet vs. DaemonSet**
    - Formulate an exhaustive architectural comparison across the three primary Kubernetes workload controllers (Deployments, StatefulSets, and DaemonSets) covering identity persistence, startup/shutdown sequencing, storage volume binding (`volumeClaimTemplates`), associated service types, and real-world production placement.
- **Task 11: Production Cost Optimization & Service Selection Decision Tree**
    - Synthesize an end-to-end Service Selection Decision Tree. Analyze the enterprise cloud anti-pattern of provisioning multiple `type: LoadBalancer` services ($18–$25/month per LB) and contrast it with the production-grade Ingress pattern that multiplexes hundreds of internal `ClusterIP` microservices behind a single unified Cloud Load Balancer.
- **Task 12: Minikube Docker-Driver Port Binding & Tunnel Gotcha Analysis**
    - Investigate and document the root cause of why `<Node-IP>:<NodePort>` fails on macOS, Windows, and Linux when using the Minikube Docker driver (isolated container network bridge). Demonstrate the two standard operational workarounds: `minikube service <svc> --url` and the Layer 3 routing proxy `minikube tunnel`.

---

# SECTION 2: Detailed Workflow, Commands & Screenshot Checklist

---

### Task 1: Kubernetes Port Architecture & Clarification Drill

- **Short Description:** Document and visually map the 4 distinct port definitions in Kubernetes. Illustrate how a packet flows from an external client through the node, into the service, and down to the application process inside the container.
- **Manifest Reference:** Concept mapping across all `service.yaml` and `app-deployment.yaml` files.
- **Key Commands to Run:**
    
    ```bash
    # Inspect port declarations across pod and service
    kubectl explain pod.spec.containers.ports.containerPort
    kubectl explain service.spec.ports
    ```
    
- **Architecture Flowchart to Document:**
    
    ```
    Client Browser ──► [nodePort: 30080] (Host IP)
                            │
                            ▼
                       [port: 8080] (Service VIP)
                            │
                            ▼
                       [targetPort: 80] (Pod Network)
                            │
                            ▼
                       [containerPort: 80] (Container Engine / Nginx)
    ```
    
- **📸 Screenshot to Attach:**
    - **Screenshot 1.1:** Terminal output or diagram showing the 4 ports documented with arrows connecting `nodePort` -> `port` -> `targetPort` -> `containerPort`.

---

### Task 2: Type 1 Service — ClusterIP (Default Internal Networking)

- **Short Description:** Deploy a 3-replica backend (`web-app-clusterip`), create a `ClusterIP` service on port `8080` targeting container port `80`, inspect automatic endpoint binding, and test connectivity from an ephemeral client pod using short names and full FQDN.
- **Working Directory:** `session-11-kubernetes-services/01-clusterip/`
- **Commands to Run:**
    
    ```bash
    # 1. Deploy backend app and ClusterIP service
    kubectl apply -f 01-clusterip/app-deployment.yaml
    kubectl apply -f 01-clusterip/service.yaml
    
    # 2. Verify pods, service, and endpoints
    kubectl get pods -l app=web-clusterip -o wide
    kubectl get svc web-service-clusterip
    kubectl get endpoints web-service-clusterip
    
    # 3. Deploy diagnostic client pod
    kubectl apply -f 01-clusterip/client-pod.yaml
    kubectl wait --for=condition=ready pod/curl-client --timeout=60s
    
    # 4. Test internal resolution methods from inside the cluster
    kubectl exec -it curl-client -- curl -s <http://web-service-clusterip:8080> | grep -i "<title>"
    kubectl exec -it curl-client -- curl -s <http://web-service-clusterip.default.svc.cluster.local:8080> | grep -i "<title>"
    ```
    
- **📸 Screenshots to Attach:**
    - **Screenshot 2.1:** Terminal output of `kubectl get svc,endpoints web-service-clusterip` showing the allocated Virtual IP and all 3 healthy Pod IPs bound to endpoints.
    - **Screenshot 2.2:** Output of the `kubectl exec` curl command successfully returning `<title>Welcome to nginx!</title>` via service name and FQDN.

---

### Task 3: Type 2 Service — NodePort (Host-Level External Ingress)

- **Short Description:** Deploy a 2-replica Nginx app and expose it externally by opening port `30080` on every cluster node. Verify that hitting any node IP on port `30080` directs traffic to the underlying pods.
- **Working Directory:** `session-11-kubernetes-services/02-nodeport/`
- **Commands to Run:**
    
    ```bash
    # 1. Deploy application and NodePort service
    kubectl apply -f 02-nodeport/app-deployment.yaml
    kubectl apply -f 02-nodeport/service.yaml
    
    # 2. Verify the NodePort mapping
    kubectl get svc web-service-nodeport
    
    # 3. Retrieve Minikube IP and verify node port access
    MINIKUBE_IP=$(minikube ip)
    curl -I <http://$>{MINIKUBE_IP}:30080
    
    # 4. Alternatively test via minikube service tunnel (macOS/Docker driver)
    minikube service web-service-nodeport --url
    ```
    
- **📸 Screenshots to Attach:**
    - **Screenshot 3.1:** Terminal output of `kubectl get svc web-service-nodeport` highlighting the `80:30080/TCP` port mapping.
    - **Screenshot 3.2:** Browser or `curl -I` response showing `HTTP/1.1 200 OK` from `http://<node-ip>:30080`.

---

### Task 4: Type 3 Service — LoadBalancer (Cloud-Native Ingress Simulation)

- **Short Description:** Deploy a 3-replica workload exposed through `type: LoadBalancer`. Use `minikube tunnel` to simulate a cloud provider assigning an `EXTERNAL-IP`, and confirm that Kubernetes automatically configures internal `NodePort` and `ClusterIP` layers.
- **Working Directory:** `session-11-kubernetes-services/03-loadbalancer/`
- **Commands to Run:**
    
    ```bash
    # 1. Deploy application and LoadBalancer service
    kubectl apply -f 03-loadbalancer/app-deployment.yaml
    kubectl apply -f 03-loadbalancer/service.yaml
    
    # 2. Check service status (will initially show <pending> without tunnel)
    kubectl get svc web-service-loadbalancer
    
    # 3. In a separate terminal, start the Minikube LoadBalancer tunnel
    minikube tunnel
    
    # 4. In primary terminal, observe EXTERNAL-IP populated
    kubectl get svc web-service-loadbalancer
    
    # 5. Access the application directly on standard port 80
    EXTERNAL_IP=$(kubectl get svc web-service-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    curl -s <http://$>{EXTERNAL_IP}:80 | grep -i "<title>"
    ```
    
- **📸 Screenshots to Attach:**
    - **Screenshot 4.1:** Terminal showing `kubectl get svc web-service-loadbalancer` with a populated external IP (e.g., `127.0.0.1` or `10.96.x.x`).
    - **Screenshot 4.2:** Browser loading the Nginx welcome page directly at `http://localhost` or `http://<external-ip>` without any high port number.

---

### Task 5: Type 4 Service — ExternalName (CoreDNS CNAME Alias Redirection)

- **Short Description:** Create an `ExternalName` service that acts as an internal DNS CNAME alias pointing to an external domain (e.g., `api.github.com`). Verify that no cluster IP or endpoints are created, and confirm CNAME resolution using `nslookup`.
- **Working Directory:** `session-11-kubernetes-services/04-externalname/`
- **Commands to Run:**
    
    ```bash
    # 1. Apply ExternalName service and client pod
    kubectl apply -f 04-externalname/service.yaml
    kubectl apply -f 04-externalname/client-pod.yaml
    kubectl wait --for=condition=ready pod/dns-test-client --timeout=60s
    
    # 2. Inspect the service (Notice CLUSTER-IP is <none>, EXTERNAL-IP is the target domain)
    kubectl get svc external-database-service
    
    # 3. Verify DNS resolution returns canonical name (CNAME)
    kubectl exec -it dns-test-client -- nslookup external-database-service
    
    # 4. Test outbound traffic through the alias
    kubectl exec -it dns-test-client -- curl -s -k <https://external-database-service>
    ```
    
- **📸 Screenshots to Attach:**
    - **Screenshot 5.1:** Terminal output of `kubectl get svc external-database-service` showing `TYPE: ExternalName` and `CLUSTER-IP: <none>`.
    - **Screenshot 5.2:** Output of `nslookup external-database-service` showing `canonical name = <external-domain>` and the resolved IP addresses.

---

### Task 6: Type 5 Service — Headless Service (`clusterIP: None` & Stateful Workloads)

- **Short Description:** Deploy a 3-replica `StatefulSet` with a Headless Service (`clusterIP: None`). Prove that CoreDNS returns individual `A` records for all matching Pod IPs directly rather than a single VIP, and curl an ordinal pod hostname directly.
- **Working Directory:** `session-11-kubernetes-services/05-headless/`
- **Commands to Run:**
    
    ```bash
    # 1. Apply Headless service and StatefulSet
    kubectl apply -f 05-headless/service.yaml
    kubectl apply -f 05-headless/app-statefulset.yaml
    kubectl apply -f 05-headless/client-pod.yaml
    
    # 2. Wait for stateful pods (web-stateful-0, 1, 2) to become Ready
    kubectl rollout status statefulset/web-stateful --timeout=120s
    kubectl get pods -l app=web-headless -o wide
    
    # 3. Inspect Service (Notice CLUSTER-IP is explicitly None)
    kubectl get svc web-service-headless
    
    # 4. Perform DNS lookup on Headless Service name -> Returns ALL pod IPs
    kubectl exec -it headless-dns-client -- nslookup web-service-headless
    
    # 5. Query an individual Pod directly via its stable FQDN
    kubectl exec -it headless-dns-client -- nslookup web-stateful-0.web-service-headless.default.svc.cluster.local
    kubectl exec -it headless-dns-client -- curl -s <http://web-stateful-0.web-service-headless:80> | grep -i "<title>"
    ```
    
- **📸 Screenshots to Attach:**
    - **Screenshot 6.1:** Terminal output of `nslookup web-service-headless` displaying 3 separate `A` record IPs for the 3 stateful pods.
    - **Screenshot 6.2:** Successful curl output against the predictable hostname `web-stateful-0.web-service-headless`.

---

### Task 7: Services Without Selectors (Manual Endpoints Mapping)

- **Short Description:** Define a Service without selectors (`empty-endpoints.yaml` pattern) and manually bind it to an external backend IP address using a separate `Endpoints` manifest. Demonstrate how Kubernetes abstracts legacy or external infrastructure.
- **Commands to Run:**
    
    ```bash
    # 1. Create Service without a selector
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Service
    metadata:
      name: external-legacy-db
    spec:
      ports:
        - protocol: TCP
          port: 3306
          targetPort: 3306
    EOF
    
    # 2. Verify endpoints are initially empty (<none>)
    kubectl get endpoints external-legacy-db
    
    # 3. Manually create matching Endpoints object pointing to external IP
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Endpoints
    metadata:
      name: external-legacy-db
    subsets:
      - addresses:
          - ip: 192.168.1.150
        ports:
          - port: 3306
    EOF
    
    # 4. Verify endpoints are now successfully attached
    kubectl get endpoints external-legacy-db
    ```
    
- **📸 Screenshots to Attach:**
    - **Screenshot 7.1:** `kubectl get endpoints external-legacy-db` showing `<none>`.
    - **Screenshot 7.2:** `kubectl get endpoints external-legacy-db` showing `192.168.1.150:3306` bound after manual apply.

---

### Task 8: FQDN & CoreDNS Deep Dive Architecture Analysis

- **Short Description:** Inspect the cluster DNS configuration inside running pods. Break down the anatomy of a Kubernetes FQDN, examine `/etc/resolv.conf`, test search domain completion, and explain why `ndots:5` causes latency in production when making external API calls.
- **Commands to Run:**
    
    ```bash
    # 1. Verify CoreDNS pods are active in kube-system
    kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide
    
    # 2. Inspect /etc/resolv.conf inside any running pod
    kubectl exec -it curl-client -- cat /etc/resolv.conf
    
    # 3. Test DNS search domain expansion
    # Querying 'web-service-clusterip' automatically expands to:
    # 'web-service-clusterip.default.svc.cluster.local'
    kubectl exec -it curl-client -- nslookup web-service-clusterip
    
    # 4. Demonstrate ndots:5 external query latency mechanism
    # Queries to an external domain (e.g., api.stripe.com) will traverse local search paths first
    kubectl exec -it curl-client -- nslookup api.github.com
    ```
    
- **📸 Screenshots to Attach:**
    - **Screenshot 8.1:** Terminal displaying the output of `cat /etc/resolv.conf` showing `nameserver`, `search`, and `options ndots:5`.
    - **Screenshot 8.2:** Successful resolution of both short service name and full FQDN pointing to the CoreDNS server IP (`10.96.0.10`).

---

### Task 9: Pod Identity & Lifecycle Invariance Drill — Deployment (Stateless) vs. StatefulSet (Stateful)

- **Short Description:** Deploy both a stateless Deployment and an ordinal StatefulSet. Inspect their naming schemes, delete a running pod from each controller using `kubectl delete pod`, and observe that the Deployment spawns an ephemeral pod with a completely new random hash, whereas the StatefulSet strictly resurrects the exact same ordinal index (`web-stateful-0`).
- **Manifest Reference:**
    - Deployment: `session-11-kubernetes-services/01-clusterip/app-deployment.yaml`
    - StatefulSet: `session-11-kubernetes-services/05-headless/app-statefulset.yaml`
    - Service: `session-11-kubernetes-services/05-headless/service.yaml`
- **Commands to Run:**
    
    ```bash
    # 1. Apply both workloads
    kubectl apply -f session-11-kubernetes-services/01-clusterip/app-deployment.yaml
    kubectl apply -f session-11-kubernetes-services/05-headless/service.yaml
    kubectl apply -f session-11-kubernetes-services/05-headless/app-statefulset.yaml
    
    # 2. Wait for pods to become Ready and observe the naming conventions
    kubectl get pods -l app=web-clusterip
    kubectl get pods -l app=web-headless
    
    # 3. Capture the exact pod names before deletion
    DEPLOY_POD=$(kubectl get pods -l app=web-clusterip -o jsonpath='{.items[0].metadata.name}')
    echo "Deleting Stateless Deployment Pod: ${DEPLOY_POD}"
    kubectl delete pod "${DEPLOY_POD}"
    
    # 4. Check the Deployment pods immediately — notice a brand-new random hash is generated!
    kubectl get pods -l app=web-clusterip
    
    # 5. Delete an ordinal StatefulSet pod (web-stateful-0)
    echo "Deleting StatefulSet Pod: web-stateful-0"
    kubectl delete pod web-stateful-0
    
    # 6. Check the StatefulSet pods immediately — notice web-stateful-0 is recreated identically!
    kubectl get pods -l app=web-headless
    ```
    
- **Expected Behavioral Comparison:**
    - **Stateless Pod Deleted:** `web-app-clusterip-6c679b9456-4d9vz` ──► Replaced by: `web-app-clusterip-6c679b9456-x8k2m` *(New random identity)*
    - **Stateful Pod Deleted:** `web-stateful-0` ──► Replaced by: `web-stateful-0` *(Deterministic, invariant identity)*
- **📸 Screenshots to Attach:**
    - **Screenshot 9.1:** Terminal output showing the initial list of pods with the Deployment's random hashes (`6c679b9456-4d9vz`) contrasted against the StatefulSet's ordinals (`web-stateful-0`, `web-stateful-1`, `web-stateful-2`).
    - **Screenshot 9.2:** Terminal output after pod deletion demonstrating that the Deployment created a new hash while the StatefulSet recreated the identical ordinal `web-stateful-0`.

---

### Task 10: Master Architectural Matrix — Deployment vs. StatefulSet vs. DaemonSet

- **Short Description:** Create an engineering reference matrix evaluating the differences between Deployments, StatefulSets, and DaemonSets. Document their scheduling paradigms, storage lifetimes, identity models, network coupling, and failure domains.
- **Manifests Inspected:**
    - `session10-k8s-core-objects/deployment/deployment-v1.yaml`
    - `session10-k8s-core-objects/daemonset/node-agent-ds.yaml`
    - `session10-k8s-core-objects/k8s-core-objects/statefulset.yml`
- **Commands to Run:**
    
    ```bash
    # Inspect resource definitions and schema specifications
    kubectl explain deployment.spec
    kubectl explain statefulset.spec
    kubectl explain daemonset.spec
    ```
    
- **Engineering Matrix to Document in Submission:**

| Architectural Metric | Deployment | StatefulSet | DaemonSet |
| --- | --- | --- | --- |
| **Primary Workload Type** | Stateless microservices, Web APIs | Clustered databases, Distributed queues | Node-level infrastructure agents |
| **Pod Naming Scheme** | Random hash (`<deploy>-<rs-hash>-<random>`) | Deterministic ordinal (`<name>-0, 1, 2`) | Deterministic node hash (`<ds>-<random>`) |
| **Pod Identity Persistence** | Ephemeral (disposable upon death) | Invariant (identity, IP, hostname stick) | Bound to individual worker node |
| **Startup / Shutdown Order** | Non-ordered, parallel | Strictly sequential (`0 -> 1 -> 2`, reversed on termination) | Parallel across all eligible nodes |
| **Storage Mechanism** | Shared volume or ephemeral emptyDir | Dedicated PersistentVolume per ordinal via `volumeClaimTemplates` | HostPath mounts or node-local storage |
| **Associated Service Type** | Standard `ClusterIP` / `NodePort` / `LoadBalancer` | **Headless Service** (`clusterIP: None`) mandatory for discovery | None or local `ClusterIP` |
| **Scaling Behavior** | Scales arbitrarily across healthy nodes | Scales ordinally (adds/removes at the tail) | Scales automatically when nodes join/leave |
| **Production Examples** | Nginx, Python Flask, Node.js API, Go services | Kafka, MongoDB, Cassandra, PostgreSQL, ZooKeeper | Fluentd, Prometheus Node Exporter, Cilium, Falco |
- **📸 Screenshot to Attach:**
    - **Screenshot 10.1:** Cleanly formatted Markdown table of the Architectural Matrix in your README, or a screenshot of `kubectl get deploy,sts,ds` running simultaneously in your cluster.

---

### Task 11: Production Cost Optimization & Service Selection Decision Tree

- **Short Description:** Document the Kubernetes Service Decision Tree and conduct a cost-optimization analysis. Detail why provisioning 50 `type: LoadBalancer` services creates an enterprise billing anti-pattern in public clouds (AWS/GCP/Azure) and demonstrate how an Ingress Controller eliminates this overhead.
- **Architecture Diagram to Document:**
    
    ```
    ANTI-PATTERN (Expensive: $25/mo per service):
    Microservice A ──► AWS NLB 1 ($25/mo) ──► ClusterIP A
    Microservice B ──► AWS NLB 2 ($25/mo) ──► ClusterIP B
    Microservice C ──► AWS NLB 3 ($25/mo) ──► ClusterIP C
    Total for 50 services = $1,250 / month
    
    BEST PRACTICE (Cost-Optimized: Single Entrypoint):
    Public Internet ──► 1 Unified AWS Load Balancer ($25/mo)
                                │
                                ▼
                     [ NGINX Ingress Controller ]
                     (Layer 7 Host & Path Routing)
                        │            │            │
                        ▼            ▼            ▼
                   ClusterIP A  ClusterIP B  ClusterIP C
    Total for 50 services = $25 / month (Savings: $1,225/mo)
    ```
    
- **Service Selection Logic Tree to Document:**
    
    ```
    Need to expose service outside cluster?
    │
    ├── NO ──► Need direct pod-to-pod discovery (Kafka/DB)?
    │           ├── YES ──► Use HEADLESS SERVICE (clusterIP: None)
    │           └── NO  ──► Use CLUSTERIP (Default)
    │
    └── YES ──► Connecting to an external 3rd-party domain (AWS RDS / Stripe)?
                ├── YES ──► Use EXTERNALNAME
                └── NO  ──► Are you on Public Cloud (AWS/GCP/Azure)?
                             ├── YES (HTTP/HTTPS) ──► Expose 1 INGRESS via LOADBALANCER,
                             │                        apps as internal CLUSTERIP
                             ├── YES (TCP/UDP)    ──► Direct LOADBALANCER
                             └── NO (On-Prem/Dev) ──► NODEPORT
    ```
    
- **📸 Screenshot to Attach:**
    - **Screenshot 11.1:** Rendered Decision Tree flowchart and Cloud Cost Comparison Breakdown table included in the submission documentation.

---

### Task 12: Minikube Docker-Driver Port Binding & Tunnel Gotcha Analysis

- **Short Description:** Analyze and document why running `curl http://<Node-IP>:<NodePort>` fails on macOS and Windows when using Minikube with the Docker driver. Execute and verify the two standard operational solutions: the temporary network forwarder (`minikube service <svc> --url`) and the continuous Layer 3 routing daemon (`minikube tunnel`).
- **Root Cause Explanation to Document:**
    - In standard bare-metal Linux clusters, the worker node IP belongs directly to a physical interface reachable on the local network.
    - When using Minikube on macOS or Windows with the Docker driver (`-driver=docker`), Minikube runs inside an **isolated Docker container**. The node IP (e.g., `192.168.49.2`) belongs to an internal Docker network bridge (`docker0`/`bridge`) that macOS/Windows host kernels cannot directly route to without specialized proxying.
- **Commands to Run & Verify Workarounds:**
    
    ```bash
    # 1. Re-verify the NodePort service is active
    kubectl get svc web-service-nodeport
    
    # 2. Attempt direct curl on Node IP (Demonstrating the failure)
    NODE_IP=$(minikube ip)
    echo "Testing direct connection to ${NODE_IP}:30080 (Expect timeout/failure on macOS Docker driver)..."
    curl --connect-timeout 2 -s <http://$>{NODE_IP}:30080 || echo "Connection Failed as expected!"
    
    # -------------------------------------------------------------
    # WORKAROUND 1: Dynamic Local Proxy via Minikube Service
    # -------------------------------------------------------------
    # Minikube binds an open loopback port on 127.0.0.1 directly into the Docker bridge
    minikube service web-service-nodeport --url
    
    # Test the output URL provided by minikube service (e.g., <http://127.0.0.1:51234>)
    # curl -I <http://127.0.0.1>:<generated-port>
    
    # -------------------------------------------------------------
    # WORKAROUND 2: Continuous L3 Route Tunnel (Production Simulation)
    # -------------------------------------------------------------
    # In a separate terminal window, launch minikube tunnel (requires sudo for host network routing tables):
    minikube tunnel
    
    # In your primary terminal, test direct localhost access on the mapped port:
    curl -I <http://localhost:30080>
    ```
    
- **📸 Screenshots to Attach:**
    - **Screenshot 12.1:** Terminal output showing the failed direct connection to `http://$(minikube ip):30080` alongside the explanation of Docker bridge network isolation on macOS/Windows.
    - **Screenshot 12.2:** Output of `minikube service web-service-nodeport --url` showing the dynamically mapped `127.0.0.1` address successfully returning an `HTTP/1.1 200 OK` response.

---

# Lecture 12

> Mam gave these tasks in Lec 14
> 

# SECTION 1: All Tasks

- **Task 1: Non-Sensitive Configuration Decoupling via ConfigMaps**
    - Create a declarative `ConfigMap` storing application runtime configuration (e.g., `ENVIRONMENT`, `LOG_LEVEL`, port, currency), verify its stored keys with `kubectl describe configmap`, and query individual keys imperatively using JSONPath (`o jsonpath='{.data.<KEY>}'`).
- **Task 2: ConfigMap Live Update & Pod Immobility Verification Drill**
    - Dynamically patch an active `ConfigMap` (`kubectl patch configmap`), inspect the running container environment via `kubectl exec` to prove that existing pod environment variables do not automatically update, and execute a zero-downtime rolling restart (`kubectl rollout restart deployment`) to load the updated values.
- **Task 3: Sensitive Data Isolation via Kubernetes Secrets & Base64 Mechanics**
    - Construct an `Opaque` Kubernetes `Secret` storing database credentials, understand that Base64 represents encoding rather than encryption, and imperatively retrieve and decode masked credentials using JSONPath piped to `base64 --decode`.
- **Task 4: The Trailing Newline Secret Gotcha & Authentication Failure Analysis**
    - Investigate the critical Base64 encoding bug where standard `echo` appends an invisible trailing newline (`\n` / `0x0A`), causing application authentication rejections. Contrast the output of `echo "password" | base64` against `echo -n "password" | base64` to verify proper binary payload hygiene.
- **Task 5: Enterprise Secret Management & Pipeline Integration Analysis**
    - Research and document the security anti-pattern of hardcoding Base64 secrets in Git/YAML manifests. Detail external secret management integration patterns (AWS Secrets Manager, Azure Key Vault / ADO Variable Groups, HashiCorp Vault) and how secrets are securely referenced in CI/CD pipeline definitions.
- **Task 6: Combined ConfigMap and Secret Pod Injection Architecture**
    - Deploy a multi-tier backend application that concurrently consumes plain-text parameters using bulk environment injection (`envFrom: configMapRef`) and sensitive credentials using granular key mapping (`env.valueFrom.secretKeyRef`), verifying runtime injection via `kubectl exec env`.
- **Task 7: Architectural Comparative Study — Ingress Resource vs. Ingress Controller**
    - Research and document the fundamental architectural boundary between an `Ingress` resource (the declarative Layer 7 routing rules blueprint) and an `Ingress Controller` (the active reverse proxy daemon, e.g., NGINX Ingress Controller, that watches the API and executes traffic routing).
- **Task 8: NGINX Ingress Controller Activation & Lifecycle Verification**
    - Enable the NGINX Ingress Controller addon on Minikube (`minikube addons enable ingress`), inspect the `ingress-nginx` system namespace, and verify readiness using `kubectl wait` targeting the controller pod.
- **Task 9: Local DNS Resolution & System Hosts File Mapping**
    - Configure local workstation DNS resolution by mapping the Minikube cluster IP to custom domain endpoints (`yatri.local`) inside `/etc/hosts` using elevated permissions (`sudo nano /etc/hosts` or `sudo tee -a`), verifying direct resolution via `curl` and browser access.
- **Task 10: Layer 7 Path-Based Routing Implementation**
    - Deploy an `Ingress` resource configuring path-based routing rules under a single host domain (`yatri.local`), directing root traffic (`/`) to a frontend service and API traffic (`/api(/|$)(.*)`) to a backend service with NGINX URL rewriting (`rewrite-target: /$2`).
- **Task 11: Virtual Host-Based Routing (Subdomain Routing)**
    - Implement multi-tenant/subdomain routing within a single Ingress manifest, mapping distinct virtual hostnames (`portal.campus.local` and `api.campus.local`) to separate backend services, and test access across domains sharing the same entry IP.
- **Task 12: Hybrid Ingress Routing Architecture**
    - Construct an advanced Ingress routing configuration that combines both host-based virtual routing and path-based routing within the same resource, validating traffic isolation across multiple domain-path combinations.
- **Task 13: Ingress TLS/HTTPS Termination & Secret Binding**
    - Generate a self-signed SSL/TLS certificate pair using `openssl`, create a `kubernetes.io/tls` secret, bind the secret to an Ingress manifest under the `spec.tls` block, and verify HTTPS termination on port `443` using `curl -k --resolve`.
- **Task 14: End-to-End Multi-Tier Microservice Integration & Automation Scripting**
    - Deploy the end-to-end Session 12 architecture combining ConfigMap, Secret, Frontend Deployment, Backend Deployment, ClusterIP Services, and Ingress routing. Inspect the automated multi-resource deployment workflow (`run-demo.sh` / `cleanup.sh`) and analyze multi-document YAML syntax (`--`) for co-locating Deployments and Services.

---

# SECTION 2: Detailed Workflow, Instructions, Commands & Screenshot Requirements

Navigate to the Session 12 directory in the course repository:

```bash
cd session-12-ingress-configmaps-secrets
```

---

### Task 1: Non-Sensitive Configuration Decoupling via ConfigMaps

- **Short Description:** Decouple environment-specific runtime configurations (log levels, ports, currency settings) from container images by storing them in a declarative `ConfigMap`.
- **Workflow:**
    1. Review `01-configmap/app-config.yaml`.
    2. Apply the manifest to the cluster.
    3. Inspect the stored keys and verify the payload using `describe` and JSONPath queries.
- **Commands to Run:**
    
    ```bash
    kubectl apply -f 01-configmap/app-config.yaml
    kubectl get configmap yatri-app-config
    kubectl describe configmap yatri-app-config
    kubectl get configmap yatri-app-config -o jsonpath='{.data.ENVIRONMENT}' && echo ""
    kubectl get configmap yatri-app-config -o jsonpath='{.data.LOG_LEVEL}' && echo ""
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 1:** Terminal showing `kubectl describe configmap yatri-app-config` displaying all 5 key-value pairs (`ENVIRONMENT`, `LOG_LEVEL`, `PORT`, `DEFAULT_CURRENCY`, `MAX_BOOKING_DAYS`) and the output of the JSONPath query returning `production`.

---

### Task 2: ConfigMap Live Update & Pod Immobility Verification Drill

- **Short Description:** Demonstrate that updating a `ConfigMap` does **not** retroactively update environment variables inside active running containers, and use `kubectl rollout restart` to trigger a zero-downtime rolling update.
- **Workflow:**
    1. Patch the active `yatri-app-config` ConfigMap to change `ENVIRONMENT` from `production` to `staging`.
    2. Query the running pod's environment directly using `kubectl exec` to show that the variable did not change.
    3. Perform a rolling restart on the deployment.
    4. Verify the new pod instances picked up `ENVIRONMENT=staging`.
- **Commands to Run:**
    
    ```bash
    # Step 1: Patch ConfigMap live
    kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"staging"}}'
    
    # Step 2: Check running pod env (assuming backend pod from 04-full-demo is running)
    kubectl exec -it deploy/yatri-backend -- env | grep ENVIRONMENT
    
    # Step 3: Trigger rolling restart
    kubectl rollout restart deployment/yatri-backend
    kubectl rollout status deployment/yatri-backend
    
    # Step 4: Re-check pod env
    kubectl exec -it deploy/yatri-backend -- env | grep ENVIRONMENT
    
    # Step 5: Revert patch for subsequent labs
    kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"production"}}'
    kubectl rollout restart deployment/yatri-backend
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 2:** Split terminal showing the before-and-after check: `ENVIRONMENT=production` in the running pod after patching, the `rollout restart` execution, and `ENVIRONMENT=staging` reflected in the newly created pod.

---

### Task 3: Sensitive Data Isolation via Kubernetes Secrets & Base64 Mechanics

- **Short Description:** Implement credential isolation using an `Opaque` Kubernetes `Secret`, illustrating that Base64 is merely an encoding scheme (not encryption) that can be decoded on the CLI.
- **Workflow:**
    1. Review `02-secret/db-secret.yaml`.
    2. Apply the manifest to store database user and password credentials.
    3. Verify that `kubectl describe secret` masks the values for security.
    4. Imperatively extract and decode the password to confirm the plaintext value.
- **Commands to Run:**
    
    ```bash
    kubectl apply -f 02-secret/db-secret.yaml
    kubectl get secret yatri-db-secret
    kubectl describe secret yatri-db-secret
    kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode && echo ""
    kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_USER}' | base64 --decode && echo ""
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 3:** Terminal output displaying `kubectl describe secret yatri-db-secret` (showing masked byte lengths) followed by the JSONPath pipeline revealing `secretpassword` and `yatri_admin`.

---

### Task 4: The Trailing Newline Secret Gotcha & Authentication Failure Analysis

- **Short Description:** Analyze the common authentication bug where encoding with standard `echo` appends an invisible ASCII newline (`\n` / `0x0A`), corrupting passwords sent to backend databases.
- **Workflow:**
    1. Encode a test string with standard `echo` and inspect its hexadecimal binary representation using `xxd` or `hexdump`.
    2. Encode the test string with `echo -n` to demonstrate suppression of the newline byte.
    3. Decode both strings to document the payload corruption.
- **Commands to Run:**
    
    ```bash
    # Broken pattern: appends 0x0a (\n)
    echo "secretpassword" | xxd
    echo "secretpassword" | base64
    
    # Correct pattern: exact byte stream
    echo -n "secretpassword" | xxd
    echo -n "secretpassword" | base64
    
    # Visual comparison
    echo "Wrong (with newline): $(echo "secretpassword" | base64)"
    echo "Right (no newline):   $(echo -n "secretpassword" | base64)"
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 4:** Terminal showing the output of both `xxd` commands: one showing the trailing `0a` byte with base64 `c2VjcmV0cGFzc3dvcmQK`, and the clean version ending in `c2VjcmV0cGFzc3dvcmQ=`.

---

### Task 5: Enterprise Secret Management & Pipeline Integration Analysis

- **Short Description:** Research and document how real-world enterprise architectures solve Kubernetes secret management securely without committing Base64 strings to source control.
- **Workflow:**
    1. Write an architectural summary in your `README.md` covering:
        - **The Vulnerability:** Why committing `Secret` YAMLs to Git violates DevSecOps (Git history retention, RBAC exposure, lack of rotation).
        - **External Secret Operators:** How **External Secrets Operator (ESO)** or **HashiCorp Vault Agent Injector** synchronizes credentials from AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault into ephemeral Kubernetes secrets.
        - **CI/CD Integration:** How GitHub Actions secrets or Azure DevOps Variable Groups inject secrets dynamically at deploy time without storing them in manifest repositories.
- **Commands / References to Run:**
    
    ```bash
    # Check if any secret operator or CRDs exist in your cluster
    kubectl get crds | grep -i secret || echo "Standard native secrets in use"
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 5:** A clear markdown architecture diagram or formatted documentation section in your `README.md` explaining the flow: `AWS Secrets Manager / Vault -> External Secrets Operator -> Kubernetes Secret -> Pod Volume/Env`.

---

### Task 6: Combined ConfigMap and Secret Pod Injection Architecture

- **Short Description:** Deploy a backend pod that simultaneously consumes configuration from both a `ConfigMap` and a `Secret`, verifying that both sources merge cleanly into the container's environment.
- **Workflow:**
    1. Review `04-full-demo/backend.yaml` to observe `envFrom.configMapRef` and `env.valueFrom.secretKeyRef`.
    2. Deploy the backend application and its corresponding `ClusterIP` Service.
    3. Execute `env` inside the running container to verify the coexistence of both datasets.
- **Commands to Run:**
    
    ```bash
    kubectl apply -f 04-full-demo/configmap.yaml
    kubectl apply -f 04-full-demo/secret.yaml
    kubectl apply -f 04-full-demo/backend.yaml
    kubectl rollout status deployment/yatri-backend
    
    # Verify injection inside pod
    kubectl exec -it deploy/yatri-backend -- env | grep -E "ENVIRONMENT|LOG_LEVEL|POSTGRES|DEFAULT_CURRENCY"
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 6:** Terminal displaying the `kubectl exec` output listing both non-sensitive values (`ENVIRONMENT=production`, `LOG_LEVEL=INFO`) and secret credentials (`POSTGRES_USER=yatri_admin`, `POSTGRES_PASSWORD=secretpassword`).

---

### Task 7: Architectural Comparative Study — Ingress Resource vs. Ingress Controller

- **Short Description:** Provide a conceptual and technical breakdown of the division of responsibilities between an `Ingress` rule manifest and an `Ingress Controller`.
- **Workflow:**
    1. Document the comparison table in your report:
        - **Ingress Resource:** Declarative Kubernetes Layer 7 API specification (contains hostnames, paths, TLS cert references, target service names). Does nothing by itself.
        - **Ingress Controller:** Active reverse proxy pod (NGINX, Traefik, HAProxy, Envoy) that runs a control loop, monitors the API Server for `Ingress` objects, dynamically generates proxy configuration (e.g., `nginx.conf`), and reloads its engine to route real network traffic.
- **Commands to Run:**
    
    ```bash
    # Show that Ingress API exists natively
    kubectl api-resources | grep -i ingress
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 7:** Formatted markdown comparison table and architecture flow diagram documented in your submission file.

---

### Task 8: NGINX Ingress Controller Activation & Lifecycle Verification

- **Short Description:** Enable and verify the NGINX Ingress Controller daemon on Minikube, validating the pod lifecycle within the `ingress-nginx` namespace.
- **Workflow:**
    1. Enable the Minikube Ingress addon.
    2. Observe the creation of the Ingress Controller deployment, pods, and admission webhooks.
    3. Wait until the controller pod reaches a healthy `Running` and `Ready` state.
- **Commands to Run:**
    
    ```bash
    minikube addons enable ingress
    kubectl get pods -n ingress-nginx
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=120s
    kubectl get service -n ingress-nginx
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 8:** Terminal output showing `ingress-nginx-controller` pod in `Running` (1/1) status and the `ingress condition met` success message.

---

### Task 9: Local DNS Resolution & System Hosts File Mapping

- **Short Description:** Configure host-level local DNS name resolution by binding the Minikube VM/Docker IP to the custom domain `yatri.local` in `/etc/hosts`.
- **Workflow:**
    1. Retrieve the Minikube cluster IP address.
    2. Append the hostname mapping to your local workstation's `/etc/hosts` file.
    3. Ping or query the domain locally to confirm resolution.
- **Commands to Run:**
    
    ```bash
    MINIKUBE_IP=$(minikube ip)
    echo "Minikube IP is: ${MINIKUBE_IP}"
    
    # Append to /etc/hosts if not already present
    if ! grep -q "yatri.local" /etc/hosts; then
      echo "${MINIKUBE_IP}  yatri.local" | sudo tee -a /etc/hosts
    fi
    
    # Verify entry
    grep "yatri.local" /etc/hosts
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 9:** Terminal output showing `minikube ip` matching the IP mapped to `yatri.local` inside `/etc/hosts`.

---

### Task 10: Layer 7 Path-Based Routing Implementation

- **Short Description:** Implement path-based Layer 7 traffic routing using an Ingress resource, directing `/` to the frontend Nginx service and `/api/*` to the backend Python API service.
- **Workflow:**
    1. Review `04-full-demo/ingress.yaml` and verify the `rewrite-target: /$2` and regex annotations.
    2. Deploy `frontend.yaml` and apply `ingress.yaml`.
    3. Send HTTP requests to both paths and verify traffic lands on the correct microservice.
- **Commands to Run:**
    
    ```bash
    kubectl apply -f 04-full-demo/frontend.yaml
    kubectl apply -f 04-full-demo/backend.yaml
    kubectl apply -f 04-full-demo/ingress.yaml
    
    kubectl get ingress yatri-ingress
    kubectl describe ingress yatri-ingress
    
    # Test Frontend path (Root /)
    curl -s <http://yatri.local/> | grep -i "<title>"
    
    # Test Backend path (/api/)
    curl -s <http://yatri.local/api/>
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 10:** Terminal showing both curl commands: one returning the `<title>Welcome to nginx!</title>` HTML response and the other returning the Python backend config output (`ENVIRONMENT: production`, `POSTGRES_USER: yatri_admin`).

---

### Task 11: Virtual Host-Based Routing (Subdomain Routing)

- **Short Description:** Deploy an Ingress configuration that routes incoming requests based on virtual hostnames (`portal.campus.local` vs. `api.campus.local`) targeting the same external IP.
- **Workflow:**
    1. Inspect `03-ingress/ingress-tls.yaml` rules section (focusing on the separate `host:` declarations).
    2. Add `portal.campus.local` and `api.campus.local` to `/etc/hosts`.
    3. Use `curl -H "Host: <domain>"` or configure DNS to verify host-isolated routing.
- **Commands to Run:**
    
    ```bash
    MINIKUBE_IP=$(minikube ip)
    echo "${MINIKUBE_IP}  portal.campus.local api.campus.local" | sudo tee -a /etc/hosts
    
    # Verify routing by Host Header
    curl -s -H "Host: portal.campus.local" <http://$>{MINIKUBE_IP}/ | grep -i "<title>"
    curl -s -H "Host: api.campus.local" <http://$>{MINIKUBE_IP}/api/
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 11:** Terminal showing `curl` queries against the two different virtual hosts resolving to their respective services using the same cluster IP.

---

### Task 12: Hybrid Ingress Routing Architecture

- **Short Description:** Construct and validate an Ingress resource that merges both multi-tenant virtual host routing and path-based routing in a single configuration.
- **Workflow:**
    1. Review `03-ingress/ingress-tls.yaml`.
    2. Verify that `portal.campus.local` routes to the frontend on `/` while `api.campus.local` routes to the backend on `/api` and other paths.
    3. Apply and describe the resource to verify the routing table.
- **Commands to Run:**
    
    ```bash
    kubectl apply -f 03-ingress/ingress-tls.yaml
    kubectl get ingress campus-ingress-tls
    kubectl describe ingress campus-ingress-tls
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 12:** The output of `kubectl describe ingress campus-ingress-tls` clearly displaying the routing table with two separate hosts, each with distinct backend paths and services.

---

### Task 13: Ingress TLS/HTTPS Termination & Secret Binding

- **Short Description:** Configure SSL/TLS termination on an Ingress by generating a self-signed certificate, creating a `kubernetes.io/tls` secret, and serving traffic securely over HTTPS port `443`.
- **Workflow:**
    1. Generate an RSA private key and self-signed X.509 certificate using `openssl`.
    2. Create an `Opaque` TLS secret with `kubectl create secret tls`.
    3. Attach the `tls:` block in `ingress-tls.yaml`.
    4. Test secure HTTPS termination using `curl -k` on port 443.
- **Commands to Run:**
    
    ```bash
    # Step 1: Generate TLS Keypair
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout tls.key \
      -out tls.crt \
      -subj "/CN=campus.local/O=CampusDevOps"
    
    # Step 2: Store in Kubernetes Secret
    kubectl create secret tls campus-tls-cert --cert=tls.crt --key=tls.key
    kubectl get secret campus-tls-cert
    
    # Step 3: Apply TLS Ingress
    kubectl apply -f 03-ingress/ingress-tls.yaml
    kubectl get ingress campus-ingress-tls
    
    # Step 4: Verify HTTPS handshake over port 443
    INGRESS_IP=$(minikube ip)
    curl -k -v --resolve portal.campus.local:443:${INGRESS_IP} <https://portal.campus.local/> 2>&1 | grep -E "Server certificate|HTTP/|SSL connection"
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 13:** Terminal output showing `curl -k -v` successfully completing the SSL handshake (`Server certificate: CN=campus.local`), returning `HTTP/2 200` or `HTTP/1.1 200`.

---

### Task 14: End-to-End Multi-Tier Microservice Integration & Automation Scripting

- **Short Description:** Execute the comprehensive full-lifecycle automation scripts (`run-demo.sh` and `cleanup.sh`), analyzing multi-document YAML manifests (`--`) and verifying complete infrastructure cleanup.
- **Workflow:**
    1. Inspect `04-full-demo/backend.yaml` and `04-full-demo/frontend.yaml` to analyze multi-document YAML syntax (`--`) co-locating Deployments and Services.
    2. Run `run-demo.sh` to execute the full automated build.
    3. Validate all components with a single `kubectl get` command.
    4. Run `cleanup.sh` and verify all lab resources are deleted.
- **Commands to Run:**
    
    ```bash
    # Execute full automated deployment
    bash 04-full-demo/run-demo.sh
    
    # Audit entire stack state
    kubectl get configmap,secret,ingress,deploy,svc,pods -l app=yatri-app
    
    # Execute automated teardown
    bash 04-full-demo/cleanup.sh
    
    # Confirm clean state
    kubectl get ingress yatri-ingress || echo "Ingress deleted"
    kubectl get deployment yatri-backend yatri-frontend || echo "Deployments deleted"
    ```
    
- **Screenshot to Attach:**
    - **Screenshot 14:** Terminal output showing the execution of `run-demo.sh` completing with all resources green, followed by `cleanup.sh` showing all resources deleted.

---