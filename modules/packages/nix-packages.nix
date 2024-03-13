{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # archives and compression
    zip
    xz
    unzip
    p7zip
    zstd
    restic
    yj
    jq

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
    lm_sensors
    amdgpu_top
    pciutils

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
