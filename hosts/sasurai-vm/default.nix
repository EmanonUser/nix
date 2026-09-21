{
  pkgs,
  lib,
  username,
  ...
}: {
  nixpkgs.hostPlatform = "x86_64-linux";

  # Run sasurai's desktop stack inside a throwaway Incus VM for testing. It
  # reuses the sasurai guest identity (specialArg hostname = "sasurai", so
  # ssh/git/agenix resolve config/sasurai/ssh/... and the per-host host key is
  # seeded at install), but with VM-friendly hardware: no Secure Boot, no
  # amdgpu, virtio disk/GPU.
  imports = [
    ../localization.nix
    ../../users
    ../../modules/nixos/core
    ../../modules/nixos/core/impermanence.nix
    ./disko.nix
    ../../modules/nixos/ssh-server
    ../../modules/nixos/services/services.nix
    ../../modules/nixos/hardware/network.nix
    ../../modules/nixos/hardware/pipewire.nix
    ../../modules/nixos/kde
    ../../modules/nixos/stylix
    ../../modules/nixos/steam/steam.nix
  ];

  networking.hostName = lib.mkForce "sasurai-vm";

  # Headless test box: expose a serial console (getty auto-spawns on it).
  # Incus's own console chardev is wired via -device (not -serial), so our
  # raw.qemu "-serial chardev:ts1" becomes serial0=ttyS0 in the guest.
  boot.kernelParams = [
    "console=ttyS0"
    "console=tty1"
    "earlyprintk=serial,ttyS0,115200"
    "loglevel=8"
    "ignore_loglevel"
  ];

  # The virtio storage/transport drivers are needed in the initrd to see the
  # Incus disk (/dev/sda) before the root filesystem is mounted.
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "virtio_console"
    "vsock"
    "vmw_vsock_virtio_transport"
    "vmw_vsock_virtio_transport_common"
    "9p"
    "9pnet"
    "9pnet_virtio"
  ];

  # Log straight into the desktop as emanon (KDE/SDDM), like sasurai.
  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  # sasurai uses /home/<user>/Pictures/wallpaper.jpg for stylix; a throwaway
  # VM has no such file, so theme from a bundled wallpaper instead.
  stylix.image = lib.mkForce pkgs.nixos-artwork.wallpapers.nineish-dark-gray;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username;
      hostname = "sasurai";
    };
    users.${username} = import ../../config/sasurai/home.nix;
  };

  # With impermanence /home/emanon starts empty: home-manager refuses to run
  # until its profile directory exists, so create it before every activation.
  systemd.services."home-manager-${username}".serviceConfig.ExecStartPre = ["${pkgs.coreutils}/bin/mkdir -p /home/${username}/.local/state/nix/profiles"];

  virtualisation.incus.agent.enable = true;

  # Temporary convenience access for the VM test box (not for the real host).
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  users.users.${username}.initialPassword = "vmtest";

  networking.firewall.enable = false;
}