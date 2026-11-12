# AGENTS.md — Kubernetes From Zero (multi-step tutorial)

> `CLAUDE.md` is a symlink to this file. Edit **this** file only.

## 1. What this repository is

A **hands-on, multi-step Kubernetes tutorial** written for someone who has **never seen containers,
networking internals, or Kubernetes**. It starts from the bottom (what a process, a container, an IP
address, a port, NAT and DNS are) and ends with a complete, realistic system running on a local
multi-node Kubernetes cluster, exposed through an API gateway, with storage, autoscaling, security
and observability.

The tutorial is **interactive**: it is delivered **one step at a time** by an AI agent (you), and the
learner can stop at any step to ask questions before moving on.

The repository contains three kinds of things:

| Kind | Where | Purpose |
|------|-------|---------|
| Step documents | `docs/NN-<slug>.md` | The full, detailed explanation for each step |
| Application code | `apps/` | The "Bookstore" system we deploy (created in Step 01) |
| Infrastructure | `k8s/`, `cluster/`, `scripts/` | Manifests, kind config, helper scripts (grow step by step) |

`TUTORIAL-INDEX.md` is the **single source of truth for progress**: which steps are done, what was
explained, what questions the learner asked, and what comes next.

## 2. The learner

- Assume **zero prior knowledge** of Kubernetes, containers and networking internals.
- Assume general computer literacy and willingness to type commands in a terminal.
- Explain **why** before **how**. Every new term is defined the first time it appears
  (and added to the glossary in that step's doc).
- Use analogies, then replace them with the precise technical picture.
- Never say "simply" or "just". If it were simple they would not need a tutorial.

## 3. Environment (learner's machine)

- Windows + **WSL2** (Linux kernel 6.x), shell `zsh`.
- **Docker Desktop** (Docker Engine 29.x) with WSL integration.
- Tools already installed: `docker`, `kind` (v0.33), `kubectl` (v1.37), `helm` (v4), `git`.
- ~15 GB RAM, 8 CPUs.
- **No local Go/Python/Node/.NET toolchain is required**: every app is built inside Docker
  (multi-stage Dockerfiles). Don't introduce steps that require installing language runtimes.
- ⚠️ Docker Desktop runs containers inside its own VM: container IPs (and therefore kind node IPs)
  are **not directly reachable** from WSL. Expose things via kind `extraPortMappings` or
  `kubectl port-forward`. Say this explicitly when relevant.
- ⚠️ An **unrelated** kind cluster named `kube-shop` exists on the machine and uses host port
  `8080`. **Never touch, delete or reconfigure it.** Our cluster is named **`k8s-tutorial`**.
  Always pass `--name k8s-tutorial` / use context `kind-k8s-tutorial`.

## 4. The system we build: "Bookstore"

| Component | Tech | Role | K8s concepts it teaches |
|-----------|------|------|-------------------------|
| Edge gateway | **Gateway API + Envoy Gateway** (YAML only) | Cluster entry: TLS termination, HTTP→HTTPS, host/path routing, per-IP rate limiting | North–south traffic, CRDs, controllers, Helm |
| `api-gateway` | **C# / .NET + YARP** | Application API gateway / BFF: OIDC login/logout/callback, server-side sessions in Redis, Bearer JWT validation, revoked-user check, per-route policies, strip + inject `X-User-*` headers, routes `/api/*` | Code-based gateway, Secrets, shared state across replicas (sessions + ASP.NET Data Protection keys in Redis) |
| `keycloak` | Keycloak (official image) | Identity provider: users, roles, login pages, tokens (realm `bookstore` imported from JSON) | Heavy 3rd-party app: probes, resources, ConfigMap-imported config, DB dependency, internal vs external hostname |
| `frontend` | Next.js (React), standalone Node server | Web UI; calls `/api/*` and `/auth/*` same-origin (cookies, no tokens in the browser) | Deployments, Services, build-time vs run-time config |
| `catalog-api` | Go (net/http) | Books (public GET; admin-only POST); Postgres + Redis cache | Config, Secrets, probes, resources, HPA |
| `orders-api` | Python (FastAPI) | Orders for the user in `X-User-Id`; enqueues jobs in Redis | Service-to-service traffic, DNS, header trust → NetworkPolicies |
| `worker` | Python | Consumes order jobs, updates order status | Background workloads, scaling, graceful shutdown |
| `db-migrate` | Python | Creates schema + seed data | Jobs, init containers, ordering |
| `loadgen` | Go | Generates traffic (uses a Bearer token from Keycloak's CLI client) | Autoscaling, behaviour under load |
| `postgres` | Official image | Databases `bookstore` and `keycloak` | StatefulSets, PV/PVC, StorageClass, headless Services |
| `redis` | Official image | Cache, job queue, gateway sessions, revoked-user list | Shared state for stateless replicas |

Traffic shape (final):

```
browser ─► Envoy Gateway (edge, HTTPS) ─┬─ bookstore.localhost  /          ─► frontend
                                        ├─ bookstore.localhost  /api/*     ─► api-gateway ─┬─ /api/catalog ─► catalog-api ─► postgres, redis
                                        │                       /auth/*    ─► api-gateway  └─ /api/orders  ─► orders-api  ─► postgres, redis ◄─ worker
                                        └─ auth.bookstore.localhost        ─► keycloak ─► postgres
api-gateway ─► keycloak (code exchange, JWKS, refresh — in-cluster URL), redis (sessions, revoked list)
```

Design rules (do not change without the learner's agreement):
- **Two gateways, stacked** (agreed with the learner). Envoy Gateway = infrastructure edge, YAML only.
  YARP `api-gateway` = application gateway with all custom auth logic.
- **Keycloak + custom logic inside `api-gateway`**; there is **no** separate `auth-api`.
- **BFF pattern:** tokens never reach the browser; browser holds an HttpOnly session cookie.
- Downstream APIs contain **no auth code**: they trust `X-User-Id`, `X-User-Name`, `X-User-Roles`.
  `api-gateway` always strips client-supplied `X-User-*`. NetworkPolicies (Step 15) enforce that
  only `api-gateway` can reach the APIs.
- Route policies: `GET /api/catalog/*` public · `POST /api/catalog/books` admin ·
  `/api/orders/*` authenticated · `POST /api/admin/revoke/{user}` admin.
- Keycloak issuer/hostname: public `https://auth.bookstore.localhost`, in-cluster backchannel
  `http://keycloak:8080` (explained in Step 12).
- The learner asked that gateway and auth concepts be **explained in full detail** — the conceptual
  foundation is `docs/00-overview.md` §3.7–§3.8; Steps 11 and 12 go deeper, never shallower.

## 5. Tutorial structure (the step plan)

| # | Doc | Topic |
|---|-----|-------|
| 00 | `docs/00-overview.md` | Overview, mental model, reverse proxies & API gateways, authentication design, tools, prerequisites |
| 01 | `docs/01-the-application-and-containers.md` | Build all apps (incl. YARP gateway + Keycloak realm); Dockerfiles; Docker Compose; what containers really are (namespaces, cgroups, images, layers) |
| 02 | `docs/02-networking-from-zero.md` | IP, subnets, ports, TCP/UDP, DNS, routing, NAT; HTTP, cookies & TLS basics; build container networking by hand (netns, veth, bridge, iptables) |
| 03 | `docs/03-kubernetes-architecture-and-first-cluster.md` | Why orchestration; control plane & node components; reconciliation; create kind cluster; kubectl |
| 04 | `docs/04-pods-and-manifests.md` | Pods, YAML anatomy, apiVersion/kind/metadata/spec/status, lifecycle, logs, exec, multi-container |
| 05 | `docs/05-labels-replicasets-deployments.md` | Labels/selectors, ReplicaSets, Deployments, scaling, rolling updates, rollbacks |
| 06 | `docs/06-kubernetes-networking-deep-dive.md` | Pod network model, CNI, cross-node traffic, inspecting inside kind nodes |
| 07 | `docs/07-services-and-dns.md` | ClusterIP/NodePort/LoadBalancer/headless, kube-proxy & iptables, EndpointSlices, CoreDNS |
| 08 | `docs/08-namespaces-configmaps-secrets.md` | Namespaces, ConfigMaps, Secrets, env vs mounted files |
| 09 | `docs/09-storage-and-statefulsets.md` | Volumes, PV/PVC, StorageClass, StatefulSets → Postgres & Redis; db-migrate Job |
| 10 | `docs/10-health-resources-scheduling.md` | Probes, requests/limits, QoS, affinity, taints/tolerations, PDBs |
| 11 | `docs/11-edge-gateway.md` | Ingress vs Gateway API, CRDs, Envoy Gateway via Helm, Gateway/HTTPRoute, hostnames, TLS, HTTP→HTTPS, rate limiting |
| 12 | `docs/12-identity-and-api-gateway.md` | Keycloak on K8s, OAuth2/OIDC flows in detail, JWT/JWKS, BFF sessions, YARP gateway custom auth, replicas sharing sessions/keys, issuer hostname problem |
| 13 | `docs/13-jobs-cronjobs-and-workers.md` | Jobs, CronJobs, worker Deployment, graceful shutdown |
| 14 | `docs/14-autoscaling.md` | metrics-server, HPA, load testing with loadgen |
| 15 | `docs/15-security.md` | ServiceAccounts, RBAC, NetworkPolicies (incl. header-spoofing attack → fix), securityContext, Pod Security Standards |
| 16 | `docs/16-observability-and-troubleshooting.md` | Logs, events, Prometheus/Grafana, debugging playbook |
| 17 | `docs/17-packaging-kustomize-helm.md` | Kustomize base/overlays, Helm chart for the app |
| 18 | `docs/18-capstone.md` | Full system end to end, failure drills, what's next (GitOps, mesh, cloud) |

The plan may be refined (split/merge) if the learner asks; record any change in
`TUTORIAL-INDEX.md` **and** in this table.

## 6. How to run the tutorial (protocol for the agent)

### 6.1 At the start of every session
1. Read `TUTORIAL-INDEX.md` to find the **current step** and the **next step**.
2. Read the previous step's doc "Recap" section to re-establish context.
3. If the learner's message is a question, **answer it first**; do not advance.

### 6.2 Advancing
- **Only advance when the learner explicitly says so** ("go ahead", "next", "continue", "vai").
- Implement **only** what belongs to the current step. Do not pre-create manifests or code for
  later steps. (Exception: Step 01 creates **all application code**, because later steps deploy it.)
- When a step is finished, **stop** and summarise: what was built, what to run, what to read,
  and invite questions.

### 6.3 Per-step deliverables (checklist)
For step `NN`:
1. `docs/NN-<slug>.md` written following the template in §7.
2. Code / manifests / scripts for this step only, placed per §8.
3. Commands in the doc were **actually executed** by the agent where possible (cluster steps:
   run them against `kind-k8s-tutorial`), and outputs in the doc are real or clearly marked as
   "example output".
4. `scripts/reset-to-step.sh` updated so it can rebuild the cluster state at the end of step `NN`
   (from Step 03 onward).
5. `TUTORIAL-INDEX.md` updated: status, what was explained, files created, open questions.
6. Git: one commit `step NN: <title>` and an annotated tag `step-NN`.

### 6.4 Clarifications
- When the learner asks a question about a step, answer in chat.
- If the answer adds real value, append it to that step's doc under **"Q&A"** and log it in
  `TUTORIAL-INDEX.md` (column "Q&A"). Commit as `step NN: Q&A <topic>` (no new tag; move the tag
  with `git tag -f -a step-NN` only if the step's content changed).

## 7. Step document template

Every `docs/NN-*.md` uses these sections, in this order:

1. **Title + one-line goal**
2. **Where we are** — what we have so far, what this step adds (small diagram welcome)
3. **What you'll learn** — bullet list
4. **Concepts** — the theory, from zero, with analogies → precise explanation, Mermaid/ASCII diagrams
5. **Hands-on lab** — numbered steps, every command explained (what it does, what each flag means,
   what output to expect)
6. **Verify** — commands that prove it works, with expected results
7. **Break it on purpose** — 1–3 experiments that fail in instructive ways, and how to diagnose them
8. **Recap** — short summary of the key ideas
9. **Glossary** — new terms introduced in this step
10. **Cleanup / state for next step** — what to keep running
11. **Q&A** — filled in over time from the learner's questions

Style rules:
- Every YAML manifest is shown in full and annotated (comments or a field-by-field table).
- Every command block states **where** to run it (WSL shell, inside a container, inside a kind node).
- Prefer Mermaid diagrams (`flowchart`, `sequenceDiagram`); fall back to ASCII.
- Keep the language plain English; short paragraphs.

## 8. Repository layout & conventions

```
AGENTS.md                 # this file (CLAUDE.md -> AGENTS.md)
TUTORIAL-INDEX.md         # progress tracker
README.md                 # human entry point
docs/                     # one doc per step
apps/<name>/              # application source + Dockerfile (Step 01)
compose.yaml              # Docker Compose for local run (Step 01)
cluster/                  # kind cluster config (Step 03+)
k8s/                      # manifests, organised by component; later Kustomize base/overlays (Step 16)
scripts/                  # helper scripts (prereqs, build/load images, reset-to-step)
labs/                     # throwaway lab material that isn't part of the system (e.g. Step 02 netns)
```

Conventions:
- Kubernetes namespace for the app: `bookstore` (introduced in Step 08; before that use `default`).
- Image names: `bookstore/<app>:<tag>`; loaded into kind with `kind load docker-image --name k8s-tutorial`.
- Labels on everything: `app.kubernetes.io/name`, `app.kubernetes.io/part-of: bookstore`,
  `app.kubernetes.io/component`.
- Scripts are bash, `set -euo pipefail`, idempotent, and print what they do.
- Pin versions (images, Helm charts) and record them in the step doc.
- Host ports: avoid `8080` (used by `kube-shop`). Planned edge-gateway host ports: `80`/`443`
  (fallback `9080`/`9443` if busy) — final choice made and documented in Step 03.
- Hostnames: `bookstore.localhost` (app) and `auth.bookstore.localhost` (Keycloak). `*.localhost`
  resolves to 127.0.0.1 in browsers and curl — no `/etc/hosts` edits.

## 9. Git

- Repo initialised in Step 00. Branch: `main`.
- One commit per step + annotated tag `step-NN`. Learner can `git diff step-04 step-05`.
- Commit messages end with the attribution trailer configured for the agent.
