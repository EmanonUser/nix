{
  config,
  lib,
  username,
  ...
}: {
  imports = [../noctalia/noctalia.nix];

  programs.umbriel.enable = true;

  programs.noctalia.recommendedServices.enable = lib.mkForce false;
  services.upower.enable = lib.mkForce false;

  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      user.default = username;
      session.default = "umbriel";
      keyboard = {
        layout = "fr";
        variant = "azerty";
        numlock = true;
      };
      cursor.size = 24;
    };
  };

  services.greetd.settings.initial_session = {
    command = "${config.programs.umbriel.package}/bin/start-umbriel";
    user = username;
  };

  services.displayManager.sddm.enable = lib.mkForce false;
}
