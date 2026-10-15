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
      jobs = [
        {
          name = "zrepl_default";
          type = "snap";
          filesystems = {
            "fern/data" = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = "zrepl_default_";
            interval = "1h";
          };
          pruning = {
            keep = [
              {
                type = "grid";
                grid = "2x48h(keep=all) | 1x30d(keep=1) | 1x90d(keep=1)";
                regex = "^zrepl_default_.*";
              }
              {
                type = "regex";
                negate = true;
                regex = "^zrepl_default_.*";
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
            prefix = "zrepl_P2_";
            interval = "6h";
          };
          pruning = {
            keep = [
              {
                type = "grid";
                grid = "1x14d(keep=all) | 1x30d(keep=all) | 1x365d(keep=1)";
                regex = "^zrepl_P2_.*";
              }
              {
                type = "regex";
                negate = true;
                regex = "^zrepl_P2_.*";
              }
            ];
          };
        }
      ];
    };
  };
}
