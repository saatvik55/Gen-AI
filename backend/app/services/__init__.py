from .topic_service import TopicService
from .decay_service import DecayService

topic_service = TopicService()
decay_service = DecayService()

__all__ = ["topic_service", "decay_service", "TopicService", "DecayService"]
