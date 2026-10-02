{
  description = "Emanon's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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

    # fern's backup daemon. It has no remote yet, so this points at the local
    # checkout; `git+file` (not `path`) keeps its 600 MB target/ out of the
    # store. Switch to github:<owner>/backupd and run `nix flake update backupd`
    # once it is pushed.
    backupd = {
      url = "git+file:///fern/emanonlab/dev/backupd";
      flake = false;
    };
    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    home-manager-stable,
    impermanence,
    disko,
    stylix,
    agenix,
    lanzaboote,
    noctalia,
    backupd,
    wrappers,
    ...
  } @ attrs: let
    system = "x86_64-linux";
    username = "emanon";
    lib = nixpkgs.lib;
    # Mirrors modules/nixos/core/settings.nix (allowUnfree = true). Needed at
    # the flake level too because the wrapped neovim is evaluated here and
    # presence.nvim is unfree.
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    mkBackupd = p:
      p.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "backupd";
        version = (builtins.fromTOML (builtins.readFile (backupd + "/Cargo.toml"))).package.version;
        src = backupd;
        cargoLock.lockFile = backupd + "/Cargo.lock";
        meta.mainProgram = "backupd";
      });

    mkNeovim = p:
      wrappers.lib.evalPackage (lib.modules.importApply ./modules/neovim/wrapper.nix {
        systemPkgs = p;
      });

    backupdPkg = mkBackupd pkgs;
    neovimPkg = mkNeovim pkgs;

    # Build a NixOS system. Setting `vm = true` produces a throwaway Incus-VM
    # twin of the *same* host config: same identity/hostname, but the
    # bare-metal-only pieces are skipped in the host config itself
    # (secureboot/lanzaboote, amdgpu, host incus/podman; see vm overs in the
    # configs/*/nixos.nix files) and hosts/vm/common.nix wires up the virtio
    # disk, serial console and incus agent.
    mkSystem = {
      hostname,
      vm ? false,
      filesystem ? null,
      luks ? true,
      extraModules ? [],
      nixpkgsInput ? nixpkgs,
      homeManagerInput ? home-manager,
      pkgsInput ? pkgs,
    }:
      nixpkgsInput.lib.nixosSystem {
        specialArgs =
          {
            inherit username system;
            inherit hostname;
            backupdPkg = mkBackupd pkgsInput;
          }
          // (lib.optionalAttrs (filesystem != null) {inherit filesystem;})
          // {inherit vm luks;}
          // (lib.optionalAttrs vm {netHostName = hostname + "-vm";})
          // attrs;
        modules =
          [
            disko.nixosModules.disko
            homeManagerInput.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            agenix.nixosModules.default
            {nixpkgs.overlays = [(_final: _prev: {neovim = mkNeovim pkgsInput;})];}
            ./hosts/${hostname}/${hostname}.nix
          ]
          ++ lib.optionals vm [./hosts/vm/common.nix]
          ++ extraModules;
      };
  in {
    formatter.x86_64-linux = pkgs.alejandra;

    packages.x86_64-linux.neovim = neovimPkg;

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
        luks = false;
      };

      nixos-tests = mkSystem {
        hostname = "nixos-tests";
        filesystem = "zfs";
        luks = false;
        vm = true;
      };

      # fern runs nixos-26.05 (stable); every other host stays on unstable.
      fern = mkSystem {
        hostname = "fern";
        filesystem = "ext4";
        luks = false;
        nixpkgsInput = nixpkgs-stable;
        homeManagerInput = home-manager-stable;
        pkgsInput = pkgs-stable;
      };

      fern-vm = mkSystem {
        hostname = "fern";
        filesystem = "ext4";
        luks = false;
        vm = true;
        nixpkgsInput = nixpkgs-stable;
        homeManagerInput = home-manager-stable;
        pkgsInput = pkgs-stable;
      };
    };

    # Standalone Home Manager profiles for non-NixOS machines.
    # (fern moved to nixosConfigurations.fern - it is now a NixOS host.)
    homeConfigurations = {};
  };
}
