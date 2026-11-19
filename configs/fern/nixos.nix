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
      ./alerts.nix
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

  age.secrets."user-ssh-id".enable = lib.mkIf vm false;

  # gh-token.age is sealed to fern's pre-NixOS host key and can no longer be
  # decrypted; re-add once re-sealed to configs/fern/ssh/ssh_host_ed25519_key.pub.

  environment.persistence."/persist".directories = [
    "/var/lib/samba"
    "/var/lib/zrepl"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.package = pkgs.zfs_unstable;

  boot.zfs.forceImportRoot = false;

  networking.useNetworkd = true;
  networking.useDHCP = lib.mkForce vm;

  systemd.network = {
    netdevs."10-br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
      bridgeConfig.STP = false;
    };

    networks."10-eno1" = {
      matchConfig.Name = "eno1";
      DHCP = "yes";
      domains = ["home.emanon.dev" "home.arpa"];
    };

    networks."10-eno2" = {
      matchConfig.Name = "eno2";
      networkConfig = {
        Bridge = "br0";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "no";
      };
    };

    networks."10-br0" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "no";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "no";
      };
    };
  };

  boot.zfs.extraPools = lib.mkForce [];
  systemd.services.fern-zfs-import = {
    description = "Import the fern ZFS data pool";
    wantedBy = ["zfs-import.target" "zfs.target"];
    wants = ["systemd-modules-load.service"];
    after = ["systemd-modules-load.service" "systemd-udev-settle.service"];
    before = ["fern-zfs-load-keys.service"];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "1";
      # -f: the pool records the exporting host's hostid, which differs from
      # networking.hostId across reinstalls.
      ExecStart = "${config.boot.zfs.package}/sbin/zpool import -N -f fern";
    };
  };

  # 8 GiB ARC
  boot.extraModprobeConfig = ''
    options zfs zfs_arc_max=8589934592
  '';

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

  networking.nftables.enable = true;
  # Filtering is done upstream on holo; keep the host out of the way of
  # bridged VM traffic and its DHCP/DNS.
  networking.firewall.enable = false;
  networking.firewall.extraForwardRules = ''
    iifname "br0" accept
    oifname "br0" accept
  '';

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
