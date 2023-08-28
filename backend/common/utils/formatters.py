from decimal import Decimal


def decimal_to_string(number: Decimal) -> str:
    """
    Convert decimal to string, remove unecessary 0
    :param number: Decimal
    :return: formatted_number: str

    decimal_to_string(Decimal(1)) -> '1'
    decimal_to_string(Decimal(1.00)) -> '1'

    decimal_to_string(Decimal(01)) -> '1'

    decimal_to_string(Decimal(1.0003)) -> '1.0003'
    decimal_to_string(Decimal(1.0003000)) -> '1.0003'
    """
    str_number = str(number)
    formatted_number = str_number.rstrip('0').rstrip('.') \
        if '.' in str_number else str_number
    return formatted_number
