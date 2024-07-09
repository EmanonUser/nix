{stylix, ...}: {
  imports = [
    ../nixos/core
    ../nixos/services/services.nix
    ../nixos/ssh-server
    ../nixos/hardware
    ../nixos/virtualisation
    ../nixos/kde
    #../nixos/greetd/greetd.nix
    ../nixos/steam/steam.nix
    stylix.nixosModules.stylix
    ../nixos/stylix
    ./nix-packages
  ];
}
