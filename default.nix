{home-manager, nixvim, ...}: {
  imports = [
    home-manager.nixosModules.home-manager
    ./hosts
    ./modules
  ];
}
