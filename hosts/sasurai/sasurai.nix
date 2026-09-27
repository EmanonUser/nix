{username, ...}: {
  imports = [
    ../localization.nix
    ./hardware-configuration.nix
    ./../../users/${username}/${username}.nix
    ./../../config/sasurai/nixos.nix
  ];

  programs.ssh.startAgent = true;
}
