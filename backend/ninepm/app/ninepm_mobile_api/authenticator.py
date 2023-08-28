__all__ = [
    'Authenticator',
    'AuthTokenType',
]

import json
import uuid

import rest_framework.authentication as rest_authentication
import rest_framework.exceptions as rest_exceptions

from enum import unique, auto

from django.contrib import auth

from common.clients import redis
from common.enum.constants import StringConstant

from ninepm.app.ninepm_mobile_api.utils import conf


@unique
class AuthTokenType(StringConstant):
    PERSISTENT = auto()
    SESSION = auto()


class Authenticator(rest_authentication.BaseAuthentication):
    @unique
    class ResponseCode(StringConstant):
        AUTH_TOKEN_NOT_FOUND = auto()
        CANNOT_PARSE_AUTH_DATA = auto()
        INVALID_AUTH_DATA = auto()
        USER_ID_IS_NONE = auto()
        USER_NOT_FOUND = auto()

    def __init__(self) -> None:
        super().__init__()
        self.auth_user_model = auth.get_user_model()

    def authenticate_header(self, request):
        return 'Auth Token'

    def authenticate(self, request):
        auth_token_storage_conf = conf.get_auth_token_storage_conf()
        storage_engine = auth_token_storage_conf.engine.lower()
        if storage_engine == 'redis':
            return self.authenticate_with_redis(
                request=request, storage_conf=auth_token_storage_conf
            )

        raise NotImplementedError(
            'Token storage engine %s is not supported' % storage_engine
        )

    def authenticate_with_redis(self, request, storage_conf):
        auth_conf = conf.get_auth_conf()
        auth_token = request.headers.get(auth_conf.auth_header_name)
        if not auth_token:
            return None

        client = redis.RedisClientGenerator.get_client(
            conf.build_redis_client_config(storage_conf)
        )
        auth_raw_data = client.get(auth_token)

        if not auth_raw_data:
            raise rest_exceptions.AuthenticationFailed(
                dict(code=Authenticator.ResponseCode.AUTH_TOKEN_NOT_FOUND)
            )
        try:
            auth_data = json.loads(auth_raw_data.decode('utf-8'))
        except json.JSONDecodeError:
            raise rest_exceptions.AuthenticationFailed(
                dict(code=Authenticator.ResponseCode.CANNOT_PARSE_AUTH_DATA)
            )

        try:
            user_id = auth_data['user_id']
        except KeyError as e:
            raise rest_exceptions.AuthenticationFailed(
                dict(
                    code=Authenticator.ResponseCode.INVALID_AUTH_DATA,
                    details='Key %s not found' % e
                )
            )

        is_extending_auth_token_life = self.__is_extending_auth_token_life(
            auth_conf=auth_conf,
            token_remaining_life=client.ttl(auth_token),
        )
        if is_extending_auth_token_life:
            client.set(
                auth_token,
                json.dumps(dict(user_id=user_id)),
                self.__get_auth_token_max_age(
                    auth_conf=auth_conf
                )
            )

        return self.__get_user_by_id(user_id), dict(token=auth_token)

    def __get_user_by_id(self, user_id: int):
        try:
            return self.auth_user_model.objects.get(pk=user_id)
        except self.auth_user_model.DoesNotExist:
            raise rest_exceptions.AuthenticationFailed(
                dict(code=Authenticator.ResponseCode.USER_NOT_FOUND)
            )

    @staticmethod
    def register(user_id: int, token_type: AuthTokenType):
        auth_token_storage_conf = conf.get_auth_token_storage_conf()
        if auth_token_storage_conf.engine.lower() == 'redis':
            return Authenticator.register_with_redis(
                user_id=user_id,
                token_type=token_type,
                storage_conf=auth_token_storage_conf
            )

        raise NotImplementedError()

    @staticmethod
    def register_with_redis(
        user_id: int, token_type: AuthTokenType, storage_conf
    ):
        auth_conf = conf.get_auth_conf()
        client = redis.RedisClientGenerator.get_client(
            conf.build_redis_client_config(storage_conf)
        )

        def auth_token_max_age():
            return auth_conf.persistent_auth_token_max_age_in_sec

        token_max_age = auth_token_max_age()
        auth_token = '%s:%s' % (
            str(user_id), str(uuid.uuid4())
        )
        client.set(
            auth_token,
            json.dumps(dict(user_id=user_id, token_type=token_type)),
            token_max_age
        )

        return auth_token, token_max_age

    @staticmethod
    def deregister(token: str):
        auth_token_storage_conf = conf.get_auth_token_storage_conf()
        if auth_token_storage_conf.engine.lower() == 'redis':
            return Authenticator.deregister_with_redis(
                token=token, storage_conf=auth_token_storage_conf
            )

    @staticmethod
    def deregister_with_redis(token: str, storage_conf):
        client = redis.RedisClientGenerator.get_client(
            conf.build_redis_client_config(storage_conf)
        )
        client.delete(token)

    def __is_extending_auth_token_life(
        self, auth_conf, token_remaining_life
    ) -> bool:
        if not auth_conf.auto_extend_auth_token:
            return False
        auth_token_max_age = self.__get_auth_token_max_age(
            auth_conf=auth_conf
        )
        auto_extend_auth_token_interval = self.__get_auto_extend_auth_token_interval(
            auth_conf=auth_conf
        )
        if auth_token_max_age - auto_extend_auth_token_interval < token_remaining_life:
            return False

        return True

    def __get_auth_token_max_age(self, auth_conf):
        return auth_conf.persistent_auth_token_max_age_in_sec

    def __get_auto_extend_auth_token_interval(self, auth_conf):
        return auth_conf.auto_extend_persistent_auth_token_interval_in_sec
