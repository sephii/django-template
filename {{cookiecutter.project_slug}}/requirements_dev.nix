# If you wish to have any additional dev packages installed, add them to this list
{ pythonPackages }: with pythonPackages;
  (import ./requirements.nix { inherit pythonPackages; }) ++ [
  django-extensions
  django-debug-toolbar
  ipython
  isort
  pytest
  pytest-cov
  pytest-django
]
