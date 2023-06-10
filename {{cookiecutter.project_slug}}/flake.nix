{
  description = "{{ cookiecutter.project_name }}";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, devenv }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };

        assets = pkgs.callPackage ./src/assets { };

        # The overlay allows to add this package to the `pkgs` of another flake like so:
        # pkgs = import nixpkgs {
        #   overlays = [ thisFlake.overlay ];
        # };
        overlay = (final: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            {% if cookiecutter.packaging == "nix" %}
            (python-final: python-prev: let
              drvWithDeps = requirements: (final.callPackage ./. {
                inherit (python-final) buildPythonPackage;
                pythonPackages = python-final;
                assetsStatic = assets.static;
              }).overridePythonAttrs (old: {
                propagatedBuildInputs = (
                  old.propagatedBuildInputs or []
                ) ++ (
                  import requirements { pythonPackages = python-final; }
                );
              });
            in {
              {{ cookiecutter.project_slug }} = drvWithDeps ./requirements.nix;
              {{ cookiecutter.project_slug }}-dev = drvWithDeps ./requirements_dev.nix;
            })
            {% elif cookiecutter.packaging == "poetry" %}
            (python-final: python-prev: {
              {{ cookiecutter.project_slug }} = final.callPackage ./. {
                inherit (python-final) python;
                assetsStatic = assets.static;
              };
              {{ cookiecutter.project_slug }}-dev = (final.callPackage ./. {
                inherit (python-final) python;
                assetsStatic = assets.static;
                groups = [ "dev" ];
              });
            })
            {% endif %}
          ];

          {{ cookiecutter.project_slug }}-static = final.stdenv.mkDerivation {
            pname = "${final.python3.pkgs.{{ cookiecutter.project_slug }}.pname}-static";
            version = final.python3.pkgs.{{ cookiecutter.project_slug }}.version;
            src = ./.;
            buildPhase = ''
              export STATIC_ROOT=$out
              export MEDIA_ROOT=/dev/null
              export DJANGO_SETTINGS_MODULE={{ cookiecutter.project_slug }}.config.settings.base
              export SECRET_KEY=dummy
              export DATABASE_URL=sqlite:////dev/null
              ${final.python3.withPackages (ps: [ ps.{{ cookiecutter.project_slug }} ])}/bin/python -m django collectstatic --noinput
            '';
            phases = [ "buildPhase" ];
          };
        });

        python = pkgs.python3;
      in rec {
        overlays.default = overlay;

        packages = rec {
          default = python.pkgs.{{ cookiecutter.project_slug }};
          static = pkgs.{{ cookiecutter.project_slug }}-static;
        };

        checks = packages;

        devShells.default = pkgs.callPackage ./shell.nix {
          inherit devenv inputs pkgs python;
          inherit (assets) nodeDependencies;
        };
      });
}
