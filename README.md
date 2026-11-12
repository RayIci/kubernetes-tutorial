# Kubernetes From Zero

A hands-on, step-by-step Kubernetes tutorial for people who have never used containers,
networking internals or Kubernetes. It starts with what a container and an IP address are,
and ends with a complete application running on a local multi-node cluster:

- a **Next.js** frontend
- a **Go** catalog API and a **Python** orders API
- a background **worker**
- **Postgres** and **Redis**
- two **stacked gateways**: an edge gateway (Kubernetes Gateway API + Envoy Gateway) and our own
  **C#/YARP API gateway** with custom authentication
- **Keycloak** as the identity provider (OpenID Connect login, BFF sessions)
- plus storage, autoscaling, security, monitoring and packaging (Kustomize/Helm)

## Start here

1. Read [docs/00-overview.md](docs/00-overview.md).
2. Run `./scripts/check-prereqs.sh`.
3. See [TUTORIAL-INDEX.md](TUTORIAL-INDEX.md) for where you are and what comes next.

## How it works

The tutorial is delivered **one step at a time** by an AI agent (rules in [AGENTS.md](AGENTS.md)).
After each step you can ask questions. When you're ready, say **"go ahead"** to get the next step.

Each step has its own document in [docs/](docs/) and its own git tag (`step-00`, `step-01`, …).
To see exactly what a step added, run `git diff step-04 step-05`.
