{
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  environment.etc."ssh/emanon_user_ca.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQd1ns90RWNTdaxdk0UrxfNQdWKAPm0HBZOGVZ98Tsm Users Certificate Authority created at Wed Jul  9 09:42:45 AM CEST 2025
  '';

  services.openssh.settings.TrustedUserCAKeys = "/etc/ssh/emanon_user_ca.pub";
}
