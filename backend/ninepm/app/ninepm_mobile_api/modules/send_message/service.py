__all__ = ['ViewService']

import threading

from django.utils import timezone

from common.services.notification.common import NotificationCommonService
from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()
        self.client = NotificationCommonService().get_notification_client()

    def background_task(self, user, user_of_crush, message, chat_message):
        fcm_tokens = list(models.FcmTokenMembership.objects.filter(
            user=user_of_crush
        ).values_list('fcm_token', flat=True))

        self.client.send_notification(
            tokens=fcm_tokens,
            title='******' + user_of_crush.phone_number[-3:],
            body=message,
            data=dict(
                id=str(chat_message.id),
                sender_id=str(user.id),
                status=models.ChatMessage.Status.RECEIVED,
                message=chat_message.message,
                start_at=str(chat_message.start_at),
                type='chat',
            ),
        )

    def send_message(
        self,
        user: models.NinepmUser,
        receiver_id: int,
        message: str,
    ):
        user_of_crush = models.NinepmUser.objects.get(id=receiver_id)

        chat_message = models.ChatMessage.objects.create(
            my_user=user,
            user_of_crush=user_of_crush,
            status=models.ChatMessage.Status.SENT,
            message=message,
            start_at=timezone.now(),
        )

        my_thread = threading.Thread(
            target=self.background_task,
            args=[user, user_of_crush, message, chat_message])
        my_thread.start()
