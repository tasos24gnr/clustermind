from fastapi import FastAPI

app = FastAPI(title="ClusterMind API")


@app.get("/healthz")
def healthz():
    """Liveness check. Kubernetes hits this to know the service is up."""
    return {"status": "ok"}


@app.get("/")
def root():
    return {"service": "clustermind", "message": "not much here yet"}
