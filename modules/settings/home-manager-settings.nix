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

  # Remove the XDG user dirs we never use. Setting them to null drops them from
  # user-dirs.dirs, so xdg-user-dirs won't recreate the folders. The existing
  # directories on disk are left untouched (delete them manually if wanted).
  xdg.userDirs = {
    enable = true;
    music = null;
    pictures = null;
    videos = null;
    projects = null;
    publicShare = null;
    templates = null;
  };
  # The legacy files written by xdg-user-dirs-update exist; force-overwrite them.
  xdg.configFile."user-dirs.dirs".force = true;
  xdg.configFile."user-dirs.conf".force = true;
}
