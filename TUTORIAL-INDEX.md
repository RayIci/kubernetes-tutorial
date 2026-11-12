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
| 2026-11-13 | Gateways **stacked**: Envoy Gateway (Gateway API, YAML) at the edge + `api-gateway` in C#/YARP for custom auth |
| 2026-11-13 | Auth: **Keycloak** as identity provider + custom logic inside `api-gateway` (BFF sessions in Redis, revoked list, route policies, `X-User-*` headers); no separate auth-api |
| 2026-11-13 | Learner asked for gateway/auth concepts to be explained in full detail (Step 00 §3.7–3.8, Steps 11–12) |
| 2026-11-12 | Local cluster: kind, multi-node (1 control plane + 2 workers), name `k8s-tutorial` |
| 2026-11-12 | Git: one commit + annotated tag `step-NN` per step |
| 2026-11-13 | Step plan (00–18) decided by the agent; API gateway split into Step 11 (edge) + Step 12 (identity & YARP); see `AGENTS.md` §5 |

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
| 11 | Edge gateway (Gateway API + Envoy Gateway) | ⬜ todo | — | — |
| 12 | Identity & API gateway (Keycloak + YARP) | ⬜ todo | — | — |
| 13 | Jobs, CronJobs & workers | ⬜ todo | — | — |
| 14 | Autoscaling | ⬜ todo | — | — |
| 15 | Security | ⬜ todo | — | — |
| 16 | Observability & troubleshooting | ⬜ todo | — | — |
| 17 | Packaging: Kustomize & Helm | ⬜ todo | — | — |
| 18 | Capstone | ⬜ todo | — | — |

Legend: ✅ done · 🔄 in progress · ⏭️ next · ⬜ todo

## Step log

### Step 00 — Overview & prerequisites ✅
- **Explained:** what problem Kubernetes solves (in plain words); the final Bookstore system and its
  traffic flow; how the tutorial works (one step at a time, Q&A); the tools (Docker, kind, kubectl,
  Helm, git) and what each is for; the learner's environment (WSL2 + Docker Desktop) and its
  networking quirk; the per-step document layout.
- **Files:** `AGENTS.md`, `CLAUDE.md` (symlink), `TUTORIAL-INDEX.md`, `README.md`, `.gitignore`,
  `docs/00-overview.md`, `scripts/check-prereqs.sh`.
- **Also explained (after learner questions, now in the main Concepts):** reverse proxy vs forward proxy;
  what an API gateway is; configured (Gateway API + Envoy Gateway) vs coded (YARP) gateways; the
  K8s "standard interface + implementation" pattern; managed external gateways; do we need both /
  stacking; how Bookstore splits work between edge and API gateway; header trust chain; AuthN vs
  AuthZ; why not build our own login; Keycloak concepts; JWT/JWKS; BFF pattern + login sequence;
  our per-request custom auth flow and route policies; why Keycloak + gateway logic (no auth-api);
  K8s consequences (Keycloak resources, Secrets, shared sessions, issuer hostnames).
- **Q&A:** Q1 does K8s have its own API gateway (vs YARP)? · Q2 YAML gateway vs YARP-style, do we
  need both? · Q3 Keycloak vs custom auth-api vs both? → docs/00-overview.md §10 (pointing to §3.7–3.8).
- **Notes for next step:** Step 01 creates **all** application code under `apps/` (frontend, catalog-api,
  orders-api, worker, db-migrate, loadgen, api-gateway) + Keycloak realm JSON + `compose.yaml`,
  and teaches containers from zero (process isolation, namespaces, cgroups, images & layers,
  Dockerfiles, multi-stage builds, Compose networking).
