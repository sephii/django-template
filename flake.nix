{
  description = "A collection of Django-related flake templates";

  outputs = { self }: {
    templates = {
      nixos = {
        path = ./nix_templates/nixos;
        description = "A basic NixOS host with a Django website.";
        welcomeText = ''
          You need to edit the newly created `flake.nix` file and replaces
          instances of `my_project` to references to your real project.
        '';
      };
    };
  };
}
