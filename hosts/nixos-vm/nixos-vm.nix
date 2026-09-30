# Headless Incus VM used as the development environment: SSH in, edit, build.
# Layer 1 only - what this machine is. What it runs lives in
# configs/nixos-vm/nixos.nix, and the disk layout in hosts/vm/disko.nix.
{
  username,
  lib,
  ...
}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-vm";

  # Headless box: expose a serial console (getty auto-spawns on it). Incus's own
  # console chardev is wired via -device (not -serial), so our raw.qemu
  # "-serial chardev:ts1" becomes serial0=ttyS0 in the guest.
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
    ../../users/${username}/${username}.nix
    ../../configs/nixos-vm/nixos.nix
  ];

  # Convenience access for the dev VM: the real password (sealed in
  # users/emanon/password.age) is also the SSH one, so a fresh install is
  # reachable before any key is in place.
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  virtualisation.incus.agent.enable = true;
  networking.firewall.enable = false;
}
