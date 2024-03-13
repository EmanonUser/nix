{
  imports = [
    ./hardware-configuration.nix
  ];

  programs.ssh.startAgent = true;
}
