{
  # Reuse the shared VM disk layout (VirtIO /dev/sda, LUKS crypt, btrfs/zfs
  # selected by the `filesystem` specialArg).
  imports = [
    ../nixos-vm/disko.nix
  ];
}