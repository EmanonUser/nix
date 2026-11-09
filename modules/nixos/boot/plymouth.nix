{
  lib,
  pkgs,
  ...
}: {
  boot.plymouth = {
    enable = true;
    theme = lib.mkDefault "hexagon_dots";
    themePackages = lib.mkDefault [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = ["hexagon_dots"];
      })
    ];
  };
}
