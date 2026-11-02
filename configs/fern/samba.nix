{
  config,
  ...
}: let
  shadowShare = path: {
    "path" = path;
    "browseable" = "yes";
    "read only" = "no";
    "valid users" = "emanon";
    "create mask" = "0644";
    "directory mask" = "0755";
    "vfs objects" = "shadow_copy2";
    "shadow:snapdir" = ".zfs/snapshot";
    "shadow:format" = "zrepl_%Y%m%d_%H%M%S_000";
    "shadow:localtime" = "no";
    "shadow:sort" = "desc";
  };
in {
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server role" = "standalone server";
        "log file" = "/var/log/samba/log.%m";
        "max log size" = "1000";
        "logging" = "file";
        "panic action" = "/usr/share/samba/panic-action %d";
        "obey pam restrictions" = "yes";
        "unix password sync" = "yes";
        "passwd program" = "/usr/bin/passwd %u";
        "passwd chat" = "*Enter\\snew\\s*\\spassword:* %n\\n *Retype\\snew\\s*\\spassword:* %n\\n *password\\supdated\\ssuccessfully* .";
        "pam password change" = "yes";
        "map to guest" = "bad user";
        "usershare allow guests" = "yes";
      };
      fern = {
        "comment" = "My manually managed ZFS dataset";
        "path" = "/fern";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "emanon";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      data = shadowShare "/fern/data";
      documents = shadowShare "/fern/emanon/documents";
      other_users = shadowShare "/fern/emanon/other_users";
      dev = shadowShare "/fern/emanonlab/dev";
      secrets = shadowShare "/fern/emanonlab/secrets";
      games_server = shadowShare "/fern/emanonlab/games_server";
    };
  };

  age.secrets.smb-password.file = ../../users/emanon/smb-password.age;

  systemd.services.samba-smb-user = {
    description = "Set emanon's SMB password from the agenix secret";
    wantedBy = ["multi-user.target"];
    after = ["samba-smbd.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      pw=$(cat ${config.age.secrets.smb-password.path})
      printf '%s\n%s\n' "$pw" "$pw" | ${config.services.samba.package}/bin/smbpasswd -a -s emanon
    '';
  };
}
