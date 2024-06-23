{
  pkgs,
  username,
  ...
}: {
  home.packages = with pkgs; [
    hyprpaper
  ];

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = /home/${username}/Pictures/wallpaper.jpg
    wallpaper = DP-2,/home/${username}/Pictures/wallpaper.jpg
  '';
}
