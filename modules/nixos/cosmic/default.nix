{
  # COSMIC enables gnome-keyring (→ gcr-ssh-agent) by default, which conflicts
  # with programs.ssh.startAgent. Keep the keyring, drop its SSH agent.
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
}
