{
  config,
  lib,
  pkgs,
  ...
}: let
  # plasma-workspace ships both a Wayland and an X11 session; prune the X11
  # one so SDDM offers Plasma (Wayland) only.
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

  # Default to the Plasma Wayland session (matching the only remaining
  # session file, see plasmaWaylandSessions above).
  services.displayManager.defaultSession = "plasma";

  # Plasma (Wayland) plus any compositor sessions registered by other modules
  # (e.g. niri when services.niri.login = "none").
  services.displayManager.sessionPackages = lib.mkForce (
    [plasmaWaylandSessions]
    ++ lib.optional (config.services.niri.waylandSessionPackage or null != null)
    config.services.niri.waylandSessionPackage
  );

  # No X11 compositor: the Wayland session is the only supported one.
  environment.plasma6.excludePackages = [pkgs.kdePackages.kwin-x11];
}