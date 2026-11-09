{
  username,
  lib,
  ...
}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-vm";

  boot.kernelParams = [
    "console=ttyS0"
    "console=tty1"
    "earlyprintk=serial,ttyS0,115200"
    "loglevel=8"
    "ignore_loglevel"
  ];

  services.getty.autologinUser = username;

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
    ../../users/${username}/${username}.nix
    ../../configs/nixos-vm/nixos.nix
  ];

  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  virtualisation.incus.agent.enable = true;
  networking.firewall.enable = false;
}
