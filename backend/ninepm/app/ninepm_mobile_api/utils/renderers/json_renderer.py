__all__ = ['JSONRenderer']

from rest_framework.renderers import JSONRenderer as BaseJSONRender


class JSONRenderer(BaseJSONRender):
    charset = 'utf-8'
