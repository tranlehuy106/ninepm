from abc import abstractmethod


class ITaskProducerClient:

    @abstractmethod
    def add_to_queue(self, byte_data: bytes):
        pass
