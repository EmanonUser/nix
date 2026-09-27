{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.services.niri;
in {
  options.services.niri.login = lib.mkOption {
    type = lib.types.enum ["greetd" "noctalia-greeter" "none"];
    default = "greetd";
    description = ''
      How niri is started at login:

      - `greetd`: greetd logs straight into `niri-session` as `${username}`.
      - `noctalia-greeter`: greetd shows the Noctalia Greeter login screen first
        (defaults to niri and `${username}`). Session locking (Noctalia shell's
        own lock screen) works either way.
      - `none`: leave the login manager alone; an external display manager
        (e.g. SDDM) is used and the niri Wayland session is registered as a
        session package so it can be picked from the login screen.
    '';
  };

  options.services.niri.waylandSessionPackage = lib.mkOption {
    type = lib.types.nullOr lib.types.package;
    internal = true;
    default = null;
    description = ''
      Session package registered with the external display manager when
      `services.niri.login` is set to `none`.
    '';
  };

  config = lib.mkMerge [
    {
      programs.niri = {
        enable = true;
        useNautilus = false;
      };

      environment.systemPackages = [pkgs.wl-clipboard];
      programs.xwayland.enable = true;
      services.gnome.gcr-ssh-agent.enable = false;

      # Make user-profile binaries available in niri binds.
      environment.sessionVariables.PATH = [
        "${config.home-manager.users.${username}.home.profileDirectory}/bin"
      ];
    }

    (lib.mkIf (cfg.login == "greetd") {
      services.greetd = {
        enable = true;
        settings.default_session = {
          user = username;
          command = "${pkgs.niri}/bin/niri-session";
        };
      };
    })

    (lib.mkIf (cfg.login == "noctalia-greeter") {
      services.displayManager.noctalia-greeter = {
        enable = true;
        settings = {
          session.default = "niri";
          user.default = username;
          keyboard = {
            layout = "fr";
            numlock = true;
          };
        };
      };

      services.greetd.settings.default_session.user = "greeter";
      users.groups.greeter = {};

      users.users.greeter = {
        isSystemUser = true;
        group = "greeter";
        home = "/var/lib/noctalia-greeter";
      };
    })

    # External display manager (e.g. SDDM): don't manage login, but announce
    # niri as a selectable Wayland session. niri ships
    # share/wayland-sessions/niri.desktop.
    (lib.mkIf (cfg.login == "none") {
      services.niri.waylandSessionPackage =
        pkgs.niri
        // {
          providedSessions = ["niri"];
        };
    })
  ];
}
