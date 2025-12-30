{
  description = "{{ cookiecutter.project_name }}";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, devenv }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        assets = pkgs.callPackage ./src/assets { };

        python = pkgs.python3.override {
          packageOverrides = import ./overrides.nix { assetsStatic = assets.static; };
          self = python;
        };
      in rec {
        packages = {
          default = python.pkgs.{{ cookiecutter.project_slug }};
          static = python.pkgs.callPackage ./static.nix {};
          devenv-up = self.devShells.${system}.default.config.procfileScript;
        };

        checks = packages;

        devShells.default = python.pkgs.callPackage ./shell.nix {
          inherit devenv inputs pkgs;
          inherit (assets) npmDeps;
        };
      }) // {
        nixosModules.default = import ./nixos.nix;
      };
}
