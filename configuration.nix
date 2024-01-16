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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-69f07c4f-4348-468f-8dd2-caff60fd31fe" = {
    device = "/dev/disk/by-uuid/69f07c4f-4348-468f-8dd2-caff60fd31fe";
    allowDiscards = true;
    bypassWorkqueues = true;
  };

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

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerdfonts
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.hyprland.enable = true;
  virtualisation.docker.enable = true;

  services.xserver = {
    layout = "fr";
    xkbVariant = "azerty";
  };
  console.keyMap = "fr";

  services = {
    fstrim.enable = true;
    printing.enable = true;
    openssh.enable = true;
    fwupd.enable = true;
  };

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
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "docker" "wireshark"];
    packages = with pkgs; [
    ];
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "emanon" = import ./home.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    # archives and compression
    zip
    xz
    unzip
    p7zip
    zstd

    # utils
    fd
    ripgrep
    fzf
    ntfs3g
    tree
    gnupg
    which
    lsof
    stow
    rsync
    rclone

    # development
    neovim
    git
    ansible
    ansible-lint
    rustup
    alejandra
    cargo-watch
    strace
    ltrace
    docker
    clang

    # networking
    iperf3
    mtr
    ethtool
    tcpdump
    wireshark
    whois
    curl
    socat
    nmap
    dnsutils
    aria2

    zsh
    alacritty
    zellij
    atuin
    google-chrome
    discord
    bitwarden
    vlc
    mpv
    rustdesk
    steam
  ];

  system.stateVersion = "23.11";
}
