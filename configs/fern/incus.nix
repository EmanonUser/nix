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
    };
  };
}
