{ config, pkgs, lib, ... }:
let cfg = config.services.{{ cookiecutter.project_slug }};
in {
  options.services.{{ cookiecutter.project_slug }} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    package = lib.mkOption { type = lib.types.package; };

    staticFilesPackage = lib.mkOption { type = lib.types.package; };

    user = lib.mkOption {
      type = lib.types.str;
      default = "{{ cookiecutter.project_slug }}";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "{{ cookiecutter.project_slug }}";
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Additional environment variables to export. Must be files that contain lines in the format FOO=BAR.
        You will need to at least set SECRET_KEY and DATABASE_URL.
      '';
    };

    settingsModule = lib.mkOption {
      type = lib.types.str;
      default = "{{ cookiecutter.project_slug }}.config.settings.base";
    };

    staticUrl = lib.mkOption {
      type = lib.types.str;
      default = "/static/";
    };

    mediaUrl = lib.mkOption {
      type = lib.types.str;
      default = "/media/";
    };

    mediaRoot = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/{{ cookiecutter.project_slug }}/media";
    };

    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = if cfg.webServer.enable then [ cfg.webServer.hostName ] else [ ];
    };

    manageScript = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };

    appServer = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };

          nbWorkers = lib.mkOption {
            type = lib.types.int;
            default = 4;
          };

          socket = lib.mkOption {
            type = lib.types.path;
            readOnly = true;
          };

          wsgiModule = lib.mkOption {
            type = lib.types.str;
            default = "{{ cookiecutter.project_slug }}.config.wsgi";
          };
        };
      };

      default = { };
    };

    webServer = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };

          hostName = lib.mkOption {
            type = lib.types.str;
          };
        };
      };

      default = { };
    };
  };

  config = let
    environment = {
      STATIC_URL = cfg.staticUrl;
      MEDIA_URL = cfg.mediaUrl;
      DJANGO_SETTINGS_MODULE = cfg.settingsModule;
      ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHosts;
      STATIC_ROOT = cfg.staticFilesPackage;
      MEDIA_ROOT = cfg.mediaRoot;
    };

    environmentList = lib.mapAttrsToList (name: value: "${name}=${lib.escapeShellArg value}") environment;

    dependencyEnv = cfg.package.python.withPackages (ps: [ ps.{{ cookiecutter.project_slug }} ]);
  in lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.{{ cookiecutter.project_slug }}.appServer.socket = "/run/gunicorn_{{ cookiecutter.project_slug }}/gunicorn.sock";

      services.{{ cookiecutter.project_slug }}.manageScript = pkgs.writeShellScriptBin "{{ cookiecutter.project_slug }}" ''
        sudo() {
          if [[ "$USER" != ${cfg.user} ]]; then
            exec /run/wrappers/bin/sudo -u ${cfg.user} --preserve-env "$@"
          else
            exec "$@"
          fi
        }

        export ${lib.concatStringsSep " " environmentList}

        set -a
        ${lib.concatStringsSep "\n"
        (map (file: "source ${file}") cfg.environmentFiles)}
        set +a

        sudo ${dependencyEnv.interpreter} -m django "$@"
      '';

      systemd.services.{{ cookiecutter.project_slug }}-maintenance = {
        wantedBy = [ "multi-user.target" ];

        after = [ "network.target" "postgresql.service" ];

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
          Environment = environmentList;
          EnvironmentFile = cfg.environmentFiles;
        };

        script = ''
          ${cfg.manageScript}/bin/{{ cookiecutter.project_slug }} migrate --noinput
        '';
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.mediaRoot} 0750 ${cfg.user} ${cfg.group} - -"
      ];

      environment.systemPackages = [ cfg.manageScript ];

      users.users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };

      users.groups.${cfg.group} = { };
    }

    # App server
    (lib.mkIf cfg.appServer.enable {
      systemd.services.{{ cookiecutter.project_slug }}-gunicorn = let
        dependencyEnv = cfg.package.python.withPackages
          (ps: [ ps.gunicorn ps.gevent ps.{{ cookiecutter.project_slug }} ]);
      in {
        wantedBy = [ "multi-user.target" ];

        after = [ "{{ cookiecutter.project_slug }}-maintenance.service" ];

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          RuntimeDirectory = "gunicorn_{{ cookiecutter.project_slug }}";
          RuntimeDirectoryPreserve = true;
          # https://docs.gunicorn.org/en/stable/deploy.html#systemd
          ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
          KillMode = "mixed";
          Environment = environmentList;
          EnvironmentFile = cfg.environmentFiles;
          PrivateTmp = "true";
        };

        # TODO create a symlink to this script and call it in `serviceConfig.ExecStart` and set `reloadTriggers` to reload
        # gunicorn instead of stopping and starting it
        script = ''
          ${dependencyEnv.interpreter} -m gunicorn \
            --name gunicorn-{{ cookiecutter.project_slug }} \
            --pythonpath ${dependencyEnv}/${dependencyEnv.python.sitePackages} \
            --bind unix:${cfg.appServer.socket} \
            --workers ${toString cfg.appServer.nbWorkers} \
            --worker-class gevent \
            ${cfg.appServer.wsgiModule}:application
        '';
      };
    })

    # Web server
    (lib.mkIf (cfg.webServer.enable && cfg.appServer.enable) {
      services.caddy = {
        enable = cfg.webServer.enable;
        virtualHosts.${cfg.webServer.hostName}.extraConfig = ''
          header -Server

          handle_path /static/* {
            header -ETag
            root * ${cfg.staticFilesPackage}
            file_server
          }

          reverse_proxy * unix/${cfg.appServer.socket}
        '';
      };

      # Allow the web server to browse media files
      users.users.${config.services.caddy.user}.extraGroups = [ cfg.group ];
    })
  ]);
}
