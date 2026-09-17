{
  config,
  pkgs,
  username,
  ...
}: {
  # niri, the scrollable-tiling Wayland compositor.
  # https://github.com/YaLTeR/niri
  programs.niri = {
    enable = true;
    useNautilus = false; # not needed, avoids pulling nautilus
  };

  # Allow X11 apps (chrome, discord, ...) under niri.
  programs.xwayland.enable = true;

  # Make user-profile binaries (kitty, ghostty, ...) available in niri binds.
  environment.sessionVariables.PATH = [
    "${config.home-manager.users.${username}.home.profileDirectory}/bin"
  ];

  # Noctalia Greeter: greetd-based login screen, defaults to niri + `username`.
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

  # greetd runs the greeter as this dedicated system user.
  services.greetd.settings.default_session.user = "greeter";

  users.groups.greeter = {};

  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
    home = "/var/lib/noctalia-greeter";
  };
}
