{
  ...
}: {
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  environment.etc."ssh/emanon_user_ca.pub".source = ./user_ca.pub;

  services.openssh.settings.TrustedUserCAKeys = "/etc/ssh/emanon_user_ca.pub";
  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
  '';
}
