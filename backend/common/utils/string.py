import re

from django.utils.crypto import get_random_string


def is_blank(input: str) -> bool:
    return not (input and input.strip())


def remove_accents(input_str: str) -> str:
    s1 = u'ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝàáâãèéêìíòóôõùúýĂăĐđĨĩŨũƠơƯưẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặẸẹẺẻẼẽẾếỀềỂểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪừỬửỮữỰựỲỳỴỵỶỷỸỹ'
    s0 = u'AAAAEEEIIOOOOUUYaaaaeeeiioooouuyAaDdIiUuOoUuAaAaAaAaAaAaAaAaAaAaAaAaEeEeEeEeEeEeEeEeIiIiOoOoOoOoOoOoOoOoOoOoOoOoUuUuUuUuUuUuUuYyYyYyYy'

    s = ''
    input_str.encode('utf-8')
    for c in input_str:
        if c in s1:
            s += s0[s1.index(c)]
        else:
            s += c
    return s


def remove_special_characters(input_str: str) -> str:
    return re.sub('[^A-Za-z0-9 ]+', '', input_str)


def get_random_readable_string(length: int, prefix: str = '') -> str:
    return prefix + get_random_string(
        length, 'ABCDEFGHIKLMNOPQRSTUVWXYZ0123456789'
    )
