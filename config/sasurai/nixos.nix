{
  lib,
  vm ? false,
  stylix,
  username,
  ...
}: {
  imports =
    [
      ../../modules/nixos/core
      ../../modules/nixos/core/impermanence.nix
      ../../modules/nixos/boot/plymouth.nix
      ../../modules/nixos/boot/memtest86.nix
      ../../hosts/sasurai/disko.nix
      ../../modules/nixos/services/services.nix
      ../../modules/nixos/ssh-server
      ../../modules/nixos/hardware/pipewire.nix
      ../../modules/nixos/hardware/network.nix
      ../../modules/nixos/kde
      #../../modules/nixos/greetd/greetd.nix
      ../../modules/nixos/steam/steam.nix
      ../../modules/nixos/gaming
      ../../modules/nixos/stylix
      ../../modules/nixos/niri
      ./nix-packages
    ]
    # Bare-metal-only pieces (Secure Boot/lanzaboote, amdgpu, host incus/podman):
    # skipped when running in a test VM (hosts/vm/common.nix takes over).
    ++ lib.optionals (!vm) [
      ../../modules/nixos/boot/secureboot.nix
      ../../modules/nixos/hardware/amd.nix
      ../../modules/nixos/virtualisation
    ];

  # niri as an optional SDDM session; KDE/SDDM stays the default boot target.
  services.niri.login = "none";

  # Graphic plymouth splash: needs the KMS driver in the initrd.
  boot.initrd.availableKernelModules = ["amdgpu"];
  boot.plymouth.theme = "spinner";

  # Log straight into the desktop as emanon (KDE/SDDM).
  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  # Impermanence: keep the Secure Boot PKI (keys live under /var/lib on tmpfs).
  environment.persistence."/persist".directories = [
    "/var/lib/sbctl"
  ];

  # Allow unlocking the LUKS root via a FIDO2 hardware token at boot;
  # falls back to the passphrase when the token isn't present.
  boot.initrd.luks.devices."crypt".crypttabExtraOpts = lib.mkIf (!vm) [
    "fido2-device=auto"
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
