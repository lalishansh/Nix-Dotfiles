{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      "NixOS-Laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Override
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
            };
          }

          # Build for system type
          # /etc/nixos/hardware-configuration.nix # require --impure
          ./system-type/Laptop/hardware.nix
          ./system-type/Laptop

          # All users
          ./users/ilal
        ];
      };
    };
  };
}
