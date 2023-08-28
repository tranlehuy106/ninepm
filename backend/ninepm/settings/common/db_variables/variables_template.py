CACHES_DEFAULT = {
    'BACKEND': 'django_redis.cache.RedisCache',
    'LOCATION': 'redis://172.26.4.2:6379/',
    'OPTIONS':
        {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            # 'PASSWORD': '',
            'DB': 0,
        }
}

DB_NINE_VALUE = {
    'ENGINE': 'django.db.backends.mysql',
    'NAME': 'ninepm',
    'USER': 'admin',
    'PASSWORD': '123456',
    'HOST': '127.0.0.1',
    'PORT': '3306',
    'OPTIONS':
        {
            'charset': 'utf8mb4',
            'init_command':
                "SET default_storage_engine=INNODB; \
                    SET sql_mode='STRICT_TRANS_TABLES'; \
                    SET collation_connection=utf8mb4_unicode_520_ci;"
        },
}