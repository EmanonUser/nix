{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.backupd;

  # The KDL config holds no secrets; the repository URL, restic password and
  # S3 keys arrive through the environment, read from files (e.g. agenix) so
  # nothing secret ends up in the unit or argv.
  runner = pkgs.writeShellApplication {
    name = "backupd-run";
    runtimeInputs = [pkgs.coreutils cfg.package] ++ cfg.extraPackages;
    text = ''
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "export ${name}=${lib.escapeShellArg value}") cfg.environment)}
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: file: "export ${name}=$(cat ${lib.escapeShellArg file})") cfg.secretFiles)}
      exec backupd --config /etc/backupd.kdl "$@"
    '';
  };
in {
  options.services.backupd = {
    enable = lib.mkEnableOption "backupd";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The backupd package to run.";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = "backupd KDL config, installed to /etc/backupd.kdl.";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 04:00:00";
      description = "systemd OnCalendar expression for the backup timer.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Literal environment variables for the backupd process.";
    };

    secretFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables whose value is the contents of the given file.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra runtime packages on PATH (e.g. restic, incus).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."backupd.kdl".source = cfg.configFile;

    systemd.timers.backupd = {
      description = "backupd";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "10min";
      };
    };

    systemd.services.backupd = {
      description = "backupd: back up Incus volumes, VMs, directories and postgres to restic";
      after = ["incus.service" "network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Nice = 10;
        IOSchedulingClass = "idle";
        ExecStart = "${runner}/bin/backupd-run";
      };
    };
  };
}
