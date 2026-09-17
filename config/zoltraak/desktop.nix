{
  config,
  noctalia,
  pkgs,
  username,
  ...
}: {
  imports = [noctalia.nixosModules.default];

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  # Noctalia brings an SSH agent (gcr-ssh-agent) with its GNOME services,
  # which conflicts with programs.ssh.startAgent.
  services.gnome.gcr-ssh-agent.enable = false;

  # niri (scrollable-tiling compositor) + portals, session, etc.
  programs.niri = {
    enable = true;
    useNautilus = false; # not needed, avoids pulling nautilus
  };

  # Allow X11 apps (chrome, discord) under niri
  programs.xwayland.enable = true;

  # Make user-profile binaries (kitty, ghostty, ...) available in niri binds.
  environment.sessionVariables.PATH = [
    "${config.home-manager.users.${username}.home.profileDirectory}/bin"
  ];

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
