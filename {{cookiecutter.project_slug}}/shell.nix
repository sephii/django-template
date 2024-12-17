{ python, devenv, inputs, pkgs, nodeDependencies }: let
  pythonDevEnv = python.withPackages (ps: ps.{{ cookiecutter.project_slug }}-dev.propagatedBuildInputs);
in devenv.lib.mkShell {
  inherit inputs pkgs;

  modules = [{
    # Allow invoking Django commands directly from the root directory
    enterShell = ''
      export PYTHONPATH=$PYTHONPATH:$DEVENV_ROOT/src
    '';

    services = {
      postgres = {
        enable = true;
        initialDatabases = [{ name = "{{ cookiecutter.project_slug }}"; }];
      };

      mailhog.enable = true;
    };

    # overmind supports input with `overmind c`, allowing us to use pdb
    process.manager.implementation = "overmind";

    processes = {
      runserver.exec = "${pkgs.coreutils}/bin/timeout 30 ${pkgs.bash}/bin/bash -c 'until pg_isready -d {{ cookiecutter.project_slug }}; do sleep 1; done' && ${pythonDevEnv.interpreter} -m django runserver";

      vite.exec = "vite";
    };

    scripts = {
      vite.exec = ''
        cd $DEVENV_ROOT/src/assets
        rm -rf ./node_modules
        ln -s ${nodeDependencies}/lib/node_modules
        ${nodeDependencies}/bin/vite --clearScreen false "$@"
      '';

      dj.exec = ''${pythonDevEnv.interpreter} -m django "$@"'';

      node2nix.exec = ''
        cd $DEVENV_ROOT/src/assets
        ${pkgs.node2nix}/bin/node2nix --development -l package-lock.json -c nix/default.nix -o nix/node-packages.nix -e nix/node-env.nix
      '';
    };

    packages = [
      pkgs.gettext
      pkgs.just
      pkgs.nodejs
      pkgs.ruff
      pythonDevEnv
    ];

    pre-commit.hooks = {
      ruff = {
        enable = true;
        entry = pkgs.lib.mkForce "${pkgs.ruff}/bin/ruff check --fix";
      };

      ruff-format.enable = true;

      nixfmt-rfc-style.enable = true;
    };
  }];
}
