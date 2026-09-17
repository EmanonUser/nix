{
  config,
  hostname,
  ...
}: let
  keyDir = ../../../config/${hostname}/ssh;
in {
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # Static per-host host keys (config/<hostname>/ssh/), deployed identically on
  # every (re)install so client fingerprints never change.
  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  environment.etc."ssh/emanon_user_ca.pub".source = ../../../modules/ssh/user_ca.pub;

  # User certificate authorities for login + the host certificate.
  services.openssh.settings.TrustedUserCAKeys = "/etc/ssh/emanon_user_ca.pub";
  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
  '';

  # Impermanence wipes /etc/ssh on every boot, so re-place the static key and
  # its certificate (needs strict 0600 on the private key) at each activation.
  system.activationScripts.ssh-host-keys.text = ''
    install -m 600 -o root -g root ${keyDir}/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
    install -m 644 -o root -g root ${keyDir}/ssh_host_ed25519_key.pub /etc/ssh/ssh_host_ed25519_key.pub
    ${
      if builtins.pathExists "${keyDir}/ssh_host_ed25519_key-cert.pub"
      then "install -m 644 -o root -g root ${keyDir}/ssh_host_ed25519_key-cert.pub /etc/ssh/ssh_host_ed25519_key-cert.pub"
      else "" # not signed yet, `make sign-host-certs`
    }
  '';
}
