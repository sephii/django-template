{ buildPythonPackage, pythonPackages, gettext, assetsStatic, devDependencies ? false }: buildPythonPackage {
  src = ./.;
  pname = "{{ cookiecutter.project_slug }}";
  version = "0.1.0";
  format = "pyproject";

  buildInputs = [ pythonPackages.hatchling gettext ];

  propagatedBuildInputs = import (if !devDependencies then ./requirements.nix else ./requirements_dev.nix) {
    inherit pythonPackages;
  };

  passthru.python = pythonPackages.python;

  # Include the compiled assets in the package and compile messages
  configurePhase = ''
    mkdir -p src/{{ cookiecutter.project_slug }}/static
    cp -r ${assetsStatic}/* src/{{ cookiecutter.project_slug }}/static

    export PATH=$PATH:${gettext}/bin
    python -m django compilemessages
  '';
}
