{
  description = "{{ cookiecutter.project_name }}";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };

        # The overlay allows to add this package to the `pkgs` of another flake like so:
        # pkgs = import nixpkgs {
        #   overlays = [ thisFlake.overlay ];
        # };
        overlay = (final: prev: {
          {{ cookiecutter.project_slug }} = (final.callPackage ./. { }) // {
            backend = final.callPackage ./backend { };
            frontend = final.callPackage ./frontend { };
          };
        });

        # Create an environment with all inputs from the given environments
        mergeEnvs = envs:
          pkgs.mkShell (builtins.foldl' (a: v: {
            buildInputs = a.buildInputs ++ v.buildInputs;
            nativeBuildInputs = a.nativeBuildInputs ++ v.nativeBuildInputs;
            propagatedBuildInputs = a.propagatedBuildInputs
              ++ v.propagatedBuildInputs;
            propagatedNativeBuildInputs = a.propagatedNativeBuildInputs
              ++ v.propagatedNativeBuildInputs;
            shellHook = a.shellHook + "\n" + v.shellHook;
          }) (pkgs.mkShell { }) envs);

        # Convert a derivation to the format expected by flakes apps
        mkApp = drv: {
          type = "app";
          program = "${drv}/bin/${drv.name}";
        };
      in rec {
        overlays.default = overlay;

        apps.default = mkApp pkgs.{{ cookiecutter.project_slug }}.dev;

        packages = rec {
          default = server;
          server = pkgs.{{ cookiecutter.project_slug }}.backend.server;
          server-static = pkgs.{{ cookiecutter.project_slug }}.backend.static;
          static = pkgs.{{ cookiecutter.project_slug }}.frontend.static;
        };

        checks = packages;

        devShells = rec {
          default = mergeEnvs [
            frontend
            backend
            (pkgs.mkShell {
              packages = with pkgs.{{ cookiecutter.project_slug }}; [
                dev
                server-back
                server-front
              ];
            })
          ];
          frontend = pkgs.{{ cookiecutter.project_slug }}.frontend.shell;
          backend = pkgs.{{ cookiecutter.project_slug }}.backend.shell;
        };
      });
}
