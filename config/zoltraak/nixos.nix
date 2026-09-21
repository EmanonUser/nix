{
  lib,
  vm ? false,
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
    ../../modules/nixos/hardware/pipewire.nix
    ../../modules/nixos/hardware/network.nix
    ../../modules/nixos/noctalia
    ../../modules/nixos/niri
    stylix.nixosModules.stylix
    ../../modules/nixos/stylix
    ./nix-packages
  ]
  # Bare-metal-only pieces (amdgpu, host incus/podman): skipped when running
  # in a test VM (hosts/vm/common.nix takes over).
  ++ lib.optionals (!vm) [
    ../../modules/nixos/hardware/amd.nix
    ../../modules/nixos/virtualisation
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
