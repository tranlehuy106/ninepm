__all__ = [
    "CommandAbstractService",
]

from common.base.abstract_service import AbstractService


class CommandAbstractService(AbstractService):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
