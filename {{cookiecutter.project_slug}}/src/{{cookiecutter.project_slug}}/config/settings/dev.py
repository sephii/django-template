from .base import *  # noqa

DEBUG = True
DEBUG_TOOLBAR_CONFIG = {"INTERCEPT_REDIRECTS": False}
MIDDLEWARE += ("debug_toolbar.middleware.DebugToolbarMiddleware",)  # noqa

SECRET_KEY = "notsosecret"
INTERNAL_IPS = ("127.0.0.1",)

INSTALLED_APPS += ("debug_toolbar", "django_extensions")  # noqa

LOGGING = {}

DJANGO_VITE = {"default": {"dev_mode": True}}
