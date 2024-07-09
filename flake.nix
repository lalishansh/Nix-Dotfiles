{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations."NixOS-Laptop" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Syatem type
        ./system-type/Laptop/configuration.nix

        # All users
        ./users/users.nix

        # Override
       	home-manager.nixosModules.home-manager
       	{
       	  home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
       	}
      ];
    };
  };
}
