from sqlalchemy import Boolean, Column, Integer, String, Float, DateTime
from datetime import datetime, timezone
from .database import Base


class User(Base):
    """SQLAlchemy model for users table"""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=True)
    email = Column(String, unique=True, index=True, nullable=True)
    phone = Column(String, unique=True, index=True, nullable=True)
    hashed_password = Column(String, nullable=True)
    google_id = Column(String, unique=True, index=True, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f"<User(id={self.id}, email='{self.email}')>"


class Topic(Base):
    """SQLAlchemy model for topics table"""
    __tablename__ = "topics"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    summary = Column(String, default="")
    strength_score = Column(Float, default=1.0)
    last_reviewed = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f"<Topic(id={self.id}, title='{self.title}', strength={self.strength_score:.2f})>"
