{
  pkgs,
  ...
}: let
  # environment.etc only writes its /etc/ssh symlinks during an activation, so
  # with /etc/ssh bind-mounted from a clean /persist, the very first boot of a
  # fresh install has no sshd_config or user_ca.pub yet (they were written to
  # the discarded install root). Recreate every config symlink from the store
  # (via /etc/static) right before sshd starts; this also keeps them current
  # after every activation without waiting for a switch.
  rebuildSshEtc = pkgs.writeShellScript "ssh-rebuild-etc-symlinks" ''
    mkdir -p /etc/ssh
    for f in /etc/static/ssh/*; do
      [ -e "$f" ] && ln -sfn "$f" "/etc/ssh/$(basename "$f")"
    done
  '';
in {
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  environment.etc."ssh/user_ca.pub".source = ./user_ca.pub;

  services.openssh.settings.TrustedUserCAKeys = "/etc/ssh/user_ca.pub";
  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
  '';

  systemd.services.sshd = {
    after = ["etc-ssh.mount"];
    serviceConfig.ExecStartPre = [rebuildSshEtc];
  };
}
