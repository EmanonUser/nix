{
  lib,
  username,
  vm ? false,
  ...
}: {
  users.users.${username}.extraGroups = lib.mkIf (!vm) ["incus-admin"];

  # Host side only. The containers/VMs and profiles are Terraform resources
  # (dev/incus), and incus-preseed re-applies on every boot, so only the
  # storage pool and networks are declared here.
  virtualisation.incus = lib.mkIf (!vm) {
    enable = true;
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
            "ipv4.address" = "10.188.165.1/24";
            "ipv4.nat" = "true";
            "ipv6.address" = "fd42:7dab:7518:2c4e::1/64";
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
    };
  };
}
