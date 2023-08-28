import django.conf as django_conf

from ninepm.app.ninepm_mobile_api.dtos.auth_conf import AuthConfig, \
    AuthTokenStorageConfig


def get_auth_conf() -> AuthConfig:
    attr_name = 'AUTH_CONFIG'
    try:
        config = django_conf.settings.AUTH_CONFIG
    except AttributeError:
        raise django_conf.ImproperlyConfigured(
            'settings.%s not found' % attr_name
        )

    def value(key: str, **kwargs):
        try:
            return config[key]
        except KeyError:
            if 'default' in kwargs:
                return kwargs['default']
            raise django_conf.ImproperlyConfigured(
                'settings.%s["%s"] not found' % (attr_name, key)
            )

    if value('PERSISTENT_AUTH_TOKEN_MAX_AGE'
             ) <= value('PERSISTENT_AUTH_TOKEN_AUTO_EXTEND_AFTER'):
        raise django_conf.ImproperlyConfigured(
            'PERSISTENT_AUTH_TOKEN_MAX_AGE must be greater than PERSISTENT_AUTH_TOKEN_AUTO_EXTEND_AFTER'
        )

    return AuthConfig(
        auth_header_name=value('AUTH_HEADER_NAME'),
        persistent_auth_token_max_age_in_sec=value(
            'PERSISTENT_AUTH_TOKEN_MAX_AGE'
        ),
        auto_extend_auth_token=value('AUTH_TOKEN_AUTO_EXTEND'),
        auto_extend_persistent_auth_token_interval_in_sec=value(
            'PERSISTENT_AUTH_TOKEN_AUTO_EXTEND_AFTER'
        ),
    )


def get_auth_token_storage_conf():
    try:
        storage_config = django_conf.settings.AUTH_CONFIG['AUTH_TOKEN_STORAGE']
    except AttributeError:
        raise django_conf.ImproperlyConfigured(
            'settings.AUTH_CONFIG not found'
        )
    except KeyError:
        raise django_conf.ImproperlyConfigured(
            'settings.AUTH_CONFIG["AUTH_TOKEN_STORAGE"] not found'
        )

    def value(key: str, **kwargs):
        try:
            return storage_config[key]
        except KeyError:
            if 'default' in kwargs:
                return kwargs['default']
            raise django_conf.ImproperlyConfigured(
                'settings.AUTH_CONFIG["AUTH_TOKEN_STORAGE"]["%s"] not found' %
                key
            )

    return AuthTokenStorageConfig(
        engine=value('ENGINE'),
        host=value('HOST'),
        port=value('PORT'),
        password=value('PASSWORD', default=None),
        db=value('DB'),
    )


def build_redis_client_config(storage_conf: AuthTokenStorageConfig):
    if storage_conf.password is None:
        return dict(
            host=storage_conf.host,
            port=storage_conf.port,
            db=storage_conf.db,
        )

    return dict(
        host=storage_conf.host,
        port=storage_conf.port,
        password=storage_conf.password,
        db=storage_conf.db,
    )
