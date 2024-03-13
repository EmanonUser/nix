{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  programs.ssh.startAgent = true;

  networking.hostName = "sasurai";
  networking.networkmanager.enable = true;
}
