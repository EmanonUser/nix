{pkgs, ...}: {
  home.packages = with pkgs; [
    # developpement
    alejandra
    ansible
    ansible-lint
    cargo-expand
    cargo-watch
    docker
    ltrace
    rustup
    sshpass # ansible requirement
    strace
    zola

    # utils
    fd
    fzf
    gnupg
    htop
    jq
    jq
    lm_sensors
    lsof
    pciutils
    rclone
    ripgrep
    rsync
    tree
    which
    yj
    hyfetch

    # networking
    curl
    dnsutils
    ethtool
    iperf3
    mtr
    nmap
    socat
    tcpdump
    whois
    aria2
  ];
}
