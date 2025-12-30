# If you wish to have any additional dev packages installed, add them to this list
{ python }:
with python.pkgs;
(import ./requirements.nix { inherit python; })
++ [
  django-extensions
  django-debug-toolbar
  ipython
  isort
  pytest
  pytest-cov
  pytest-django
]
