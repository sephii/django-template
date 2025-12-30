{ python, devenv, inputs, pkgs, npmDeps }:
let
  pythonDevEnv = python.withPackages (ps: ps.{{ cookiecutter.project_slug }}-dev.propagatedBuildInputs);
in
devenv.lib.mkShell {
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

    # This process manager allows interaction with the processes' stdin
    process.manager.implementation = "mprocs";

    processes = {
      runserver.exec = "${pkgs.coreutils}/bin/timeout 30 ${pkgs.bash}/bin/bash -c 'until pg_isready -d {{ cookiecutter.project_slug }}; do sleep 1; done' && ${pythonDevEnv.interpreter} -m django runserver";

      vite.exec = "vite";
    };

    scripts = {
      vite.exec = ''
        cd $DEVENV_ROOT/src/assets
        rm -rf ./node_modules
        ln -s ${npmDeps}/node_modules
        ${npmDeps}/node_modules/.bin/vite --clearScreen false "$@"
      '';

      dj.exec = ''${pythonDevEnv.interpreter} -m django "$@"'';
    };

    packages = [
      pkgs.gettext
      pkgs.just
      pkgs.nodejs
      pkgs.pyright
      pkgs.ruff
      pythonDevEnv
    ];

    git-hooks.hooks = {
      ruff = {
        enable = true;
        entry = pkgs.lib.mkForce "${pkgs.ruff}/bin/ruff check --fix";
      };

      ruff-format.enable = true;

      nixfmt-rfc-style.enable = true;
    };
  }];
}
