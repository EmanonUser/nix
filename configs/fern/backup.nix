{
  config,
  lib,
  pkgs,
  backupdPkg,
  ...
}: {
  imports = [../../modules/nixos/backupd/backupd.nix];

  age.secrets = lib.mkIf config.services.backupd.enable {
    "backupd-restic-repo" = {
      file = ./backup/restic-repo.age;
      owner = "root";
      mode = "0400";
    };
    "backupd-restic-password" = {
      file = ./backup/restic-password.age;
      owner = "root";
      mode = "0400";
    };
    "backupd-aws-access-key-id" = {
      file = ./backup/aws-access-key-id.age;
      owner = "root";
      mode = "0400";
    };
    "backupd-aws-secret-access-key" = {
      file = ./backup/aws-secret-access-key.age;
      owner = "root";
      mode = "0400";
    };
  };

  services.backupd = {
    enable = false;
    package = backupdPkg;
    configFile = ./backupd.kdl;
    environment = {
      RESTIC_PASSWORD_FILE = "/run/agenix/backupd-restic-password";
      INCUS_STORAGE_POOL = "default";
    };
    secretFiles = {
      RESTIC_REPOSITORY = "/run/agenix/backupd-restic-repo";
      AWS_ACCESS_KEY_ID = "/run/agenix/backupd-aws-access-key-id";
      AWS_SECRET_ACCESS_KEY = "/run/agenix/backupd-aws-secret-access-key";
    };
    extraPackages = [pkgs.restic pkgs.incus-lts];
  };
}
