{ poetry2nix, python, assetsStatic, groups ? [ ] }:
let
  # Some packages have specific dependencies poetry2nix doesn’t seem to be aware of.
  # If you get errors while building the main package, check which Python package is
  # causing the problem and add any missing dependency here
  poetryOverrides = poetry2nix.overrides.withDefaults (self: super: {
    # https://github.com/nix-community/poetry2nix/issues/568
    anyascii = super.anyascii.overridePythonAttrs (old: {
      buildInputs = old.buildInputs or [ ] ++ [ self.flit-core ];
    });

    sqlparse = super.sqlparse.overridePythonAttrs (old: {
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
in poetry2nix.mkPoetryApplication {
  inherit python groups;

  projectDir = ./.;

  # Include the compiled assets in the package
  configurePhase = ''
    mkdir -p ./{{ cookiecutter.project_slug }}/static
    cp -r ${assetsStatic}/* ./{{ cookiecutter.project_slug }}/static
  '';

  overrides = poetryOverrides;
}
