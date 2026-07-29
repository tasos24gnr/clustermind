# Changelog

## P1 — Infrastructure (in progress)
- Installed Terraform from HashiCorp's official apt repo (not snap).
- Generated OCI API signing key, secured in ~/.oci (700 dir, 600 key), out of the repo.
- Proved credentials with `oci iam region list` before writing any Terraform.
- Wrote provider.tf (oracle/oci ~> 8.0), ran `terraform init`, committed the lock file.

## P0 — Foundations (2026-07-23)
- Built: repo skeleton, gitignore-first secret hygiene, README with honest scope.
- Decided: ADR-001 (k3s over kubeadm/k0s/k3d, with tradeoffs documented).
- Environment: WSL2 Ubuntu, SSH key auth to GitHub.
- Surprised me: how much of "cloud setup" is fighting credentials and DNS, not real work.
