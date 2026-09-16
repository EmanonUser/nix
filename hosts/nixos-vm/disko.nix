{
  filesystem,
  lib,
  ...
}: {
  disko.devices.disk.main = {
    type = "disk";
    # Virtio disk presented by incus/QEMU.
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
        root = {
          size = "100%";
          content =
            if filesystem == "zfs"
            then {
              type = "zfs";
              pool = "zroot";
            }
            else {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = ["compress=zstd" "noatime"];
                };
              };
            };
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

  # ZFS-specific boot wiring (harmless no-ops on btrfs).
  networking.hostId = lib.mkIf (filesystem == "zfs") "3f7c9e21";
  boot.zfs.forceImportRoot = lib.mkIf (filesystem == "zfs") false;
}
