{
  filesystem,
  lib,
  ...
}: {
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/ata-CT250MX500SSD1_2137E5D05541";
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
        root = {
          size = "100%";
          content =
            if filesystem == "zfs"
            then {
              type = "zfs";
              pool = "zroot";
            }
            else {
              type = "lvm_pv";
              vg = "rootvg";
            };
        };
      };
    };
  };

  disko.devices.lvm_vg.rootvg = lib.mkIf (filesystem != "zfs") {
    type = "lvm_vg";
    lvs = {
      nix = {
        size = "150G";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/nix";
          mountOptions = ["noatime"];
        };
      };
      persist = {
        size = "60G";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/persist";
        };
      };
      swap = {
        size = "12G";
        content = {
          type = "swap";
        };
      };
    };
  };

  disko.devices.zpool.zroot = lib.mkIf (filesystem == "zfs") {
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
      "nix" = {
        type = "zfs_fs";
        mountpoint = "/nix";
        mountOptions = ["noatime"];
      };
      "persist" = {
        type = "zfs_fs";
        mountpoint = "/persist";
      };
    };
  };
}
