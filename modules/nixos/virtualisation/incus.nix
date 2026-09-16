{username, ...}: {
  users.users.${username} = {
    extraGroups = ["incus-admin"];
  };

  virtualisation.incus.enable = true;

  # Incus refuses to run with iptables; requires nftables.
  networking.nftables.enable = true;
}
