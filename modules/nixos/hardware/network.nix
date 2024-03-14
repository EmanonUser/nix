{
  username,
  hostname,
  ...
}: {
  users.users.${username} = {
    extraGroups = ["networkmanager"];
  };
  networking.hostName = "${hostname}";
  networking.networkmanager.enable = true;
}
