{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
  ];


  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  networking.hostName = "sasurai";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerdfonts
  ];

  services.xserver.videoDrivers = ["amdgpu"];
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };
  console.keyMap = "fr";

  services = {
    fstrim.enable = true;
    printing.enable = true;
    openssh.enable = true;
    fwupd.enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    libGL
  ];

  hardware.opengl.extraPackages32 = with pkgs; [
    # For 32 bit applications
    driversi686Linux.amdvlk
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true; # For 32 bit applications

  users.users.emanon = {
    isNormalUser = true;
    description = "emanon";
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "docker" "wireshark" "libvirtd"];
  };
}
