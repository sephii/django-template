# {{ cookiecutter.project_name }}

This project has been created from [the following Cookiecutter template](https://github.com/sephii/django-template/).

It uses [Nix](https://nixos.org/) and [direnv](https://github.com/direnv/direnv).

To get a better idea how the whole thing works, check these files:

* [flake.nix](./flake.nix)
* [backend/default.nix](./backend/default.nix)
* [frontend/default.nix](./frontend/default.nix)
* [default.nix](./default.nix)

## Running it

To run this project locally, install [Nix](https://nixos.org/) and [direnv](https://github.com/direnv/direnv).

Then configure the database connection and allow direnv to run:

``` sh
echo 'export DATABASE_URL="sqlite:///example.db"' > .envrc.local
direnv allow
```

Run the database migrations:

``` sh
python -m django migrate
```

Now use `nix run` to start the Django development server and Vite (which watches JS & CSS files):

``` sh
nix run
```

You should be able to access http://localhost:8000/ !

Note: you can also run each server individually if you prefer that over having a tmux window with both the frontend and
the backend server:

``` sh
server-back
server-front
```

## Deploying it

Check out the django.nix example to see how this project can be deployed on NixOS.
