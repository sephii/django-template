# Django template for the modern developer

This is a Django project template preconfigured with:

* [Django 4](https://www.djangoproject.com/)
* [Wagtail CMS](https://wagtail.org/) (optional)
* Basic dev tools ([django-debug-toolbar](https://github.com/jazzband/django-debug-toolbar/), [django-extensions](https://github.com/django-extensions/django-extensions/))
* [Pytest](https://docs.pytest.org/) & [pytest-cov](https://pypi.org/project/pytest-cov/)
* [TailwindCSS](https://tailwindcss.com/)
* Assets compilation with [Vite](https://vitejs.dev/) (using [django-vite](https://github.com/MrBin99/django-vite))
* [Poetry](https://python-poetry.org/)
* [Direnv](https://github.com/direnv/direnv) integration
* [Nix](https://nixos.org/) packaging
* Custom user model (optional)

To create a new project using this template, install [cookiecutter](https://github.com/cookiecutter/cookiecutter), then run:

    cookiecutter gh:sephii/django-template

Make sure to initialize a git repository in your newly created project directory
(`cd my_project; git init; git add .`), and follow the instructions in the
generated `README.md` file.

If you plan to deploy your site on NixOS, have a look at
[django.nix](https://github.com/sephii/django.nix)!
