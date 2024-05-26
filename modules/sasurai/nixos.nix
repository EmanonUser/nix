{stylix, ...}: {
  imports = [
    ../nixos/core
    ../nixos/services/services.nix
    ../nixos/hardware
    ../nixos/virtualisation
    #../nixos/greetd/greetd.nix
    ../nixos/steam/steam.nix
    stylix.nixosModules.stylix
    ../nixos/stylix
    ./nix-packages
  ];
}
