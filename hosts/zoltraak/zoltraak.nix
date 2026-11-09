{username, ...}: {
  imports = [
    ../localization.nix
    ./hardware-configuration.nix
    ./../../users/${username}/${username}.nix
    ./../../configs/zoltraak/nixos.nix
  ];

  programs.ssh.startAgent = true;

  networking.hostId = "a6aa5c96";
  boot.zfs.forceImportRoot = false;
}
