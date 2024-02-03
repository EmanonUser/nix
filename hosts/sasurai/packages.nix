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
    rsync
    rclone
    htop

    # development
    git
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
  ];
}
