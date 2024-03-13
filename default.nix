{
  home-manager,
  ...
}: {
  imports = [
    home-manager.nixosModules.home-manager
    ./hosts
    ./users
    ./modules
  ];
}
