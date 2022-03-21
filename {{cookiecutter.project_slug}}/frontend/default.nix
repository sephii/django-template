{ stdenv, callPackage, nodePackages, nodejs, writeShellScriptBin }:
let
  generated = callPackage ./nix { inherit nodejs; };
  fixGyp = drv:
    drv.override {
      buildInputs = [ nodePackages.node-gyp-build ];
      preRebuild = ''
        sed -i -e "s|#!/usr/bin/env node|#! ${nodejs}/bin/node|" node_modules/node-gyp-build/bin.js
      '';
    };
  # nodeDependencies = fixGyp generated.nodeDependencies;
  nodeDependencies = generated.nodeDependencies;
  # shell = fixGyp (generated.shell.override { buildInputs = [ node2nix ]; });
  shell = generated.shell.override { buildInputs = [ node2nix ]; };
  node2nix = writeShellScriptBin "node2nix" ''
    ${nodePackages.node2nix}/bin/node2nix \
      --development \
      -l package-lock.json \
      -c ./nix/node/default.nix \
      -o ./nix/node/node-packages.nix \
      -e ./nix/node/node-env.nix
  '';
in {
  inherit nodeDependencies;
  static = stdenv.mkDerivation {
    name = "{{ cookiecutter.project_slug }}-frontend";
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
  shell = shell;
}
