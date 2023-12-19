{
  description = "{{ cookiecutter.project_name }}";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    # Workaround https://github.com/cachix/devenv/issues/756#issuecomment-1684049113
    devenv.url = "github:cachix/devenv/9ba9e3b908a12ddc6c43f88c52f2bf3c1d1e82c1";
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
        };

        checks = packages;

        devShells.default = python.pkgs.callPackage ./shell.nix {
          inherit devenv inputs pkgs;
          inherit (assets) nodeDependencies;
        };
      }) // {
        nixosModules.default = import ./nixos.nix;
      };
}
