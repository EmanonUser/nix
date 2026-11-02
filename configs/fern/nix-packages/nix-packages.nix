# Host-level packages for fern (the NixOS server). Home-manager user packages
# live in configs/fern/home-packages/home-packages.nix.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Agent / infrastructure-as-code
    ansible
    ansible-lint
    terraform
    opentofu
    age
    restic

    # ZFS operations. `zfs` itself is NOT listed: boot.zfs.package
    # (zfs_unstable) is already put on PATH by the zfs module, and asking for
    # the stable `pkgs.zfs` too makes the two collide over bin/zpool.
    zrepl

    # Samba / file sharing
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
