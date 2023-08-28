__all__ = [
    "AbstractEnum"
]

from enum import Enum


class AbstractEnum(Enum):
    @classmethod
    def choices(cls):
        return [(tag.name, tag.value) for tag in cls]

    @classmethod
    def names(cls):
        return [tag.name for tag in cls]

    @classmethod
    def values(cls):
        return [tag.value for tag in cls]
