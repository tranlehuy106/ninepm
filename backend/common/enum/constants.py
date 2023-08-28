__all__ = [
    'StringConstant',
    'ConstantValueError',
    'IntegerConstant',
]

from typing import Optional

from enum import EnumMeta, Enum


class _EnumDirectValueMeta(EnumMeta):

    def __getattribute__(cls, name):
        value = super().__getattribute__(name)
        if isinstance(value, cls):
            value = value.value
        return value

    def __getitem__(cls, name):
        return cls._member_map_[name].value

    def __iter__(cls):
        return (cls._member_map_[name].value for name in cls._member_names_)

    def __contains__(cls, value):
        return value in [
            cls._member_map_[name].value for name in cls._member_names_
        ]

    def _items(cls):
        return [cls._member_map_[name] for name in cls._member_names_]


class _AbstractConstantEnum(Enum, metaclass=_EnumDirectValueMeta):

    @classmethod
    def choices(cls):
        return [(item.name, item.value) for item in cls._items()]

    @classmethod
    def names(cls):
        return [item.name for item in cls._items()]

    @classmethod
    def values(cls):
        return [item.value for item in cls._items()]


class ConstantValueError(Exception):
    pass


class StringConstant(str, _AbstractConstantEnum):

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """make sure when declare auto() it will use the name as value"""
        return name

    @classmethod
    def from_str(cls, value: Optional[str]):
        if value is not None:
            for tag in cls:
                if tag == value:
                    return tag

        raise ConstantValueError()


class IntegerConstant(int, _AbstractConstantEnum):
    pass
