{
  buildPythonPackage,
  python,
  gettext,
  assetsStatic,
  devDependencies ? false,
}:
buildPythonPackage {
  src = ./.;
  pname = "{{ cookiecutter.project_slug }}";
  version = "0.1.0";
  format = "pyproject";

  buildInputs = [
    python.pkgs.hatchling
    gettext
  ];

  propagatedBuildInputs =
    import (if !devDependencies then ./requirements.nix else ./requirements_dev.nix)
      {
        inherit python;
      };

  passthru = { inherit python; };

  # Include the compiled assets in the package and compile messages
  configurePhase = ''
    mkdir -p src/{{ cookiecutter.project_slug }}/static
    cp -r ${assetsStatic}/* src/{{ cookiecutter.project_slug }}/static

    export PATH=$PATH:${gettext}/bin
    python -m django compilemessages
  '';
}
