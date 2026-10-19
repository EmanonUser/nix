{...}: let
  # Windows "Previous Versions" for one ZFS dataset. zrepl names every snapshot
  # zrepl_%Y%m%d_%H%M%S_000 (UTC), so a single constant format works for all.
  shadowShare = path: {
    "path" = path;
    "browseable" = "yes";
    "read only" = "no";
    "valid users" = "emanon";
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
      # The pool root has no snapshots of its own and shadow_copy2's
      # snapdirseverywhere can't reach the child datasets' hidden .zfs, so it
      # stays a plain browsing share; Previous Versions comes from the
      # per-dataset shares below.
      fern = {
        "comment" = "My manually managed ZFS dataset";
        "path" = "/fern";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "emanon";
        "create mask" = "0755";
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
}
