from datetime import datetime, date, time, timedelta

import pytz


class VietnamDatetimeHelper:
    VIETNAM_TIMEZONE_NAME = 'Asia/Ho_chi_minh'

    @staticmethod
    def get_timezone():
        return pytz.timezone(VietnamDatetimeHelper.VIETNAM_TIMEZONE_NAME)

    @staticmethod
    def now():
        """return now in vietnam timezone"""
        return datetime.now(tz=VietnamDatetimeHelper.get_timezone())

    @staticmethod
    def today():
        """return today date in vietnam timezone"""
        return VietnamDatetimeHelper.now().date()

    @staticmethod
    def strptime(date_string, format):
        """parse a string into a datetime in vietnam timezone"""
        naive_datetime = datetime.strptime(date_string, format)
        return VietnamDatetimeHelper.get_timezone().localize(naive_datetime)

    @staticmethod
    def localize(naive_datetime):
        return VietnamDatetimeHelper.get_timezone().localize(naive_datetime)

    @staticmethod
    def to_vietnam_timezone(tz_aware_datetime: datetime):
        return tz_aware_datetime.astimezone(tz=VietnamDatetimeHelper.get_timezone())

    @staticmethod
    def today_from_utc_now(utc_now):
        return VietnamDatetimeHelper.to_vietnam_timezone(utc_now).date()

    @staticmethod
    def begin_of_day(a_date: date):
        return VietnamDatetimeHelper.localize(datetime.combine(a_date, time.min))

    @staticmethod
    def end_of_day(a_date: date):
        return VietnamDatetimeHelper.localize(datetime.combine(a_date, time.max))


class UtcDatetimeHelper:

    @staticmethod
    def get_timezone():
        return pytz.utc

    @staticmethod
    def now():
        """return now in utc timezone"""
        return datetime.now(tz=pytz.utc)

    @staticmethod
    def localize(naive_datetime):
        return UtcDatetimeHelper.get_timezone().localize(naive_datetime)

    @staticmethod
    def begin_of_day(a_date: date):
        return UtcDatetimeHelper.localize(datetime.combine(a_date, time.min))

    @staticmethod
    def end_of_day(a_date: date):
        return UtcDatetimeHelper.localize(datetime.combine(a_date, time.max))

    @staticmethod
    def to_utc_timezone(tz_aware_datetime: datetime):
        return tz_aware_datetime.astimezone(tz=UtcDatetimeHelper.get_timezone())


class DatetimeHelper:
    @staticmethod
    def is_naive_datetime(input_datetime: datetime) -> bool:
        if input_datetime.tzinfo is None:
            return True

        if input_datetime.tzinfo.utcoffset(input_datetime) is None:
            return True

        return False

    @staticmethod
    def daterange(start: datetime, end: datetime):
        if start == end: yield start
        for i in range(int((end - start).days)):
            yield start + timedelta(i)
