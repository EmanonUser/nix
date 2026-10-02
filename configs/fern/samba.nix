{...}: {
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
        "create mask" = "0755";
        "directory mask" = "0755";
      };
      homes = {
        "comment" = "Home Directories";
        "browseable" = "no";
        "read only" = "yes";
        "create mask" = "0700";
        "directory mask" = "0700";
        "valid users" = "%S";
      };
      printers = {
        "comment" = "All Printers";
        "browseable" = "no";
        "path" = "/var/tmp";
        "printable" = "yes";
        "guest ok" = "no";
        "read only" = "yes";
        "create mask" = "0700";
      };
      # Quoted because `print$` is not a bare Nix identifier.
      "print$" = {
        "comment" = "Printer Drivers";
        "path" = "/var/lib/samba/printers";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "no";
      };
    };
  };
}
