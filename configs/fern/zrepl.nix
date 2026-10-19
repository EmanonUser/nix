{...}: {
  services.zrepl = {
    enable = true;
    settings = {
      global = {
        logging = [
          {
            type = "syslog";
            format = "human";
            level = "warn";
          }
        ];
      };
      # Every job uses the same "zrepl_" prefix: each dataset belongs to exactly
      # one job, so the prefix only scopes pruning (a single ^zrepl_.* does it),
      # and a constant name lets Samba's shadow_copy2 use one shadow:format.
      jobs = [
        {
          name = "zrepl_default";
          type = "snap";
          filesystems = {
            "fern/data" = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = "zrepl_";
            interval = "1h";
          };
          pruning = {
            keep = [
              {
                type = "grid";
                grid = "2x48h(keep=all) | 1x30d(keep=1) | 1x90d(keep=1)";
                regex = "^zrepl_.*";
              }
              {
                type = "regex";
                negate = true;
                regex = "^zrepl_.*";
              }
            ];
          };
        }
        {
          name = "zrepl_P2";
          type = "snap";
          filesystems = {
            "fern/emanon/documents" = true;
            "fern/emanon/other_users" = true;
            "fern/emanonlab/dev" = true;
            "fern/emanonlab/secrets" = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = "zrepl_";
            interval = "6h";
          };
          pruning = {
            keep = [
              {
                type = "grid";
                grid = "1x14d(keep=all) | 1x30d(keep=all) | 1x365d(keep=1)";
                regex = "^zrepl_.*";
              }
              {
                type = "regex";
                negate = true;
                regex = "^zrepl_.*";
              }
            ];
          };
        }
        {
          name = "zrepl_P3";
          type = "snap";
          filesystems = {
            "fern/emanonlab/games_server" = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = "zrepl_";
            interval = "10m";
          };
          pruning = {
            keep = [
              {
                type = "grid";
                grid = "1x1h(keep=all) | 1x24h(keep=1)";
                regex = "^zrepl_.*";
              }
              {
                type = "regex";
                negate = true;
                regex = "^zrepl_.*";
              }
            ];
          };
        }
      ];
    };
  };
}
