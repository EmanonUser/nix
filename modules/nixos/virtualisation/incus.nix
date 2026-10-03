{username, ...}: {
  users.users.${username} = {
    extraGroups = ["incus-admin"];
  };

  virtualisation.incus.enable = true;
  networking.nftables.enable = true;
  virtualisation.incus.preseed = {
    storage_pools = [
      {
        name = "default";
        driver = "dir";
        config.source = "/var/lib/incus/storage-pools/default";
      }
    ];

    networks = [
      {
        name = "incusbr0";
        type = "bridge";
        config = {
          "ipv4.address" = "10.121.190.1/24";
          "ipv4.nat" = "true";
          "ipv6.address" = "fd42:121:190::1/64";
          "ipv6.nat" = "true";
          "ipv6.routing" = "true";
        };
      }
    ];

    profiles = [
      {
        name = "default";
        description = "Default Incus profile";
        devices = {
          eth0 = {
            name = "eth0";
            network = "incusbr0";
            type = "nic";
          };
          root = {
            path = "/";
            pool = "default";
            type = "disk";
            size = "20GiB";
          };
        };
      }
    ];
  };
}
