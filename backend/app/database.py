from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os


# SQLite database URL - uses a file in the backend directory
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./learning_agent.db",
)

# SQLite requires check_same_thread=False for FastAPI
connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

