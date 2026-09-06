# Runbook: Pod in CrashLoopBackOff

## Symptom
A pod repeatedly starts, crashes, and restarts. `kubectl get pods` shows STATUS
`CrashLoopBackOff` and a RESTARTS count that keeps climbing. The pod never reaches
a stable `Running` state.

## Likely causes
- The application errors out on startup (bad config, missing environment variable,
  code exception before it can serve).
- A required dependency is unreachable (database, cache, or another service the app
  needs at boot).
- A missing or wrong secret/config value (wrong credentials, absent config file).
- A permissions problem inside the container (e.g. a non-root process trying to bind
  a privileged port below 1024, or unable to write to a required path).
- The container's start command or health probe is misconfigured, so Kubernetes kills
  it as unhealthy.

## How to diagnose
1. Look at the application's own logs — this usually names the fatal error:
   `kubectl logs <pod> -n <namespace>`
2. If the current logs are empty (the pod just restarted), read the *previous* crashed
   instance's logs:
   `kubectl logs <pod> -n <namespace> --previous`
3. Check Kubernetes' own events for scheduling, mount, or probe failures that don't
   appear in the app logs:
   `kubectl describe pod <pod> -n <namespace>`  (read the Events section at the bottom)
4. Read past the warnings to find the single fatal error line — that names the real cause.

## How to fix
Fix the specific fatal error identified above, then let the pod restart:
- Startup error / bad config → correct the config or environment variable and redeploy.
- Unreachable dependency → confirm the dependency is running and reachable, check the
  service name and port.
- Wrong/missing secret → correct the secret and restart the deployment.
- Permission problem → grant the specific capability or adjust the securityContext
  (e.g. allow binding low ports, or run as the required user).
- Misconfigured probe/command → fix the liveness/readiness probe or container command.

## Related
Distinct from `ImagePullBackOff` (image can't be pulled — the container never starts at
all) and `Pending` (pod can't be scheduled — no node/ports/resources available).
