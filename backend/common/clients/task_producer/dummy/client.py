__all__ = ['DummyTaskProducerClient']
from common.clients.task_producer.client_interface import ITaskProducerClient


class DummyTaskProducerClient(ITaskProducerClient):

    def __init__(self, config):
        super().__init__()

    def add_to_queue(self, *args, **kwargs):
        return
