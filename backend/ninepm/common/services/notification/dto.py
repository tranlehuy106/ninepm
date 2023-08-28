__all__ = ["NotificationData"]

from dataclasses import dataclass


@dataclass(frozen=True)
class NotificationData:
    type: str
    extra_data: object
