{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    stylix.url = "github:danth/stylix";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixvim,
    stylix,
    ...
  } @ attrs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      sasurai = let
        system = "x86_64-linux";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs =
            {
              username = "emanon";
              hostname = "sasurai";
              inherit system;
            }
            // attrs;
          modules = [./hosts/sasurai];
        };
    };

    homeConfigurations = {
      "emanon@sasurai" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          username = "emanon";
          hostname = "sasurai";
          inherit nixvim;
          inherit stylix;
        };
        modules = [./modules/sasurai/home.nix];
      };

      "emanon@frieren" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          username = "emanon";
          hostname = "frieren";
          inherit nixvim;
        };
        modules = [./modules/frieren/home.nix];
      };
    };
  };
}
