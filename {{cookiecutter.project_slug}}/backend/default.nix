{ poetry, poetry2nix, {{ cookiecutter.project_slug }}, mkShell, python3, stdenv, writeShellScriptBin }:
let
  # Some packages have specific dependencies poetry2nix doesn’t seem to be aware of
  # If you get errors while building the main package, check which Python package is causing the problem and add any
  # missing dependency here
  poetryOverrides = poetry2nix.overrides.withDefaults (self: super: {
    # https://github.com/nix-community/poetry2nix/issues/568
    anyascii = super.anyascii.overridePythonAttrs (old: {
      buildInputs = old.buildInputs or [ ] ++ [ self.flit-core ];
    });

    django-debug-toolbar = super.django-debug-toolbar.overridePythonAttrs (old: {
      buildInputs = old.buildInputs or [ ] ++ [ self.hatchling ];
    });

    django-vite = super.django-vite.overridePythonAttrs (old: {
      buildInputs = old.buildInputs or [ ] ++ [ self.setuptools ];
    });

    packaging = super.packaging.overridePythonAttrs (old: {
      buildInputs = old.buildInputs or [ ] ++ [ self.flit-core ];
    });
    {% if cookiecutter.use_wagtail == "y" %}
    {% for pkg in [ "draftjs-exporter", "telepath", "l18n", "django-permissionedforms", "wagtail" ] %}
    {{ pkg }} = super.{{ pkg }}.overridePythonAttrs (old: {
      buildInputs = old.buildInputs or [ ] ++ [ self.setuptools ];
    });
    {% endfor %}
    {% endif %}
  });

  # The main app that is used when not in dev mode (for dev mode, see the `shell` derivation below)
  poetryApp = (poetry2nix.mkPoetryApplication {
    projectDir = ./.;
    # Copy static files generated by the frontend build process to our static files directory, so the files are then
    # picked up by the `collectstatic` phase (see the `static` derivation below)
    configurePhase = ''
      mkdir -p ./{{ cookiecutter.project_slug }}/static
      cp -r {{ '${' }}{{ cookiecutter.project_slug }}.frontend.static}/* ./{{ cookiecutter.project_slug }}/static
    '';
    overrides = poetryOverrides;
    python = python3;
  });

  # This is a derivation with all the static files resulting from Django’s `collectstatic`
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
in {
  inherit static;

  server = poetryApp.dependencyEnv;

  # That’s the environment used in development
  shell = mkShell {
    packages = [
      (poetry2nix.mkPoetryEnv {
        projectDir = ./.;
        editablePackageSources = { {{ cookiecutter.project_slug }} = ./{{ cookiecutter.project_slug }}; };
        overrides = poetryOverrides;
      })
      python3.pkgs.poetry
    ];

    # This allows running `django-admin` from the main directory without having to first cd into backend
    shellHook = ''
      export PYTHONPATH=$PYTHONPATH:$(git rev-parse --show-toplevel)/backend
    '';
  };
}