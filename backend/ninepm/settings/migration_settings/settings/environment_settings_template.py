from ninepm.settings.common import (DB_NINE_VALUE)

DATABASES = dict(default={}, ninepm=DB_NINE_VALUE)

NINEPM_DB = 'ninepm'
DATABASE_ROUTERS = [
    'ninepm.common.models.model_ninepm.database_routers.NinepmRouter',
]
