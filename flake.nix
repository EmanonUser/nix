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

    # Neovim wrapper framework (successor to nixCats). nixpkgs owns the plugin
    # packages; see modules/neovim/wrapper.nix.
    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim plugins not in nixpkgs, built by nvim-lib.mkPlugin.
    plugins-typr = {
      url = "github:nvzone/typr";
      flake = false;
    };
    plugins-volt = {
      url = "github:nvzone/volt";
      flake = false;
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
    wrappers,
    ...
  } @ attrs: let
    system = "x86_64-linux";
    username = "emanon";
    lib = nixpkgs.lib;
    # allowUnfree mirrors modules/nixos/core/settings.nix; needed here because
    # the wrapped neovim is evaluated in this flake and presence.nvim is unfree.
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Neovim from nix-wrapper-modules. `attrs` gives the wrapper module the
    # plugin-* flake inputs; systemPkgs supplies pkgs.vimPlugins.
    neovimPkg = wrappers.lib.evalPackage (lib.modules.importApply ./modules/neovim/wrapper.nix {
      inherit attrs;
      systemPkgs = pkgs;
    });

    # Overlay so every `pkgs.neovim` is the wrapped one: NixOS hosts get it via
    # mkSystem, the standalone fern home-manager profile via its own pkgs below.
    neovimOverlay = _final: _prev: {neovim = neovimPkg;};

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
    }:
      lib.nixosSystem {
        specialArgs =
          {
            inherit username system;
            inherit hostname;
          }
          // (lib.optionalAttrs (filesystem != null) {inherit filesystem;})
          // {inherit vm luks;}
          // (lib.optionalAttrs vm {netHostName = hostname + "-vm";})
          // attrs;
        modules =
          [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            agenix.nixosModules.default
            {nixpkgs.overlays = [neovimOverlay];}
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

      # Headless dev environment: SSH in, edit, build. Unencrypted - it holds
      # nothing but a checkout, and a throwaway passphrase beats a FIDO2 prompt.
      nixos-vm = mkSystem {
        hostname = "nixos-vm";
        filesystem = "zfs";
        luks = false;
      };

      # Second throwaway VM: smoke-test config changes before they reach
      # sasurai or zoltraak. vm = true, so it gets the throwaway credentials and
      # the virtio adaptations from hosts/vm/.
      nixos-tests = mkSystem {
        hostname = "nixos-tests";
        filesystem = "zfs";
        luks = false;
        vm = true;
      };
    };

    homeConfigurations = {
      fern = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [neovimOverlay];
        };
        extraSpecialArgs = {
          inherit username;
          hostname = "fern";
        };
        modules = [
          agenix.homeManagerModules.age
          ./configs/fern/home.nix
        ];
      };
    };
  };
}
