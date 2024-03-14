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
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixvim,
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
      "emanon@frieren" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          username = "emanon";
          hostname = "frieren";
          inherit nixvim;
        };
        modules = [./hosts/frieren];
      };

      "emanon@sasurai" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          username = "emanon";
          hostname = "sasurai";
          inherit nixvim;
        };
        modules = [./modules/sasurai/home.nix];
      };
    };
  };
}
