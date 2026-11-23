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

    backupd = {
      url = "git+ssh://git@github.com/EmanonUser/backupd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bootvine = {
      url = "git+https://codeberg.org/wvhulle/bootvine";
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
    bootvine,
    ...
  } @ attrs: let
    system = "x86_64-linux";
    username = "emanon";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    mkNeovim = p:
      wrappers.lib.evalPackage (lib.modules.importApply ./modules/neovim/wrapper.nix {
        systemPkgs = p;
      });

    neovimPkg = mkNeovim pkgs;

    mkSystem = {
      hostname,
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
            backupdPkg =
              (backupd.packages.${system}.default).overrideAttrs (old: {
                # aws-lc-sys 0.45 demands a system AWS-LC when it detects one;
                # force the source build, and give sqlx-macros libsqlite3.
                preBuild = (old.preBuild or "") + "\nexport AWS_LC_SYS_USE_SYSTEM=0\n";
                buildInputs = (old.buildInputs or []) ++ [pkgs.sqlite];
              });
            incusPkg = nixpkgs.legacyPackages.${system}.incus;
            atuinPkg = pkgs.atuin;
          }
          // (lib.optionalAttrs (filesystem != null) {inherit filesystem;})
          // {
            inherit luks;
            vm = false;
          }
          // attrs;
        modules =
          [
            disko.nixosModules.disko
            homeManagerInput.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            agenix.nixosModules.default
            {
              nixpkgs.overlays = [
                (_final: _prev: {neovim = mkNeovim pkgsInput;})
                # sqlx-cli 0.9.0 builds sqlite support but nixpkgs forgot the
                # library, so linking fails with `cannot find -lsqlite3`.
                (_final: prev: {
                  sqlx-cli = prev.sqlx-cli.overrideAttrs (old: {
                    buildInputs = (old.buildInputs or []) ++ [prev.sqlite];
                  });
                })
              ];
            }
            ./hosts/${hostname}/${hostname}.nix
          ]
          ++ extraModules;
      };
  in {
    formatter.x86_64-linux = pkgs.alejandra;

    packages.x86_64-linux.neovim = neovimPkg;

    devShells.x86_64-linux.default = pkgs-stable.mkShell {
      packages = with pkgs-stable; [
        age
        (agenix.packages.${system}.default)
        openssh
        git
        jq
        rsync
        curl
        shellcheck
        shfmt
        alejandra
      ];
    };

    nixosConfigurations = {
      sasurai = mkSystem {
        hostname = "sasurai";
        filesystem = "zfs";
        extraModules = [
          lanzaboote.nixosModules.lanzaboote
          bootvine.nixosModules.default
        ];
      };

      zoltraak = mkSystem {
        hostname = "zoltraak";
        extraModules = [
          lanzaboote.nixosModules.lanzaboote
          bootvine.nixosModules.default
        ];
      };

      flamme = mkSystem {
        hostname = "flamme";
        filesystem = "ext4";
        luks = false;
      };

      fern = mkSystem {
        hostname = "fern";
        filesystem = "ext4";
        luks = false;
        nixpkgsInput = nixpkgs-stable;
        homeManagerInput = home-manager-stable;
        pkgsInput = pkgs-stable;
      };
    };
  };
}
