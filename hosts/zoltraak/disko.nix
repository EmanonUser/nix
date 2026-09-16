{
  disko.devices = {
    disk.main = {
      type = "disk";
      # Adjust to your actual disk on the new laptop.
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1024M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypt";
              settings.allowDiscards = true;
              # Passphrase supplied by nixos-anywhere --disk-encryption-keys
              passwordFile = "/tmp/disk-encryption.key";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    zpool.zroot = {
      type = "zpool";
      mode = "";
      options = {
        ashift = "12";
        autotrim = "on";
      };
      rootFsOptions = {
        compression = "lz4";
        atime = "off";
      };
      datasets = {
        "persist" = {
          type = "zfs_fs";
          mountpoint = "/persist";
          mountOptions = ["noatime"];
        };
        "nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          mountOptions = ["noatime"];
        };
      };
    };
  };
}
