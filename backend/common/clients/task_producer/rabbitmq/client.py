__all__ = ["RabbitmqTaskProducerClient"]

from django.core.exceptions import ImproperlyConfigured

import logging
import pika
from common.clients.task_producer.client_interface import ITaskProducerClient


class RabbitmqTaskProducerClient(ITaskProducerClient):

    def __init__(self, config):
        super().__init__()
        self.__config = self.__get_connection_config_settings(config=config)
        self.__host = self.__get_host_settings(config=self.__config)
        self.__port = self.__get_port_settings(config=self.__config)
        self.__virtual_host = self.__get_virtual_host_settings(
            config=self.__config
        )
        self.__heartbeat = self.__get_heartbeat_settings(config=self.__config)
        self.__username = self.__get_username_settings(config=self.__config)
        self.__password = self.__get_password_settings(config=self.__config)
        self.__queue_name = self.__get_queue_name_settings(
            config=self.__config
        )

    def add_to_queue(self, byte_data: bytes):
        credentials = pika.PlainCredentials(
            username=self.__username, password=self.__password
        )
        parameters = pika.ConnectionParameters(
            host=self.__host,
            port=self.__port,
            virtual_host=self.__virtual_host,
            credentials=credentials,
            heartbeat=self.__heartbeat
        )
        connection = pika.BlockingConnection(parameters=parameters)
        channel = connection.channel()

        # make queue persistent
        channel.queue_declare(queue=self.__queue_name, durable=True)

        # make task persistent
        channel.basic_publish(
            exchange='',
            routing_key=self.__queue_name,
            body=byte_data,
            properties=pika.BasicProperties(
                delivery_mode=pika.spec.PERSISTENT_DELIVERY_MODE,
            )
        )
        logging.debug(" [x] Sent %s" % byte_data)
        connection.close()

    def __get_connection_config_settings(self, config) -> str:
        return self.__get_value_of_config(
            config=config, key='CONNECTION_CONFIG'
        )

    def __get_host_settings(self, config) -> str:
        return self.__get_value_of_config(config=config, key='HOST')

    def __get_port_settings(self, config) -> int:
        return self.__get_value_of_config(config=config, key='PORT')

    def __get_virtual_host_settings(self, config) -> str:
        return self.__get_value_of_config(config=config, key='VIRTUAL_HOST')

    def __get_heartbeat_settings(self, config) -> str:
        return self.__get_value_of_config(config=config, key='HEARTBEAT')

    def __get_username_settings(self, config) -> str:
        return self.__get_value_of_config(config=config, key='USERNAME')

    def __get_password_settings(self, config) -> str:
        return self.__get_value_of_config(config=config, key='PASSWORD')

    def __get_queue_name_settings(self, config) -> str:
        return self.__get_value_of_config(config=config, key='QUEUE_NAME')

    def __get_value_of_config(self, config, key):
        try:
            return config[key]
        except KeyError:
            raise ImproperlyConfigured("%s config missing" % key)
