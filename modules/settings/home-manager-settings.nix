{
  lib,
  username,
  ...
}: {
  programs.home-manager.enable = true;
  home.username = "${username}";
  # mkForce: with immutable users home-manager would push /var/empty otherwise.
  home.homeDirectory = lib.mkForce "/home/${username}";
  home.stateVersion = "25.05";

  xdg.userDirs = {
    enable = true;
    music = null;
    pictures = null;
    videos = null;
    projects = null;
    publicShare = null;
    templates = null;
  };
  xdg.configFile."user-dirs.dirs".force = true;
  xdg.configFile."user-dirs.conf".force = true;
}
