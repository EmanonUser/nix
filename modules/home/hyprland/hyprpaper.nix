{pkgs, ...}: {
  home.packages = with pkgs; [
    hyprpaper
  ];

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = /home/emanon/Pictures/wallpaper.jpg
    wallpaper = DP-2,/home/emanon/Pictures/wallpaper.jpg
  '';
}
