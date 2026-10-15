{username, vm ? false, ...}: {
  users.users.${username}.extraGroups = ["incus-admin"];

  # Host side only. The containers/VMs and profiles are Terraform resources
  # (dev/incus), and incus-preseed re-applies on every boot, so only the
  # storage pool and networks are declared here.
  #
  # On the VM the block below must NOT reuse 10.188.165.0/24: inside fern-vm
  # that prefix is the incus-bridge profile NIC the VM is reached on, so a
  # second interface on the same subnet (this incusbr0) wins the route to the
  # gateway and the VM becomes unreachable. Use a distinct test subnet instead.
  virtualisation.incus = {
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
