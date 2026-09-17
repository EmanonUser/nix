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

  # Boot straight into niri as `username`.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = username;
        command = "${pkgs.niri}/bin/niri-session";
      };
    };
  };
}
