{username, ...}: {
  users.users.${username} = {
    extraGroups = ["podman"];
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
