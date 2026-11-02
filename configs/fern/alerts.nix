{
  config,
  ...
}: {
  # ProtonMail submission for system alerts. ZED (ZFS events) and smartd (disk
  # health) both shell out to a sendmail-compatible binary; programs.msmtp
  # installs /run/wrappers/bin/sendmail for exactly that, and its presence flips
  # on the mail defaults in the ZED and smartd modules.
  programs.msmtp = {
    enable = true;
    defaults = {
      auth = true;
      tls = true;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      syslog = true;
    };
    accounts.default = {
      host = "smtp.protonmail.ch";
      port = 587;
      from = "notifications@emanon.dev";
      user = "notifications@emanon.dev";
      passwordeval = "cat ${config.age.secrets.smtp-notifications.path}";
      allow_from_override = false;
      set_from_header = true;
    };
  };

  age.secrets.smtp-notifications.file = ../../users/emanon/smtp-notifications.age;

  services.zfs.zed.settings.ZED_EMAIL_ADDR = ["moemanon@pm.me"];

  services.smartd.notifications.mail = {
    enable = true;
    recipient = "moemanon@pm.me";
    sender = "notifications@emanon.dev";
  };
}
