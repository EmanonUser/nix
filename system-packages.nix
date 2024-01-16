{
  config,
  pkgs,
  ...
}: {
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
}
