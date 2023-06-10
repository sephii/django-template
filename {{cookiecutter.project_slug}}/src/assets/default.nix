{ stdenv, callPackage, nodePackages, nodejs, writeShellScriptBin }:
let
  generated = callPackage ./nix { inherit nodejs; };
  nodeDependencies = generated.nodeDependencies;
in {
  inherit nodeDependencies;

  static = stdenv.mkDerivation {
    name = "{{ cookiecutter.project_slug }}-assets";
    src = ./.;
    buildInputs = [ nodejs ];
    buildPhase = ''
      ln -s ${nodeDependencies}/lib/node_modules ./node_modules
      export PATH="${nodeDependencies}/bin:$PATH"
      npm run build
    '';
    installPhase = ''
      cp -r dist $out/
    '';
  };
}
