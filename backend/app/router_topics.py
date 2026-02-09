from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from . import database, schemas


router = APIRouter()


@router.get("/", response_model=List[schemas.TopicOut])
def list_topics(db: Session = Depends(database.get_db)):
    # TODO: Replace with real SQLAlchemy model query
    # Temporary in-memory stub so Flutter can integrate:
    return [
        schemas.TopicOut(
            id=1,
            title="Dynamic Programming",
            summary="Optimizing recursive solutions by caching subproblems.",
            strength_score=0.62,
            last_reviewed=datetime(2026, 2, 9, 10, 0, 0),
        )
    ]


@router.post(
    "/", response_model=schemas.TopicOut, status_code=status.HTTP_201_CREATED
)
def create_topic(payload: schemas.TopicCreate, db: Session = Depends(database.get_db)):
    # TODO: Persist to PostgreSQL and trigger summary generation
    now = datetime.utcnow()
    return schemas.TopicOut(
        id=2,
        title=payload.title,
        summary=payload.notes or "",
        strength_score=0.5,
        last_reviewed=now,
    )

