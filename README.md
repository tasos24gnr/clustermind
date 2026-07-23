# ClusterMind

An AI SRE copilot that diagnoses a live Kubernetes cluster.

ClusterMind is an agentic system that answers operational questions about a running
single-node k3s cluster and produces cited, structured diagnoses. It combines live
cluster inspection — pods, events, logs, node status, PromQL metrics, exposed as
read-only MCP tools — with hybrid retrieval over hand-written runbooks and Kubernetes
documentation, so an answer is grounded in both what the cluster is doing right now and
what the documentation says it should be doing.

Every tool is read-only by construction. The agent can propose a `kubectl` command but
never executes one: the human stays the decision-maker and the blast radius of a wrong
answer is zero. Grounding is the hard part — a confidently wrong root cause is worse
than no answer at all, because it sends an engineer down the wrong path at 3am — so
every claim carries a citation, the agent refuses to answer when retrieval confidence is
low, and a suite of golden-case evaluations gates every pull request.

## Status

Early development. Phase 0 of 7.

**This is not production-ready, deliberately.** It runs on a single free-tier ARM node:
no high availability, no redundancy, k3s with SQLite instead of etcd. It is built *with*
production practices — infrastructure as code, CI/CD, least-privilege RBAC, evaluations
in CI, observability — on infrastructure that is explicitly not production. The gap is
documented, not hidden.

## Architecture (target)

| Layer | Choice |
|---|---|
| Infrastructure | Oracle Cloud always-free ARM VM, provisioned with Terraform |
| Cluster | Single-node k3s, Traefik ingress, cert-manager + Let's Encrypt |
| API | FastAPI — `/ask`, `/healthz`, `/metrics` |
| Retrieval | Qdrant (Helm + PVC), hybrid dense + sparse, reranking, mandatory citations |
| Orchestration | LangGraph — router, iteration caps, token budgets, Pydantic structured output |
| Tools | MCP server over the Python Kubernetes client, least-privilege ServiceAccount |
| LLM | Gemini free tier, swappable behind a provider interface |
| CI/CD | GitHub Actions → multi-stage ARM image → GHCR → `helm upgrade --install` |
| Evals | ~30 golden cases; docs-QA gate every PR, incident scenarios nightly |
| Observability | Grafana Cloud (out-of-band) + self-hosted Langfuse for agent traces |

## Roadmap

- [ ] **P0** — Repository skeleton, ADR-001 (k3s / Qdrant / Gemini)
- [ ] **P1** — Terraform-provisioned hardened VM, k3s, TLS
- [ ] **P2** — Skeleton FastAPI service, full CI/CD, Helm chart
- [ ] **P3** — RAG core over Kubernetes docs + hand-written runbooks
- [ ] **P4** — MCP read-only tool server, LangGraph agent
- [ ] **P5** — Evaluation suite, guardrails, prompt-injection defence
- [ ] **P6** — Observability, SLO, chaos drills with incident reports
- [ ] **P7** — Publication: demo, architecture diagram, eval results, write-up

Post-core: alert-triggered diagnosis, PR-based human-in-the-loop remediation,
multi-agent decomposition, cost/latency engineering.

## Documentation

- `docs/adr/` — architecture decision records
- `docs/runbooks/` — operational runbooks (the retrieval corpus)
- `docs/incidents/` — incident reports from chaos drills
