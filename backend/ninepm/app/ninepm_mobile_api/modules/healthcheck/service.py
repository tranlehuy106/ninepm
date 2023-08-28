__all__ = ['ViewService']

from .dto import HealthCheckResponse
from ninepm.app.ninepm_mobile_api.base.services.abstract_api_service import \
    AbstractApiService


class ViewService(AbstractApiService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def check() -> HealthCheckResponse:
        return HealthCheckResponse(is_ok=True)
