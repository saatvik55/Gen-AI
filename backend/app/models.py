from sqlalchemy import Column, Integer, String, Float, DateTime
from datetime import datetime, timezone
from .database import Base


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
