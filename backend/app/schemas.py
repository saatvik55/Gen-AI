from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class TopicBase(BaseModel):
    title: str
    notes: Optional[str] = None


class TopicCreate(TopicBase):
    pass


class TopicUpdate(BaseModel):
    title: Optional[str] = None
    notes: Optional[str] = None


class TopicOut(BaseModel):
    id: int
    title: str
    summary: Optional[str] = None
    strength_score: float
    last_reviewed: Optional[datetime] = None

    class Config:
        from_attributes = True

