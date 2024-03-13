{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  networking.hostName = "sasurai";
  networking.networkmanager.enable = true;

  services.xserver.videoDrivers = ["amdgpu"];

  users.users.emanon = {
    isNormalUser = true;
    description = "emanon";
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "docker" "wireshark" "libvirtd"];
  };
}
