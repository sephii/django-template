{ {{ cookiecutter.project_slug }}, stdenv, python }: stdenv.mkDerivation {
  pname = "${{ '{' }}{{ cookiecutter.project_slug }}.pname}-static";
  version = {{ cookiecutter.project_slug }}.version;
  src = ./.;
  buildPhase = ''
    export STATIC_ROOT=$out
    export MEDIA_ROOT=/dev/null
    export DJANGO_SETTINGS_MODULE={{ cookiecutter.project_slug }}.config.settings.base
    export SECRET_KEY=dummy
    export DATABASE_URL=sqlite:////dev/null
    export ALLOWED_HOSTS=
    ${
      (python.withPackages
        (ps: [ ps.{{ cookiecutter.project_slug }} ])).interpreter
    } -m django collectstatic --noinput
  '';
  phases = [ "buildPhase" ];
}
