import django.views.static
from django.conf import settings
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.urls import include, path
from django.views.generic import TemplateView

{%- if cookiecutter.use_wagtail == 'y' %}
from wagtail.admin import urls as wagtailadmin_urls
from wagtail import urls as wagtail_urls
from wagtail.documents import urls as wagtaildocs_urls
{% endif -%}

admin.autodiscover()

urlpatterns = [
    path("", TemplateView.as_view(template_name="base.html")),
    path("super/", admin.site.urls),
    {%- if cookiecutter.use_wagtail == 'y' %}
    path("cms/", include(wagtailadmin_urls)),
    path("documents/", include(wagtaildocs_urls)),
    path("", include(wagtail_urls)),
    {%- endif %}
]

if settings.DEBUG:
    import debug_toolbar

    urlpatterns = (
        [
            path(
                "media/<path:path>/",
                django.views.static.serve,
                {"document_root": settings.MEDIA_ROOT, "show_indexes": True},
            ),
            path("__debug__/", include(debug_toolbar.urls)),
        ]
        + staticfiles_urlpatterns()
        + urlpatterns
    )
