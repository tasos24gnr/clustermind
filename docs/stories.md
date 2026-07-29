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
