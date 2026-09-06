## The SSH passphrase leak (2026-07-23)
Pasted an SSH key passphrase into a chat on day one. Learned the rotation reflex:
when a secret touches an insecure channel you rotate immediately, regardless of how
harmless the exposure seems — deciding case-by-case whether a leak "counts" is how
breaches happen. Also learned single-factor vs two-factor secrets: an API key is
instant compromise if leaked; a passphrase without the key file is useless alone.

## Oracle silently halved the free tier (2026-07-28)
Three days into the project my cloud provider cut the Always Free ARM allowance from
4 OCPU / 24 GB to 2 OCPU / 12 GB — no announcement, docs quietly updated. Caught it by
verifying vendor terms before provisioning instead of trusting my own plan document.
Re-budgeted the cluster (Langfuse moves out-of-band) and corrected the ADR. Lesson:
free-tier terms are not a contract; verify current reality before building on it.

## Two clouds ran out of ARM capacity (2026-08)
Designed for a €0 Oracle free-tier ARM VM. Oracle returned "Out of host capacity" across
every Frankfurt availability domain — through an overnight retry loop and even after a
PAYG upgrade. Fell back to Hetzner; its ARM shapes were also unavailable across all EU
locations. Because everything was Terraform, migrating providers and switching ARM->x86
was a config change, not a rebuild — the network concepts, SSH keys and workflow all
transferred. Lesson: don't marry an architecture choice that isn't load-bearing, and
don't defend a €0 constraint past the point where it costs you days. Ended on Hetzner x86.## Kept the Kubernetes API off the public internet (2026-08)
The cluster firewall only opens 22/80/443 — port 6443 (the K8s API) is closed to the
world. Instead of opening it, I reach the API from my laptop over an SSH tunnel
(`ssh -L 6443:localhost:6443`), so the control plane has zero public attack surface.
Chose the secure pattern over the common "open 6443 to my IP" shortcut.

## Six-layer debug to get HTTPS working (2026-09)
Getting a TLS cert on single-node k3s took debugging six distinct failures, each
revealed only after fixing the last, all read from `kubectl logs`/`describe`:
(1) Helm chart schema rejected the redirect config; (2) k3s's built-in servicelb
grabbed ports 80/443 before Traefik — disabled it; (3) non-root Traefik couldn't bind
privileged ports — ran as root (acceptable for a single-node edge proxy);
(4) HTTP-01 challenge conflicted with the HTTP->HTTPS redirect — switched to TLS-ALPN;
(5) readOnlyRootFilesystem blocked writing the ACME store — removed it;
(6) tlsChallenge:{} didn't register via Helm — forced it with an explicit CLI flag.
Lesson: read the ONE fatal error line past the warnings, fix, repeat. Each layer was
a clean diagnosis, not a guess.
