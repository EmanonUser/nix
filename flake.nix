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
    username = "emanon";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};

    # Build a NixOS system. Setting `vm = true` produces a throwaway Incus-VM
    # twin of the *same* host config: same identity/hostname, but the
    # bare-metal-only pieces are skipped in the host config itself
    # (secureboot/lanzaboote, amdgpu, host incus/podman; see vm overs in the
    # config/*/nixos.nix files) and hosts/vm/common.nix wires up the virtio
    # disk, serial console and incus agent.
    mkSystem = {
      hostname,
      vm ? false,
      filesystem ? null,
      extraModules ? [],
    }:
      lib.nixosSystem {
        specialArgs =
          {
            inherit username system;
            inherit hostname;
          }
          // (lib.optionalAttrs (filesystem != null) { inherit filesystem; })
          // { inherit vm; }
          // (lib.optionalAttrs vm { netHostName = hostname + "-vm"; })
          // attrs;
        modules =
          [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            agenix.nixosModules.default
            ./hosts/${hostname}
          ]
          ++ lib.optionals vm [./hosts/vm/common.nix]
          ++ extraModules;
      };
  in {
    formatter.x86_64-linux = pkgs.alejandra;

    nixosConfigurations = {
      sasurai = mkSystem {
        hostname = "sasurai";
        filesystem = "zfs";
        extraModules = [lanzaboote.nixosModules.lanzaboote];
      };

      sasurai-vm = mkSystem {
        hostname = "sasurai";
        filesystem = "zfs";
        vm = true;
      };

      zoltraak = mkSystem {
        hostname = "zoltraak";
        extraModules = [lanzaboote.nixosModules.lanzaboote];
      };

      zoltraak-vm = mkSystem {
        hostname = "zoltraak";
        vm = true;
      };

      nixos-vm = mkSystem {
        hostname = "nixos-vm";
        filesystem = "zfs";
      };
    };

    homeConfigurations = {
      frieren = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit username;
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