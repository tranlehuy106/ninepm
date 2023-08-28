__all__ = [
    "AbstractApiService",
]

from common.base.abstract_service import AbstractService


class AbstractApiService(AbstractService):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
