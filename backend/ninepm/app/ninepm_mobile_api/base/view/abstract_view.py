__all__ = ["AbstractNinepmMobileView"]
from typing import Optional
from rest_framework.request import Request

from common.base.abstract_api_view import AbstractAPIView


class AbstractNinepmMobileView(AbstractAPIView):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    @staticmethod
    def _get_client_ip(request: Request):
        meta = request.META
        if 'HTTP_X_FORWARDED_FOR' in meta:
            ip = meta['HTTP_X_FORWARDED_FOR'].split(',')[0]
        elif 'HTTP_X_REAL_IP' in meta:
            ip = meta['HTTP_X_REAL_IP']
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip

    def _get_device_token(self, request: Request) -> Optional[str]:
        return request.headers.get(self.__get_device_token_header_name())

    @staticmethod
    def __get_device_token_header_name():
        from django.conf import settings
        from django.core.exceptions import ImproperlyConfigured
        try:
            return settings.NINEPM_MOBILE_CONFIG[
                'DEVICE_TOKEN_HEADER_NAME']
        except AttributeError as e:
            raise ImproperlyConfigured(
                "settings.NINEPM_MOBILE_CONFIG missing"
            )
        except KeyError as e:
            raise ImproperlyConfigured(
                "settings.NINEPM_MOBILE_CONFIG['DEVICE_TOKEN_HEADER_NAME'] missing"
            )
