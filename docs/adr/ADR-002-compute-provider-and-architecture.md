# ADR-002: Migrate compute from Oracle Cloud (ARM) to Hetzner Cloud (x86)

- **Status:** Accepted
- **Date:** 2026-08-11
- **Supersedes:** the compute/host portion of ADR-001 (k3s distribution choice is unaffected)

## Context

ADR-001 assumed an Oracle Cloud Always Free ARM VM as the host. In practice this proved
unobtainable:

- **Oracle capacity.** The `VM.Standard.A1.Flex` ARM shape returned "Out of host capacity"
  in every Frankfurt availability domain (AD-1/2/3), across an overnight automated retry
  loop, and even after upgrading the account to Pay-As-You-Go (which reportedly grants
  scheduling priority). Oracle documents this as a temporary regional shortage that can
  persist for days; it did.
- **Hetzner ARM capacity.** Falling back to Hetzner, the ARM `CAX` shapes returned
  "resource_unavailable" across all three EU locations (nbg1/fsn1/hel1) for both CAX11
  and CAX21 — a concurrent ARM shortage.
- **Time cost.** Multiple working sessions were consumed on host provisioning alone,
  blocking every downstream phase (k3s, RAG, the agent — where the project's actual
  learning value lives).

The €0 budget and the ARM architecture were both goals inherited from ADR-001. Neither
turned out to be load-bearing for ClusterMind: the project needs *a real, reachable
Kubernetes host*, not specifically a free one or specifically an ARM one.

## Decision

We will host the cluster on a **Hetzner Cloud `cpx32` x86 instance** (4 vCPU, 8 GB RAM)
in `hel1` (Helsinki), provisioned with the existing Terraform via the `hcloud` provider.

## Alternatives considered

**Continue waiting for Oracle/Hetzner ARM capacity.** Rejected: unbounded delay with no
control over when (or whether) capacity appears, in direct violation of the project's
2-hour-tripwire rule against hiding in a blocker.

**Local k3d for €0.** Viable and genuinely free, retained as a documented fallback.
Rejected as primary: it is ephemeral, laptop-bound, and exposes no stable public URL,
which breaks the live-demo requirement that makes this a portfolio piece.

**Hetzner ARM (CAX), when available.** Equivalent in every way that matters and slightly
cheaper. Not rejected in principle — but unavailable at decision time, and x86 removes
the need for cross-architecture Docker builds later, which is a simplification, not a
loss.

## Consequences

**Accepted benefits:**

- A running, reachable host today, unblocking the entire remaining project.
- x86 means container images build for the same architecture they run on — no
  cross-compilation or multi-arch build complexity in the CI/CD phase.
- The migration itself cost only a rewrite of `provider.tf`/`main.tf` against a new
  provider — the network *concepts*, SSH keys, variables pattern, and Terraform workflow
  all transferred unchanged. This is the portability argument for infrastructure-as-code,
  demonstrated rather than asserted.

**Accepted costs:**

- **The €0 budget is abandoned**, at roughly €8/month for `cpx32`. Mitigated by hourly
  billing: `terraform destroy` when not actively working means paying only for hours used,
  keeping total project cost to a low double-digit euro figure.
- **PAYG safety net is gone on the abandoned Oracle account**, and orphaned Oracle
  network resources (VCN, subnet, gateway, route table, security list) remain until
  destroyed — a cleanup task, tracked separately. They are free and harmless in the
  interim.
- **Single node, no HA** — unchanged from ADR-001 and still accepted.

## Note on the €0 goal

The €0 constraint was a discipline, not a requirement. It was retired the moment it began
costing more in schedule and momentum than the money it saved — the correct time to spend
is when a constraint's cost exceeds its value. This decision is itself the artifact of
that reasoning.
