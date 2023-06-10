{ black, coreutils, bash, python, devenv, inputs, just, node2nix, nodejs, pkgs, ruff, nodeDependencies }: let
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
    process.implementation = "overmind";

    processes = {
      runserver.exec = "${coreutils}/bin/timeout 10 ${bash}/bin/bash -c 'until [ -S $DEVENV_STATE/postgres/.s.PGSQL.5432 ]; do sleep 1; done' && ${pythonDevEnv.interpreter} -m django runserver";
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
        ${node2nix}/bin/node2nix --development -l package-lock.json -c nix/default.nix -o nix/node-packages.nix -e nix/node-env.nix
      '';
    };

    packages = [
      black
      just
      nodejs
      ruff
      pythonDevEnv
    ];

    pre-commit.hooks = {
      black.enable = true;
      ruff = {
        enable = true;
        entry = pkgs.lib.mkForce "${ruff}/bin/ruff --fix";
      };
      nixfmt.enable = true;
    };
  }];
}
