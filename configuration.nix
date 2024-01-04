{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  boot.initrd.luks.devices."luks-69f07c4f-4348-468f-8dd2-caff60fd31fe".device = "/dev/disk/by-uuid/69f07c4f-4348-468f-8dd2-caff60fd31fe";
  users.users.emanon.shell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  networking.hostName = "nixos";
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

  services.xserver.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.hyprland.enable = true;

  services.xserver = {
    layout = "fr";
    xkbVariant = "azerty";
  };
  console.keyMap = "fr";

  services.printing.enable = true;
  services.openssh.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.emanon = {
    isNormalUser = true;
    description = "emanon";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      firefox
      kate
    ];
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {inherit inputs;};
    users = {
      "emanon" = import ./home.nix;
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim
    curl
    google-chrome
    discord
    fd
    ripgrep
    git
    bitwarden
    docker
    rsync
    rclone
    ansible
    ansible-lint
    rustup
    zellij
    home-manager
    alacritty
    atuin
    zsh
    neofetch
    vlc
    stow
    clang
    starship
    ntfs3g
    alejandra
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.stateVersion = "23.11";
}
