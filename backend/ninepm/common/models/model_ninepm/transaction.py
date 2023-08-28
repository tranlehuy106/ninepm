from django.db.transaction import Atomic
from django.conf import settings, ImproperlyConfigured


def atomic(using=None, savepoint=True, durable=False):
    # Bare decorator: @atomic -- although the first argument is called
    # `using`, it's actually the function being decorated.
    db = get_database()
    if using is None:
        using = db
    if callable(using):
        return Atomic(db, savepoint, durable)(using)
    # Decorator: @atomic(...) or context manager: with atomic(...): ...
    else:
        return Atomic(using, savepoint, durable)


def get_database():
    try:
        return settings.NINEPM_DB
    except AttributeError as e:
        raise ImproperlyConfigured("settings.NINEPM_DB missing")
