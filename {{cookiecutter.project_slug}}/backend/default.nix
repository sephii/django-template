{ poetry, poetry2nix, {{ cookiecutter.project_slug }}, mkShell, python3Packages, stdenv, writeShellScriptBin }:
let
  poetryApp = (poetry2nix.mkPoetryApplication {
    projectDir = ./.;
    configurePhase = ''
      mkdir -p ./{{ cookiecutter.project_slug }}/static
      cp -r {{ '${' }}{{ cookiecutter.project_slug }}.frontend.static}/* ./{{ cookiecutter.project_slug }}/static
    '';
  });

  static = stdenv.mkDerivation {
    pname = "${poetryApp.pname}-static";
    version = poetryApp.version;
    src = ./.;
    buildPhase = ''
      export STATIC_ROOT=$out
      export MEDIA_ROOT=/dev/null
      export DJANGO_SETTINGS_MODULE={{ cookiecutter.project_slug }}.config.settings.base
      export SECRET_KEY=dummy
      export DATABASE_URL=sqlite:////dev/null
      export STATICFILES_DIRS={{ '${' }}{{ cookiecutter.project_slug }}.frontend.static}
      ${poetryApp.dependencyEnv}/bin/django-admin collectstatic --noinput
    '';
    phases = [ "buildPhase" ];
  };

  django = writeShellScriptBin "django"
    ''
    PYTHONPATH=$PYTHONPATH:$(git rev-parse --show-toplevel)/backend python -m django $@
    '';
in rec {
  server = poetryApp.dependencyEnv;

  shell = mkShell {
    packages = [
      (poetry2nix.mkPoetryEnv {
        projectDir = ./.;
        editablePackageSources = { {{ cookiecutter.project_slug }} = ./{{ cookiecutter.project_slug }}; };
      })
      django
      python3Packages.poetry
    ];
  };
}
