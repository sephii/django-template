{
  stdenv,
  callPackage,
  nodejs,
  importNpmLock,
}:
let
  npmDeps = importNpmLock.buildNodeModules {
    npmRoot = ./.;
    inherit nodejs;
  };
in
{
  inherit npmDeps;

  static = stdenv.mkDerivation {
    name = "{{ cookiecutter.project_slug }}-assets";
    # It’s recessary to include the whole source so that Tailwind knows the classes in use
    src = ./..;
    buildInputs = [ nodejs ];
    buildPhase = ''
      cd assets
      ln -sf ${npmDeps}/node_modules
      ${npmDeps}/node_modules/.bin/vite build
    '';
    installPhase = ''
      cp -r dist $out/
    '';
  };
}
