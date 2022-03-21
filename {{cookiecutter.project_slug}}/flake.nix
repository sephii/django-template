{
  description = "{{ cookiecutter.project_name }}";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
        overlay = (final: prev: {
          {{ cookiecutter.project_slug }} = (final.callPackage ./. { }) // {
            django = final.callPackage ./backend { };
            frontend = final.callPackage ./frontend { };
          };
        });
        mergeEnvs = pkgs: envs:
          pkgs.mkShell (builtins.foldl' (a: v: {
            buildInputs = a.buildInputs ++ v.buildInputs;
            nativeBuildInputs = a.nativeBuildInputs ++ v.nativeBuildInputs;
            propagatedBuildInputs = a.propagatedBuildInputs
              ++ v.propagatedBuildInputs;
            propagatedNativeBuildInputs = a.propagatedNativeBuildInputs
              ++ v.propagatedNativeBuildInputs;
            shellHook = a.shellHook + "\n" + v.shellHook;
          }) (pkgs.mkShell { }) envs);
      in rec {
        inherit overlay;
        apps = { dev = pkgs.{{ cookiecutter.project_slug }}.dev; };
        defaultApp = apps.dev;
        packages = {
          server = pkgs.{{ cookiecutter.project_slug }}.django.server;
          server-static = pkgs.{{ cookiecutter.project_slug }}.django.static;
          static = pkgs.{{ cookiecutter.project_slug }}.frontend.static;
        };
        defaultPackage = pkgs.{{ cookiecutter.project_slug }}.django.server;
        checks = packages;
        devShell = mergeEnvs pkgs (with devShells; [ frontend django ]);
        devShells = {
          frontend = pkgs.{{ cookiecutter.project_slug }}.frontend.shell;
          django = pkgs.{{ cookiecutter.project_slug }}.django.shell;
        };
      });
}
