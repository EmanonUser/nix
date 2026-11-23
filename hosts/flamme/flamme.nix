{
  username,
  ...
}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "flamme";

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

  imports = [
    ../localization.nix
    ../../users/${username}/${username}.nix
    ../../configs/flamme/nixos.nix
  ];

  virtualisation.incus.agent.enable = true;
  programs.ssh.startAgent = true;
}
