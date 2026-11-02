{
  lib,
  username,
  vm ? false,
  incusPkg,
  ...
}: {
  users.users.${username} = {
    extraGroups = ["incus-admin"];
    subUidRanges = [{startUid = 100000; count = 65536;}];
    subGidRanges = [{startGid = 100000; count = 65536;}];
  };
  users.users.root = {
    subUidRanges = lib.mkForce [{startUid = 1000000; count = 1000000000;}];
    subGidRanges = lib.mkForce [{startGid = 1000000; count = 1000000000;}];
  };

  virtualisation.incus = {
    enable = true;
    package = incusPkg;
    preseed = {
      storage_pools = [
        {
          name = "default";
          driver = "zfs";
          config = {
            source = "fern/incus";
            "zfs.pool_name" = "fern/incus";
          };
        }
      ];
      networks = [
        {
          name = "incusbr0";
          type = "bridge";
          config = {
            "ipv4.address" = if vm then "10.199.165.1/24" else "10.188.165.1/24";
            "ipv4.nat" = "true";
            "ipv6.address" = if vm then "fd42:7dab:7518:2c4f::1/64" else "fd42:7dab:7518:2c4e::1/64";
            "ipv6.nat" = "true";
          };
        }
        {
          name = "br-lan";
          type = "physical";
          config = {
            parent = "br0";
          };
        }
      ];
      profiles = [
        {
          name = "default";
          description = "Default Incus profile";
          devices = {
            root = {
              type = "disk";
              path = "/";
              pool = "default";
            };
          };
        }
        {
          name = "incus-bridge";
          description = "Default bridge network";
          devices = {
            incusbr0 = {
              type = "nic";
              network = "incusbr0";
            };
          };
        }
        {
          name = "data";
          devices.data = {
            type = "disk";
            source = "/fern/data";
            path = "/data";
            shift = "true";
          };
        }
        {
          name = "data-torrents";
          devices.data-torrents = {
            type = "disk";
            source = "/fern/data/torrents";
            path = "/data/torrents";
            shift = "true";
          };
        }
        {
          name = "data-torrents-misc";
          devices.data-torrents = {
            type = "disk";
            source = "/fern/data/torrents/misc/";
            path = "/data";
            shift = "true";
          };
        }
        {
          name = "data-media";
          devices.data-media = {
            type = "disk";
            source = "/fern/data/media";
            path = "/media";
            shift = "true";
          };
        }
        {
          name = "data-media-misc";
          devices.media-misc = {
            type = "disk";
            source = "/fern/data/media/misc";
            path = "/mnt/misc";
            shift = "true";
          };
        }
        {
          name = "pictures";
          devices.pictures = {
            type = "disk";
            source = "/fern/emanon/photos";
            path = "/pictures";
            shift = "true";
          };
        }
      ];
    };
  };

  systemd.services.incus-preseed = {
    after = ["zfs-import.target" "zfs-mount.service" "fern-zfs-load-keys.service"];
    wants = ["zfs-import.target" "zfs-mount.service" "fern-zfs-load-keys.service"];
  };
}
