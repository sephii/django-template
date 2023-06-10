# {{ cookiecutter.project_name }}

This project has been created from [the following Cookiecutter template](https://github.com/sephii/django-template/).

It uses [Nix](https://nixos.org/) and [devenv](https://devenv.sh/).

To get a better idea how the whole thing works, check these files:

* [flake.nix](./flake.nix)
* [default.nix](./default.nix)
* [shell.nix](./shell.nix)
* [src/assets/default.nix](./src/assets/default.nix)

## Running it

To run this project locally, install [Nix](https://nixos.org/) and [devenv](https://devenv.sh/).

Then run the project by running:

```sh
devenv up
```

In another terminal, run the database migrations:

``` sh
dj migrate
```

You should be able to access http://localhost:8000/ !
