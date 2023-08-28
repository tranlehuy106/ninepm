from django.core.management.base import BaseCommand
from django.utils import timezone

from common.services.notification.common import NotificationCommonService
from ninepm.common.models.model_ninepm import models


class Command(BaseCommand):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.client = NotificationCommonService().get_notification_client()

    # def send_message(
    #     self,
    #     user_id: int,
    #     receiver_id: int,
    #     message: str,
    # ):
    #     user = models.NinepmUser.objects.get(id=user_id)
    #     user_of_crush = models.NinepmUser.objects.get(id=receiver_id)
    #
    #     chat_message = models.ChatMessage.objects.create(
    #         my_user=user,
    #         user_of_crush=user_of_crush,
    #         status=models.ChatMessage.Status.SENT,
    #         message=message,
    #         start_at=timezone.now(),
    #     )
    #
    #     fcm_tokens = list(models.FcmTokenMembership.objects.filter(
    #         user=user_of_crush
    #     ).values_list('fcm_token', flat=True))
    #
    #     self.client.send_notification(
    #         tokens=fcm_tokens,
    #         title='******' + user_of_crush.phone_number[-3:],
    #         body=message,
    #         data=dict(
    #             id=str(chat_message.id),
    #             sender_id=str(user.id),
    #             status=models.ChatMessage.Status.RECEIVED,
    #             message=chat_message.message,
    #             start_at=str(chat_message.start_at),
    #             type='chat',
    #         ),
    #     )

    def handle(self, *args, **options):
        # self.send_message(
        #     user_id=1,
        #     receiver_id=2,
        #     message='ko có gì cả lần 4'
        # )
        # return

        crushes = models.Crush.objects.filter(
            status=models.Crush.Status.MATCHED
        )

        models.Crush.objects.filter(
            status=models.Crush.Status.MATCHED
        ).update(
            status=models.Crush.Status.CONNECTING,
            completed_at=timezone.now(),
        )

        fcm_token_all = []
        for crush in crushes:
            user = crush.crush_user
            fcm_tokens = list(models.FcmTokenMembership.objects.filter(
                user=user
            ).values_list('fcm_token', flat=True))

            for item in fcm_tokens:
                if item not in fcm_token_all:
                    fcm_token_all.append(item)

            self.client.send_notification(
                tokens=fcm_tokens,
                title='Xin chúc mừng!',
                body='Bạn và %s đã kết nối thành công với nhau.' % user.phone_number,
            )

        if len(fcm_token_all) > 0:
            self.client.send_notification(
                tokens=fcm_token_all,
                data=dict(
                    type='connected',
                ),
            )
