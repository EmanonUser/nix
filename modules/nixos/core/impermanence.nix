{
  lib,
  username,
  ...
}: {
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["mode=0755"];
    neededForBoot = true;
  };

  fileSystems."/nix".neededForBoot = lib.mkForce true;
  fileSystems."/persist".neededForBoot = lib.mkForce true;
  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      {
        directory = "/home/${username}";
        user = username;
        group = "users";
        mode = "0755";
      }
      "/etc/ssh"
      "/var/lib/fwupd"
      "/var/lib/incus"
      "/var/lib/logrotate"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/log"
    ];

    files = [
      "/etc/machine-id"
    ];
  };
}
