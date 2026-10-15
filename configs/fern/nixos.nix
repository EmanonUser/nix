{
  lib,
  pkgs,
  config,
  username,
  hostname,
  vm ? false,
  ...
}: {
  imports =
    [
      ../../modules/nixos/core/settings.nix
      ../../modules/nixos/core/fonts.nix
      ../../modules/nixos/core/agenix.nix
      ../../modules/nixos/core/impermanence.nix
      ../../modules/nixos/services/services.nix
      ../../modules/nixos/ssh-server/ssh-server.nix
      ./incus.nix
      ./monitoring.nix
      ./samba.nix
      ./zfs-scrub.nix
      ./zrepl.nix
      ./nix-packages/nix-packages.nix
    ]
    ++ lib.optional (!vm) ../../hosts/fern/disko.nix
    ++ lib.optional vm ../../hosts/fern-vm/disko.nix
    ++ [./zfs/keys.nix ./backup.nix];

  networking.hostName = hostname;

  # The VM doesn't need the user SSH identity (install-fern-vm seeds fern's
  # host key so the ZFS keys still decrypt).
  age.secrets."user-ssh-id".enable = lib.mkIf vm false;

  environment.persistence."/persist".directories = [
    "/var/lib/samba"
    "/var/lib/zrepl"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # zfs_unstable is what a data pool with 87% capacity and live Incus VMs
  # wants; nixpkgs' `zfs` is the stable 2.x line.
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.package = pkgs.zfs_unstable;

  # fern has no ZFS root (ext4 on LVM), so there is nothing to force-import in
  # the initrd; the data pool is imported unforced in stage 2. Explicitly false
  # both to say so and to silence nixpkgs' deprecation of the old true default.
  boot.zfs.forceImportRoot = false;

  # systemd-networkd rather than NetworkManager/dhcpcd: br0 has to be declared,
  # and networkd is the only backend here that can do that with a plain option.
  networking.useNetworkd = true;
  networking.useDHCP = lib.mkForce vm;

  systemd.network = {
    netdevs."10-br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
      # Matches /etc/network/interfaces on the live host (STP off).
      bridgeConfig.STP = false;
    };

    # eno1 is the LAN/DMZ NIC. DHCP covers v4 + v6/SLAAC in one go; the search
    # domains come from the live host's DHCP lease, pinned here so they survive
    # a resolver that stops advertising them.
    networks."10-eno1" = {
      matchConfig.Name = "eno1";
      DHCP = "yes";
      domains = ["home.emanon.dev" "home.arpa"];
    };

    # eno2 carries the Incus VMs (caddy-vm, debian-vm, nixos-vm, qbittorrent-vm,
    # torrents-vm) via br0, so those VMs land on the real LAN (192.168.5.0/24)
    # instead of behind incusbr0's NAT. It is a bridge port only - no address,
    # and IPv6 is off, matching the live host.
    networks."10-eno2" = {
      matchConfig.Name = "eno2";
      networkConfig = {
        Bridge = "br0";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "no";
      };
    };

    # br0 itself carries no addresses; Incus' br-lan sits on top of it and the
    # VMs get their own addresses on the real LAN.
    networks."10-br0" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "no";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "no";
      };
    };
  };

  boot.zfs.extraPools = ["fern"];

  # 8 GiB ARC, matching /etc/modprobe.d/zfs.conf on the live host.
  boot.extraModprobeConfig = ''
    options zfs zfs_arc_max=8589934592
  '';

  # The encrypted children stay unmounted without this: nixpkgs masks the
  # OpenZFS-provided zfs-load-key.service to /dev/null.
  systemd.services."fern-zfs-load-keys" = {
    description = "Load encryption keys for the fern ZFS pool";
    unitConfig.DefaultDependencies = false;
    wantedBy = ["zfs.target"];
    after = ["zfs-import.target" "systemd-udev-settle.service"];
    before = ["zfs-mount.service" "local-fs.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.boot.zfs.package}/sbin/zfs load-key -a";
    };
  };

  # nftables rather than firewalld: firewalld is installed on the live host but
  # inactive, and the Ansible role that managed it was never applied to fern.
  networking.nftables.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username;
      hostname = "fern";
    };
    users.${username} = import ./home.nix;
  };
}
