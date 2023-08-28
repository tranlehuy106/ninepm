__all__ = ['ViewService']

from django.utils import timezone

from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def __validate(
        user: models.NinepmUser,
        phone_number_of_crush: str
    ):
        if user.phone_number == phone_number_of_crush:
            raise NotImplementedError('Bạn không thể gửi cho chính bạn.')

    def send_love_messages(
        self,
        user: models.NinepmUser,
        phone_number_of_crush: str,
        reminiscent_name: str,
    ):
        self.__validate(user, phone_number_of_crush)

        is_exists = models.Crush.objects.filter(
            my_user=user,
            phone_number_of_crush=phone_number_of_crush,
            status__in=[
                models.Crush.Status.CONNECTING,
                models.Crush.Status.COMPLETED,
            ],
        ).exists()

        if is_exists is True:
            raise NotImplementedError('Số điện thoại này đã kết nối.')

        models.Crush.objects.filter(
            my_user=user,
            phone_number_of_crush=phone_number_of_crush,
            status__in=[
                models.Crush.Status.NEW,
                models.Crush.Status.MATCHED,
            ],
        ).delete()

        myself = models.Crush.objects.create(
            my_user=user,
            my_phone_number=user.phone_number,
            phone_number_of_crush=phone_number_of_crush,
            reminiscent_name=reminiscent_name,
            start_at=timezone.now(),
        )

        try:
            crush_user = models.NinepmUser.objects.get(
                phone_number=phone_number_of_crush
            )
        except models.NinepmUser.DoesNotExist:
            return

        update_count = models.Crush.objects.filter(
            my_phone_number=phone_number_of_crush,
            phone_number_of_crush=user.phone_number,
            status=models.Crush.Status.NEW,
        ).update(
            crush_user=user,
            status=models.Crush.Status.MATCHED,
            matched_at=timezone.now(),
        )

        if update_count > 0:
            myself.crush_user = crush_user
            myself.status = models.Crush.Status.MATCHED
            myself.save()
