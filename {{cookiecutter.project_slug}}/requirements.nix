# Base dependencies: if you need any other package for your project, add them to this list
{ pythonPackages }: with pythonPackages; [
  django
  django-environ
  psycopg2
  django-vite
  {% if cookiecutter.use_wagtail == "y" %}
  wagtail
  {% endif %}
]
