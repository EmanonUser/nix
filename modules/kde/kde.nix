{
  pkgs,
  lib,
  ...
}: let
  font = "Obel Mono,10,-1,5,50,0,0,0,0,0";
in {
  home.activation = {
    kwinFollowLocale1 = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group Wayland --key FollowLocale1 true --notify
    '';

    kdeFonts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for key in font fixed smallFont menuFont toolBarFont; do
        $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key "$key" "${font}" --notify
      done
      $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group WM --key activeFont "${font}" --notify
    '';
  };
}
