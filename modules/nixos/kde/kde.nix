{
  config,
  lib,
  pkgs,
  ...
}: let
  plasmaWaylandSessions = pkgs.runCommand "plasma-wayland-sessions" {} ''
    mkdir -p "$out/share/wayland-sessions"
    cp -a ${pkgs.kdePackages.plasma-workspace.sessions}/share/wayland-sessions/. "$out/share/wayland-sessions/"
  '' // {
    providedSessions = ["plasma"];
  };
in {
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.displayManager.defaultSession = "plasma";

  services.displayManager.sessionPackages = lib.mkForce (
    [plasmaWaylandSessions]
    ++ lib.optional (config.services.niri.waylandSessionPackage or null != null)
    config.services.niri.waylandSessionPackage
  );
  environment.plasma6.excludePackages = [pkgs.kdePackages.kwin-x11];
}
