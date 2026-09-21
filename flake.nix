{
  description = "Emanon's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    impermanence,
    disko,
    stylix,
    agenix,
    lanzaboote,
    noctalia,
    ...
  } @ attrs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    formatter.x86_64-linux = pkgs.alejandra;

    nixosConfigurations = {
      sasurai = nixpkgs.lib.nixosSystem {
        specialArgs =
          {
            username = "emanon";
            hostname = "sasurai";
            filesystem = "zfs";
            inherit system;
          }
          // attrs;
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          agenix.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          ./hosts/sasurai
        ];
      };

      nixos-vm = nixpkgs.lib.nixosSystem {
        specialArgs =
          {
            username = "emanon";
            hostname = "nixos-vm";
            filesystem = "zfs";
            inherit system;
          }
          // attrs;
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          agenix.nixosModules.default
          ./hosts/nixos-vm
        ];
      };

      zoltraak = nixpkgs.lib.nixosSystem {
        specialArgs =
          {
            username = "emanon";
            hostname = "zoltraak";
            inherit system;
          }
          // attrs;
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          agenix.nixosModules.default
          ./hosts/zoltraak
        ];
      };
    };

    homeConfigurations = {
      frieren = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          username = "emanon";
          hostname = "frieren";
        };
        modules = [
          agenix.homeManagerModules.age
          ./config/frieren/home.nix
        ];
      };
    };
  };
}
