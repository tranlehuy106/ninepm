from abc import abstractmethod
from typing import List
from firebase_admin.messaging import MulticastMessage


class INotificationClient:

    @abstractmethod
    def send_notification(
        self,
        tokens: List,
        title: str = None,
        body: str = None,
        image: str = None,
        data: dict = None,
        sound: str = None,
        channel_id: str = None,
        pay_load: MulticastMessage = None
    ):
        pass
