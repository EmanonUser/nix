{
  lib,
  vm ? false,
  stylix,
  username,
  ...
}: {
  imports =
    [
      ../../modules/nixos/core/settings.nix
      ../../modules/nixos/core/fonts.nix
      ../../modules/nixos/core/agenix.nix
      ../../modules/nixos/boot/bootloader.nix
      ../../modules/nixos/core/impermanence.nix
      ../../modules/nixos/boot/plymouth.nix
      ../../modules/nixos/boot/memtest86.nix
      ../../hosts/zoltraak/disko.nix
      ../../modules/nixos/services/services.nix
      ../../modules/nixos/ssh-server/ssh-server.nix
      ../../modules/nixos/hardware/pipewire.nix
      ../../modules/nixos/hardware/network.nix
      ../../modules/nixos/samba-client/samba-client.nix
      ../../modules/nixos/noctalia/noctalia.nix
      ../../modules/nixos/niri/niri.nix
      ../../modules/nixos/stylix/stylix.nix
      ./nix-packages/nix-packages.nix
    ]
    # Bare-metal-only pieces (amdgpu, host incus/podman): skipped when running
    # in a test VM (hosts/vm/common.nix takes over).
    ++ lib.optionals (!vm) [
      ../../modules/nixos/hardware/amd.nix
      ../../modules/nixos/virtualisation/incus.nix
      ../../modules/nixos/virtualisation/podman.nix
    ];

  # Boot text splash: the closed NVIDIA driver can't drive a graphical
  # plymouth from the initrd (no KMS), so render on the text console instead.
  boot.plymouth.theme = "text";

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
