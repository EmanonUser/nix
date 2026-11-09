{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Agent / infrastructure-as-code
    ansible
    ansible-lint
    terraform
    opentofu
    age
    restic
    zrepl
    samba
    cifs-utils

    # Monitoring / diagnostics
    glances
    smartmontools
    lm_sensors
    vnstat
    powertop
    nvtopPackages.full
    btop

    # Networking
    nmap
    mtr
    tcpdump
    iperf3
    socat
    dnsutils
    ethtool
    iproute2
    nftables
    traceroute
    whois

    # Storage / filesystem
    lsof
    ncdu
    tree
    rsync
    fio
    gptfdisk
    parted

    # Misc
    htop
    ripgrep
    fd
    jq
    tmux
    git
    curl
    wget
    pciutils
    usbutils
  ];
}
