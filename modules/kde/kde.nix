{
  pkgs,
  lib,
  ...
}: {
  home.activation.kwinFollowLocale1 = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group Wayland --key FollowLocale1 true --notify
  '';
}
