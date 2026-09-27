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

  # Noctalia's GNOME services bring an SSH agent (gcr-ssh-agent), which
  # conflicts with programs.ssh.startAgent.
  services.gnome.gcr-ssh-agent.enable = false;
}
