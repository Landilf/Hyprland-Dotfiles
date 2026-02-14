{
  description = "NixOS with home-manager btw";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    matugen = {
      url = "github:InioX/Matugen?ref=refs/tags/v3.1.0";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nixpkgs-unstable,  ... }: {
    nixosConfigurations.nix-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };

      modules = [ 
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.landilf = import ./home.nix;
        }
      ];
    };
  };
}