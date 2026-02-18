import math
from datetime import datetime, timezone

class DecayService:

    LAMBDA = 0.1

    @staticmethod
    def apply_decay(topic):
        # Handle timezone-aware and timezone-naive datetimes
        now = datetime.now(timezone.utc)
        last_reviewed = topic.last_reviewed

        # If last_reviewed is naive, make it aware (assume UTC)
        if last_reviewed and last_reviewed.tzinfo is None:
            last_reviewed = last_reviewed.replace(tzinfo=timezone.utc)

        if last_reviewed:
            days = (now - last_reviewed).days
            topic.strength_score = topic.strength_score * math.exp(-DecayService.LAMBDA * days)

        return topic