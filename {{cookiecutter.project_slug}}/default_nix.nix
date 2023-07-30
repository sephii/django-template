{ buildPythonPackage, pythonPackages, assetsStatic }: buildPythonPackage {
  src = ./.;
  pname = "{{ cookiecutter.project_slug }}";
  version = "0.1.0";
  format = "pyproject";

  buildInputs = [
    pythonPackages.hatchling
  ];

  # Include the compiled assets in the package
  configurePhase = ''
    mkdir -p src/{{ cookiecutter.project_slug }}/static
    cp -r ${assetsStatic}/* src/{{ cookiecutter.project_slug }}/static
  '';

  passthru = { inherit (pythonPackages) python; };
}
