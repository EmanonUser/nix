{lib, username, ...}: {
  programs.home-manager.enable = true;
  home.username = "${username}";
  # mkForce: with immutable users home-manager would push /var/empty otherwise.
  home.homeDirectory = lib.mkForce "/home/${username}";
  home.stateVersion = "25.05";
}
