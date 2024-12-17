{
  stdenv,
  callPackage,
  nodejs,
}:
let
  generated = callPackage ./nix { inherit nodejs; };
  nodeDependencies = generated.nodeDependencies;
in
{
  inherit nodeDependencies;

  static = stdenv.mkDerivation {
    name = "{{ cookiecutter.project_slug }}-assets";
    # It’s recessary to include the whole source so that Tailwind knows the classes in use
    src = ./..;
    buildInputs = [ nodejs ];
    buildPhase = ''
      cd assets
      ln -s ${nodeDependencies}/lib/node_modules ./node_modules
      export PATH="${nodeDependencies}/bin:$PATH"
      npm run build
    '';
    installPhase = ''
      cp -r dist $out/
    '';
  };
}
