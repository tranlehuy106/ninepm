__all__ = [
    "RedisClientGenerator"
]

import datetime
from typing import NamedTuple

import redis
from django.utils import timezone
from redis import ConnectionPool


class AbstractRedisClientGenerator:
    @staticmethod
    def get_client(config: dict) -> redis.Redis:
        raise NotImplementedError("get_client func not Implemented")


class PoolItem(NamedTuple):
    connection_pool: ConnectionPool
    created_at: datetime.datetime


class RedisClientGenerator(AbstractRedisClientGenerator):
    DEFAULT_CONFIG = dict(
        host='localhost',
        port=6379,
        db=0,
    )

    _pools = dict()

    @staticmethod
    def get_client(config: dict) -> redis.Redis:
        connection_config = RedisClientGenerator.__get_connection_config(config=config)
        return redis.Redis(**connection_config)

    @staticmethod
    def __get_connection_config(config) -> dict:
        now = timezone.now()
        serialized_config = RedisClientGenerator.__serialize(config=config)
        key = RedisClientGenerator.__build_key(serialized_config=serialized_config)
        if key not in RedisClientGenerator._pools:
            from redis import ConnectionPool
            connection_pool = ConnectionPool(**serialized_config)
            RedisClientGenerator._pools[key] = PoolItem(
                connection_pool=connection_pool,
                created_at=now,
            )
        return dict(connection_pool=RedisClientGenerator._pools[key].connection_pool)

    @staticmethod
    def __serialize(config):
        import copy
        _config = copy.deepcopy(RedisClientGenerator.DEFAULT_CONFIG)
        if 'host' in config:
            _config['host'] = config['host']
        if 'port' in config:
            _config['port'] = config['port']
        if 'password' in config:
            _config['password'] = config['password']
        if 'db' in config:
            _config['db'] = config['db']
        return _config

    @staticmethod
    def __build_key(serialized_config):
        return "%s_%s_%s" % (serialized_config['host'], serialized_config['port'], serialized_config['db'])
