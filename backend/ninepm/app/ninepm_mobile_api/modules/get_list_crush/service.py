__all__ = ['ViewService']

from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def get_list_crush(
        user: models.NinepmUser,
    ):
        crushes = models.Crush.objects.filter(
            my_user=user,
            status__in=[
                models.Crush.Status.NEW,
                models.Crush.Status.MATCHED,
            ],
        ).order_by('-id')

        lovers = models.Crush.objects.filter(
            my_user=user,
            status=models.Crush.Status.CONNECTING,
        ).order_by('-id')

        for lover in lovers:
            lover.status = models.Crush.Status.COMPLETED
            lover.save()

        return crushes, lovers
