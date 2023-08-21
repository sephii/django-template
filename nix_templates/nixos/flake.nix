{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  # Step 1: Adapt the URL below to your Django project
  # inputs.my_project.url = "github:example/my_project";

  outputs = { self, nixpkgs, my_project }: {

    nixosConfigurations.default = let
      system = "x86_64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        my_project.nixosModules.default

        ({ pkgs, config, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          networking.firewall.allowedTCPPorts = [ 80 443 ];

          # Step 2: uncomment and adapt the following lines to enable your Django site
          #
          # services.my_project = {
          #   enable = true;

          #   package = my_project.packages.${system}.default;
          #   staticFilesPackage = my_project.packages.${system}.static;

          #   environmentFiles = [ (pkgs.writeText "myproject-env" ''
          #     SECRET_KEY=
          #     DATABASE_URL=postgresql:///myproject
          #   '') ];

          #   appServer.enable = true;

          #   webServer = {
          #     enable = true;
          #     hostName = "myproject.localhost";
          #   };
          # };

          # services.postgresql = {
          #   enable = true;
          #   ensureDatabases = [ "myproject" ];
          #   ensureUsers = [
          #     {
          #       name = config.services.my_project.user;
          #       ensurePermissions = { "DATABASE myproject" = "ALL PRIVILEGES"; };
          #     }
          #   ];
          # };

          environment.systemPackages = [ pkgs.httpie ];
        })
      ];
    };
  };
}
