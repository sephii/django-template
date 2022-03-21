from . import get_env_variable
from .base import *  # noqa

DEBUG = bool(get_env_variable("DEBUG", True))
DEBUG_TOOLBAR_CONFIG = {"INTERCEPT_REDIRECTS": False}
MIDDLEWARE += ("debug_toolbar.middleware.DebugToolbarMiddleware",)  # noqa

SECRET_KEY = "notsosecret"
INTERNAL_IPS = ("127.0.0.1",)

INSTALLED_APPS += ("debug_toolbar", "django_extensions")  # noqa

LOGGING = {}

DJANGO_VITE_ASSETS_PATH = os.path.join(BASE_DIR, "..", "frontend", "dist")
STATICFILES_DIRS = get_env_variable("STATICFILES_DIRS", DJANGO_VITE_ASSETS_PATH).split(",")
DJANGO_VITE_DEV_MODE = True
