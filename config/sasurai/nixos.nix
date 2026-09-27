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
      ../../hosts/sasurai/disko.nix
      ../../modules/nixos/services/services.nix
      ../../modules/nixos/ssh-server/ssh-server.nix
      ../../modules/nixos/hardware/pipewire.nix
      ../../modules/nixos/hardware/network.nix
      ../../modules/nixos/kde/kde.nix
      #../../modules/nixos/greetd/greetd.nix
      ../../modules/nixos/steam/steam.nix
      ../../modules/nixos/gaming/gaming.nix
      ../../modules/nixos/stylix/stylix.nix
      ../../modules/nixos/niri/niri.nix
      ./nix-packages/nix-packages.nix
    ]
    # Bare-metal-only pieces (Secure Boot/lanzaboote, amdgpu, host incus/podman):
    # skipped when running in a test VM (hosts/vm/common.nix takes over).
    ++ lib.optionals (!vm) [
      ../../modules/nixos/boot/secureboot.nix
      ../../modules/nixos/hardware/amd.nix
      ../../modules/nixos/virtualisation/incus.nix
      ../../modules/nixos/virtualisation/podman.nix
    ];

  boot.initrd.availableKernelModules = ["amdgpu"];

  services.niri.login = "none";
  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  # Impermanence: keep the Secure Boot PKI (keys live under /var/lib on tmpfs).
  environment.persistence."/persist".directories = [
    "/var/lib/sbctl"
  ];

  boot.initrd.luks.devices."crypt".crypttabExtraOpts = lib.mkIf (!vm) [
    "fido2-device=auto"
    "token-timeout=15"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username stylix;
      hostname = "sasurai";
    };
    users.${username} = import ./home.nix;
  };
}
