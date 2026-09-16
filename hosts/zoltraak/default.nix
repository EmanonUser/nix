{
  imports = [
    ../localization.nix
    ./hardware-configuration.nix
    ./../../users
    ./../../config/zoltraak/nixos.nix
  ];

  programs.ssh.startAgent = true;

  # Required by ZFS (the pool lives on LUKS).
  networking.hostId = "a6aa5c96";
  boot.zfs.forceImportRoot = false;
}
