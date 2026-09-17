{
  stylix,
  username,
  ...
}: {
  imports = [
    ../../modules/nixos/core
    ../../modules/nixos/core/impermanence.nix
    ../../modules/nixos/boot/plymouth.nix
    ../../modules/nixos/boot/memtest86.nix
    ../../hosts/zoltraak/disko.nix
    ../../modules/nixos/services/services.nix
    ../../modules/nixos/ssh-server
    ../../modules/nixos/hardware
    ../../modules/nixos/virtualisation
    ../../modules/nixos/noctalia
    ../../modules/nixos/niri
    stylix.nixosModules.stylix
    ../../modules/nixos/stylix
    ./nix-packages
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username stylix;
      hostname = "zoltraak";
    };
    users.${username} = import ./home.nix;
  };
}
