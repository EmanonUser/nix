{username, ...}: {
  imports = [
    ../localization.nix
    ./hardware-configuration.nix
    ./../../users/${username}/${username}.nix
    ./../../configs/sasurai/nixos.nix
  ];

  programs.ssh.startAgent = true;
}
