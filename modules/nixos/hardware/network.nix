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

  environment.persistence."/persist".directories = [
    "/etc/NetworkManager/system-connections"
    "/var/lib/NetworkManager"
  ];
}
