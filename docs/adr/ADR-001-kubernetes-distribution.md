# ADR-001: Use k3s as the Kubernetes distribution

- **Status:** Accepted
- **Date:** 2026-07-23

## Context

ClusterMind needs a real Kubernetes cluster for the agent to diagnose. The cluster is
both the subject of the project and part of its infrastructure, so it must be genuinely
representative of Kubernetes as used in industry — a simulation would undermine the
entire premise.

Constraints at the time of this decision:

- **Budget is €0.** The target host is an Oracle Cloud always-free ARM VM
  (4 OCPU / 24 GB RAM). Everything must fit there.
- **ARM64 architecture.** Not all tooling ships ARM builds; this narrows the field.
- **Single node.** The free tier provides one machine. There is no second node to fail
  over to.
- **The cluster must be publicly reachable.** A live URL is a hard requirement — the
  project is a portfolio artifact and a recruiter must be able to click it.
- **Time is the scarcest resource.** ~5 weeks at 15–20h/week, and the learning value of
  this project sits in the agent, the retrieval pipeline and the evaluation harness, not
  in hand-assembling a control plane.

## Decision

We will run a **single-node k3s cluster** on the Oracle Cloud ARM VM, installed via the
official install script and provisioned declaratively with Terraform.

## Alternatives considered

**kubeadm (upstream Kubernetes).** The official installer, and the reference
implementation of a "real" cluster. Rejected: it assumes a multi-node topology, requires
manually selecting and configuring a CNI plugin, an ingress controller and storage, and
carries a materially larger memory footprint. The additional configuration surface buys
no learning that is relevant to this project's goals, and consumes time budgeted for the
agent.

**k0s / MicroK8s.** Both are credible lightweight distributions with comparable
resource profiles. Rejected on ecosystem grounds rather than technical merit: k3s has the
largest community, the most ARM-tested documentation, and is the distribution most
frequently named in edge/lightweight Kubernetes job descriptions. Where options are
technically equivalent, the tiebreaker is the one whose name an interviewer recognises.

**kind / k3d (Kubernetes in Docker, local).** The fastest path to a working cluster and
excellent for CI. Rejected as the primary target: these run inside Docker on a local
machine, are ephemeral, and expose no public address. That breaks the live-demo
requirement and removes every genuinely instructive problem — TLS certificates, ingress
from the public internet, a host that must be hardened because it is actually exposed.
k3d remains a viable local development fallback and is retained as a contingency if
Oracle free-tier ARM capacity proves unobtainable.

**A managed cluster (GKE / EKS / AKS).** Rejected on cost. No managed Kubernetes
offering has a free tier compatible with a €0 budget for continuous operation.

## Consequences

**Accepted benefits:**

- Real, conformant Kubernetes. `kubectl`, Helm charts, RBAC and manifests all transfer
  unchanged to any standard cluster; nothing learned here is k3s-specific trivia.
- Single-binary installation, leaving time for the parts of the project that carry the
  learning value.
- Traefik ingress and a local-path storage provisioner ship enabled by default, removing
  two configuration decisions from the critical path.
- Comfortable headroom on 24 GB for Qdrant, Langfuse, the API service and the
  deliberately fragile demo application.

**Accepted costs and risks:**

- **No high availability.** A single node means the machine is a single point of
  failure. If it dies, the cluster and every workload die with it. Recovery is
  `terraform apply` plus a redeploy, not a failover — the recovery path is
  reconstruction, which is precisely why the infrastructure must be codified.
- **SQLite instead of etcd** as the datastore in single-node mode. Adequate here;
  not what a multi-node production cluster would use.
- **Some components differ from upstream defaults** (Traefik rather than ingress-nginx,
  local-path rather than a CSI driver). These must be stated accurately rather than
  described as if they were standard.
- **Node-local storage.** A PersistentVolumeClaim is bound to this node's disk. There is
  no replication; backup of the Qdrant volume is a separate concern that this decision
  does not address.

## Supersession

This decision is revisited if Oracle free-tier ARM capacity cannot be obtained. The
documented fallbacks, in order: a Hetzner ARM instance (~€4/month, breaking the €0
constraint), or local k3d with a tunnelled public endpoint (breaking the live-URL
requirement). Either would be recorded as a new ADR superseding this one.
