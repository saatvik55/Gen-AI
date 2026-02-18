from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..schemas import TopicCreate, TopicOut
from ..services import topic_service, decay_service

router = APIRouter(prefix="/topics", tags=["Topics"])


@router.post("/", response_model=TopicOut, status_code=201)
def create_topic(topic_data: TopicCreate, db: Session = Depends(get_db)):
    """Create a new topic"""
    topic = topic_service.create_topic(
        db=db,
        title=topic_data.title,
        summary=topic_data.notes or ""
    )
    return topic


@router.get("/", response_model=List[TopicOut])
def get_topics(db: Session = Depends(get_db)):
    """Get all topics with decay applied"""
    topics = topic_service.get_all_topics(db)
    for topic in topics:
        decay_service.apply_decay(topic)
    return topics


@router.get("/{topic_id}", response_model=TopicOut)
def get_topic(topic_id: int, db: Session = Depends(get_db)):
    """Get a specific topic by ID"""
    topic = topic_service.get_topic_by_id(db, topic_id)
    if not topic:
        raise HTTPException(status_code=404, detail="Topic not found")
    decay_service.apply_decay(topic)
    return topic


@router.delete("/{topic_id}", status_code=204)
def delete_topic(topic_id: int, db: Session = Depends(get_db)):
    """Delete a topic"""
    success = topic_service.delete_topic(db, topic_id)
    if not success:
        raise HTTPException(status_code=404, detail="Topic not found")
    return None