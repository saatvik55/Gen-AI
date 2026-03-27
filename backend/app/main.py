from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .controllers import topic_controller
from .controllers.auth_controller import router as auth_router
from .database import Base, engine


@asynccontextmanager
async def lifespan(_app: FastAPI):
    # Startup: Create database tables
    Base.metadata.create_all(bind=engine)
    yield
    # Shutdown: cleanup if needed


app = FastAPI(
    title="Learning Agent Backend",
    description="FastAPI backend for topics, summaries, quizzes, and strength tracking.",
    version="0.1.0",
    lifespan=lifespan,
)

# Enable CORS — allow all origins in development.
# Bearer-token auth doesn't need allow_credentials=True,
# and allow_credentials=True is incompatible with allow_origins=["*"].
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["meta"])
def health_check() -> dict:
    return {"status": "ok"}


app.include_router(topic_controller)
app.include_router(auth_router)