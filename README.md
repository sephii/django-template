# Django template for the modern developer

This is a Django project template preconfigured with:

* Vital dev tools ([django-debug-toolbar](https://github.com/jazzband/django-debug-toolbar/), [django-extensions](https://github.com/django-extensions/django-extensions/))
* Linting enforced with pre-commit hooks with [ruff](https://github.com/charliermarsh/ruff) & [Black](https://github.com/psf/black)
* Testing with [pytest](https://docs.pytest.org/) & [pytest-cov](https://pypi.org/project/pytest-cov/)
* Quick styling with [TailwindCSS](https://tailwindcss.com/)
* Assets compilation with [Vite](https://vitejs.dev/) (using [django-vite](https://github.com/MrBin99/django-vite))
* Fast, transparent & reproducible development setup with [Direnv](https://direnv.net/) & [Devenv](https://devenv.sh/)
* Packaging & dependency management with [Nix](https://nixos.org/) or [Poetry](https://python-poetry.org/)
* Command execution with [just](https://just.systems/)
* Mail preview with [Mailhog](https://github.com/mailhog/MailHog)
* [Wagtail CMS](https://wagtail.org/) (optional)
* Custom user model (optional)

This template allows you to get a working Django project with a reproducible dev
setup in 40 seconds! See for yourself:

[![asciicast](https://asciinema.org/a/MKghHwn6URYEGeHm0I3Z1uJqY.svg)](https://asciinema.org/a/MKghHwn6URYEGeHm0I3Z1uJqY)

## Usage

To create a new project using this template, you will first need to install:

* [Nix](https://github.com/DeterminateSystems/nix-installer)
* [Direnv](https://github.com/direnv/direnv)

Once you have these tools installed, run:

```sh
nix run nixpkgs#cookiecutter gh:sephii/django-template
```

Make sure to initialize a git repository in your newly created project directory
(`cd my_project; git init; git add .`), and follow the instructions in the
generated `README.md` file.

If you plan to deploy your site on NixOS, have a look at
[django.nix](https://github.com/sephii/django.nix)!

## How to…

### Add/remove dependencies

If you’re using Poetry, make the necessary changes to `pyproject.toml` and run `direnv reload`.

If you’re using Nix packaging, make the necessary changes to `requirements.nix`
or `requirements_dev.nix` (search for packages with `nix search nixpkgs mypackage`)
and run `direnv reload`.

### Use a specific Python version for development

Open `flake.nix` and change the Python package used. For example to use Python 3.11, change:

```
python = pkgs': pkgs'.python3;
```

To:

```
python = pkgs': pkgs'.python311;
```

### Use a specific version of a package

If you’re using Poetry, set the version directly in `pyproject.toml` and run `direnv reload`.

If you’re using Nix packaging, set the package version in
`pythonPackagesExtensions` in `flake.nix`. For example to use a specific Django
version:

```nix
pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
  (python-final: python-prev: {
    # my_project = drvWithDeps ./requirements.nix;
    # my_project-dev = drvWithDeps ./requirements_dev.nix;

    django = python-prev.django_4.overridePythonAttrs (old: rec {
      version = "4.0.8";

      src = python-final.fetchPypi {
        pname = "Django";
        inherit version;
        # To get the hash, use `nix-prefetch-url` with the URL of the package on PyPI
        hash = "sha256-B+ZDPyY8ODmTnPq+ttdVeEHgQZ5HdZp7fTf21E1Arcs=";
      };
    });
  })
]
```

### Install an NPM package

``` sh
cd src/assets
npm i --save --package-lock-only mypackage
node2nix
direnv reload
```

You might get an error when running `npm` related to the presence of
`node_modules/.package-lock.json`. If that’s the case, remove the `node_modules`
symlink and try again.

### Deploy to a NixOS server

Use the provided `nixos.nix` NixOS module. Here is a sample `flake.nix` file
using the provided NixOS module:

``` nix
{
  inputs.myproject.url = "github:exampleorg/exampleproject";

  outputs = { self, nixpkgs, myproject }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ myproject.overlays.default ];
    };
  in {
    nixosConfigurations.myserver = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        myproject.nixosModules.default
        {
          services.myproject = {
            enable = true;
            package = pkgs.python3.pkgs.myproject;
            staticFilesPackage = pkgs.myproject-static;
            user = "myproject";
            group = "myproject";

            appServer = {
              enable = true;
            };

            webServer = {
              enable = true;
              hostName = "www.example.com";
            };

            environmentFiles = [
              # Use a secure way to create a file with your database url and secret key, eg. https://github.com/ryantm/agenix
            ];
          };

          services.postgresql = {
            enable = true;
            ensureDatabases = [ "myproject" ];
            ensureUsers = [{ name = "myproject"; ensurePermissions = { "DATABASE myproject" = "ALL PRIVILEGES"; }; }];
          };
        }
      ];
    };
  };
}
```
