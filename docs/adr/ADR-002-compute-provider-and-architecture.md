# ADR-002: Migrate compute from Oracle Cloud (ARM) to Hetzner Cloud (x86)

- **Status:** Accepted
- **Date:** 2026-08-11
- **Supersedes:** the compute/host portion of ADR-001 (the k3s distribution choice is unaffected)

## Context

ADR-001 assumed an Oracle Cloud Always Free ARM VM as the host. In practice this proved unobtainable:

- **Oracle capacity.** The `VM.Standard.A1.Flex` ARM shape returned "Out of host capacity" in every Frankfurt availability domain, across an overnight automated retry loop, and even after upgrading the account to Pay-As-You-Go. Oracle documents this as a temporary regional shortage that can persist for days; it did.
- **Hetzner ARM capacity.** Falling back to Hetzner, the ARM `CAX` shapes returned "resource_unavailable" across all three EU locations for both CAX11 and CAX21 — a concurrent ARM shortage.
- **Time cost.** Multiple sessions were consumed on host provisioning alone, blocking every downstream phase where the project's actual learning value lives.

The €0 budget and the ARM architecture were both goals inherited from ADR-001. Neither turned out to be load-bearing for ClusterMind: the project needs a real, reachable Kubernetes host, not specifically a free or ARM one.

## Decision

We will host the cluster on a **Hetzner Cloud `cpx32` x86 instance** (4 vCPU, 8 GB RAM) in `hel1` (Helsinki), provisioned with the existing Terraform via the `hcloud` provider.

## Alternatives considered

**Continue waiting for ARM capacity.** Rejected: unbounded delay with no control over when capacity appears, violating the project's rule against hiding in a blocker.

**Local k3d for €0.** Genuinely free, retained as a documented fallback. Rejected as primary: ephemeral, laptop-bound, and no stable public URL, which breaks the live-demo requirement.

**Hetzner ARM (CAX), when available.** Equivalent and slightly cheaper. Not rejected in principle, but unavailable at decision time; x86 also removes the need for cross-architecture Docker builds later.

## Consequences

**Accepted benefits:**
- A running, reachable host, unblocking the remaining project.
- x86 means images build for the same architecture they run on — no multi-arch build complexity in CI/CD.
- The migration cost only a rewrite of `provider.tf`/`main.tf`; the network concepts, SSH keys, variables pattern, and Terraform workflow all transferred unchanged. This is the portability argument for infrastructure-as-code, demonstrated rather than asserted.
