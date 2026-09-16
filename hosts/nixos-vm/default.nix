{
  username,
  lib,
  pkgs,
  ...
}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-vm";

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

  services.getty.autologinUser = username;

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

  imports = [
    ../localization.nix
    ../../users
    ../../modules/nixos/core
    ../../modules/nixos/core/impermanence.nix
    ./disko.nix
    ../../modules/nixos/ssh-server
    ../../modules/nixos/services/services.nix
    ../../modules/nixos/hardware/network.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username;
      hostname = "nixos-vm";
    };
    users.${username} = import ./home.nix;
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
