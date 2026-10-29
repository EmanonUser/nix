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
  # Pin the root disk by its stable QEMU/incus id: virtio enumeration gives
  # sda/sdb nondeterministically, and sda may be the separate ztest volume.
  disko.devices.disk.main.device =
    lib.mkForce "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_incus_root";

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

  # Incus agent so the VM host can run commands/exec inside the instance.
  virtualisation.incus.agent.enable = true;

  # A throwaway VM has a single virtio NIC on incusbr0 (name varies). The host
  # configs wire their real NICs (eno1/eno2 on fern) into br0; here DHCP the
  # one interface directly. Keep br0 as an internal bridge (no port): Incus'
  # br-lan network still needs its parent interface to exist.
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

  # Throwaway test box conveniences.
  networking.firewall.enable = false;
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  users.users.${username}.initialPassword = lib.mkForce "vmtest";

  # With impermanence /home/<username> starts empty: home-manager refuses to
  # run until its profile directory exists, so create it before activation.
  systemd.services."home-manager-${username}".serviceConfig.ExecStartPre = ["${pkgs.coreutils}/bin/mkdir -p /home/${username}/.local/state/nix/profiles"];
}
# No stylix override here: `stylix` is only an option on hosts that import
# modules/nixos/stylix, so defining it breaks every headless VM. It cannot be
# guarded on the option existing either - probing `config` here is
# self-referential, and an mkIf'd definition still trips the unmatched-option
# check. modules/nixos/stylix branches on `vm` itself instead.
