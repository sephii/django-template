# {{ cookiecutter.project_name }}

This project has been created from [the following Cookiecutter template](https://github.com/sephii/django-template/).

It uses [Nix](https://nixos.org/) and [devenv](https://devenv.sh/).

To get a better idea how the whole thing works, check these files:

* [flake.nix](./flake.nix)
* [default.nix](./default.nix)
* [shell.nix](./shell.nix)
* [src/assets/default.nix](./src/assets/default.nix)

## Running it

To run this project locally, make sure [Nix](https://nixos.org/) and [direnv](https://github.com/direnv/direnv) are installed.

Then run `direnv allow` and start the different services by running:

```sh
devenv up
```

In another terminal, run the database migrations:

```sh
dj migrate
```

You should be able to access http://localhost:8000/ !

Note there is no `manage.py` file. All Django management commands must be run using the
`dj` command (use `dj --help` to see all available commands).
