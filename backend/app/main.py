from fastapi import FastAPI

from . import router_topics


app = FastAPI(
    title="Learning Agent Backend",
    description="FastAPI backend for topics, summaries, quizzes, and strength tracking.",
    version="0.1.0",
)


@app.get("/health", tags=["meta"])
def health_check() -> dict:
    return {"status": "ok"}


app.include_router(router_topics.router, prefix="/topics", tags=["topics"])

