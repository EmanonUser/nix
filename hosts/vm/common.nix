# Generic adaptations to run any host's configuration inside a throwaway
# Incus VM. Only imported by the -vm flake outputs (specialArgs vm = true);
# the rest of the host config is unchanged, so testing == running the same
# config as production.
{
  config,
  lib,
  pkgs,
  username,
  netHostName,
  ...
}: {
  # Every VM sees its virtio disk as /dev/sda (overrides the bare-metal device).
  disko.devices.disk.main.device = lib.mkForce "/dev/sda";

  # Don't advertise the bare-metal hostname on the LAN: this is a test box.
  networking.hostName = lib.mkForce netHostName;

  # Serial console (incus provides no VGA monitor).
  boot.kernelParams = [
    "console=ttyS0"
    "console=tty1"
    "earlyprintk=serial,ttyS0,115200"
    "loglevel=8"
    "ignore_loglevel"
  ];

  # Virtio storage/transport drivers in the initrd to see /dev/sda before the
  # root filesystem is mounted.
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

  # No host GPU: modesetting + llvmpipe software rendering is enough to test.
  services.xserver.videoDrivers = lib.mkForce ["modesetting"];

  # The bare-metal stylix image (host ~/Pictures/wallpaper.jpg) doesn't exist
  # on a throwaway VM, so theme from a bundled wallpaper instead.
  stylix.image = lib.mkForce pkgs.nixos-artwork.wallpapers.nineish-dark-gray;

  # Incus agent so the VM host can run commands/exec inside the instance.
  virtualisation.incus.agent.enable = true;

  # Throwaway test box conveniences.
  networking.firewall.enable = false;
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  users.users.${username}.initialPassword = lib.mkForce "vmtest";

  # With impermanence /home/<username> starts empty: home-manager refuses to
  # run until its profile directory exists, so create it before activation.
  systemd.services."home-manager-${username}".serviceConfig.ExecStartPre = ["${pkgs.coreutils}/bin/mkdir -p /home/${username}/.local/state/nix/profiles"];
}