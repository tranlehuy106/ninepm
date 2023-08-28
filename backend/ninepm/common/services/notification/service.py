__all__ = ['MerchantNotificationService']

import json
from typing import List
from .dto import NotificationData
import dataclasses
from common.services.task_producer.common import TaskProducerCommonService


class MerchantNotificationService(TaskProducerCommonService):
    """
    Ở mỗi ViewService sẽ định nghĩa 1 hàm để gọi hàm send_notification
    Ví dụ:
    def send_notification_example(self, user: BusinessUser):
        assert isinstance(user, BusinessUser)

        data = NotificationData(
            type=NotificationType.TEST_EXAMPLE,
            data=dict(abc='Title', xyz='Test')
        )
        tokens = ['token1']
        template = get_template('...')
        self.send_notification_to_messaging_system(
            tokens=tokens, title='Title', message=template, data=data
        )
        notification_client nếu không truyền vào sẽ lấy notification_client_default
    """

    def send_notification_to_messaging_system(
        self,
        tokens: List,
        title: str,
        message: str,
        data: NotificationData = None,
        notification_client: str = None,
    ):
        assert dataclasses.is_dataclass(data)
        assert isinstance(data, NotificationData)
        if data is not None:
            data = dataclasses.asdict(data)
            if not isinstance(data['extra_data'], str):
                data['extra_data'] = json.dumps(data['extra_data'])
        byte_data = self._dict_2_bytes(
            dict(
                tokens=tokens,
                title=title,
                message=message,
                data=data,
                notification_client=notification_client
            )
        )
        self.get_task_producer_client().add_to_queue(byte_data=byte_data)

    @staticmethod
    def _dict_2_bytes(data: dict):
        return json.dumps(data).encode('utf-8')
