{
  config,
  lib,
  pkgs,
  username,
  netHostName,
  ...
}: {
  disko.devices.disk.main.device =
    lib.mkForce "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_incus_root";

  networking.hostName = lib.mkForce netHostName;
  boot.kernelParams = [
    "console=ttyS0"
    "console=tty1"
    "earlyprintk=serial,ttyS0,115200"
    "loglevel=8"
    "ignore_loglevel"
  ];

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

  services.xserver.videoDrivers = lib.mkForce ["modesetting"];
  virtualisation.incus.agent.enable = true;

  systemd.network.networks = lib.mkForce {
    "10-lan" = {
      matchConfig.Name = "enp5s0";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
    };
    "10-br0" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "no";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "no";
      };
    };
  };

  networking.firewall.enable = false;
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  users.users.${username}.initialPassword = lib.mkForce "vmtest";

  # With impermanence /home/<username> starts empty: home-manager refuses to
  # run until its profile directory exists, so create it before activation.
  systemd.services."home-manager-${username}".serviceConfig.ExecStartPre = ["${pkgs.coreutils}/bin/mkdir -p /home/${username}/.local/state/nix/profiles"];
}
