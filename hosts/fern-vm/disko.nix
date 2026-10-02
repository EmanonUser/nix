# Small-disk variant of fern's layout for the test VM: same ext4-on-LVM +
# impermanence structure, but sized for a ~30G virtio disk. The device is
# forced to /dev/sda by hosts/vm/common.nix.
{lib, ...}: {
  disko.devices.disk.main = {
    type = "disk";
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
          content = {
            type = "lvm_pv";
            vg = "rootvg";
          };
        };
      };
    };
  };

  disko.devices.lvm_vg.rootvg = {
    type = "lvm_vg";
    lvs = {
      nix = {
        size = "20G";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/nix";
          mountOptions = ["noatime"];
        };
      };
      persist = {
        size = "6G";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/persist";
        };
      };
      swap = {
        size = "2G";
        content = {
          type = "swap";
        };
      };
    };
  };
}
