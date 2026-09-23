{
  lib,
  pkgs,
  ...
}: {
  boot.plymouth = {
    enable = true;

    # Shared default; hosts can override boot.plymouth.theme locally
    # (e.g. zoltraak uses "text" for headless boots).
    theme = lib.mkDefault "hexagon_dots";
    themePackages = lib.mkDefault [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = ["hexagon_dots"];
      })
    ];
  };
}
