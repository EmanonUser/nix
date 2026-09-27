{username, ...}: {
  users.users.${username} = {
    extraGroups = ["incus-admin"];
  };

  virtualisation.incus.enable = true;
  networking.nftables.enable = true;
}
