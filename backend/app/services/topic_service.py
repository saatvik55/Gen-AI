from sqlalchemy.orm import Session
from .. import models
from datetime import datetime, timezone

class TopicService:

    @staticmethod
    def create_topic(db: Session, title: str, summary: str):
        topic = models.Topic(
            title=title,
            summary=summary,
            strength_score=1.0,
            last_reviewed=datetime.now(timezone.utc)
        )
        db.add(topic)
        db.commit()
        db.refresh(topic)
        return topic

    @staticmethod
    def get_all_topics(db: Session):
        """Get all topics from the database"""
        return db.query(models.Topic).all()

    @staticmethod
    def get_topic_by_id(db: Session, topic_id: int):
        """Get a specific topic by ID"""
        return db.query(models.Topic).filter(models.Topic.id == topic_id).first()

    @staticmethod
    def delete_topic(db: Session, topic_id: int):
        """Delete a topic by ID"""
        topic = db.query(models.Topic).filter(models.Topic.id == topic_id).first()
        if topic:
            db.delete(topic)
            db.commit()
            return True
        return False