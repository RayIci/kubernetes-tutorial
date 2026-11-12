# Tutorial Index — progress tracker

> Maintained by the agent. Read this first in every session (see `AGENTS.md` §6).

## Current position

| | |
|---|---|
| **Last completed step** | 00 — Overview & prerequisites |
| **Next step** | 01 — The application & containers |
| **Waiting for** | Learner to say "go ahead" (or ask questions about Step 00) |

## Decisions agreed with the learner

| Date | Decision |
|------|----------|
| 2026-11-12 | Services: Go (`catalog-api`, `loadgen`) + Python/FastAPI (`orders-api`, `worker`, `db-migrate`) |
| 2026-11-12 | Frontend: Next.js (React), standalone server output |
| 2026-11-12 | API gateway: Kubernetes Gateway API implemented by Envoy Gateway (no custom gateway code) |
| 2026-11-12 | Local cluster: kind, multi-node (1 control plane + 2 workers), name `k8s-tutorial` |
| 2026-11-12 | Git: one commit + annotated tag `step-NN` per step |
| 2026-11-12 | Step plan (00–17) decided by the agent; see `AGENTS.md` §5 |

## Steps

| # | Title | Status | Doc | Tag |
|---|-------|--------|-----|-----|
| 00 | Overview & prerequisites | ✅ done | [docs/00-overview.md](docs/00-overview.md) | `step-00` |
| 01 | The application & containers | ⏭️ next | — | — |
| 02 | Networking from zero | ⬜ todo | — | — |
| 03 | Kubernetes architecture & first cluster | ⬜ todo | — | — |
| 04 | Pods & manifests | ⬜ todo | — | — |
| 05 | Labels, ReplicaSets, Deployments | ⬜ todo | — | — |
| 06 | Kubernetes networking deep dive | ⬜ todo | — | — |
| 07 | Services & DNS | ⬜ todo | — | — |
| 08 | Namespaces, ConfigMaps, Secrets | ⬜ todo | — | — |
| 09 | Storage & StatefulSets | ⬜ todo | — | — |
| 10 | Health, resources, scheduling | ⬜ todo | — | — |
| 11 | API gateway (Gateway API + Envoy Gateway) | ⬜ todo | — | — |
| 12 | Jobs, CronJobs & workers | ⬜ todo | — | — |
| 13 | Autoscaling | ⬜ todo | — | — |
| 14 | Security | ⬜ todo | — | — |
| 15 | Observability & troubleshooting | ⬜ todo | — | — |
| 16 | Packaging: Kustomize & Helm | ⬜ todo | — | — |
| 17 | Capstone | ⬜ todo | — | — |

Legend: ✅ done · 🔄 in progress · ⏭️ next · ⬜ todo

## Step log

### Step 00 — Overview & prerequisites ✅
- **Explained:** what problem Kubernetes solves (in plain words); the final Bookstore system and its
  traffic flow; how the tutorial works (one step at a time, Q&A); the tools (Docker, kind, kubectl,
  Helm, git) and what each is for; the learner's environment (WSL2 + Docker Desktop) and its
  networking quirk; the per-step document layout.
- **Files:** `AGENTS.md`, `CLAUDE.md` (symlink), `TUTORIAL-INDEX.md`, `README.md`, `.gitignore`,
  `docs/00-overview.md`, `scripts/check-prereqs.sh`.
- **Q&A:** —
- **Notes for next step:** Step 01 creates **all** application code under `apps/` + `compose.yaml`,
  and teaches containers from zero (process isolation, namespaces, cgroups, images & layers,
  Dockerfiles, multi-stage builds, Compose networking).
