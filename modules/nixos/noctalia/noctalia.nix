{
  # Noctalia flake v5 (Basement) shell services.
  # https://github.com/noctalia-dev/noctalia
  noctalia,
  ...
}: {
  imports = [noctalia.nixosModules.default];

  # NetworkManager, Bluetooth, power-profiles-daemon, upower + systemd user services
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  services.gnome.gcr-ssh-agent.enable = false;
}
