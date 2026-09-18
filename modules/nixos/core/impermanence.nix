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

  # /nix and /persist are declared by disko; make sure they're mounted
  # in the initrd so impermanence bind mounts work early.
  fileSystems."/nix".neededForBoot = lib.mkForce true;
  fileSystems."/persist".neededForBoot = lib.mkForce true;

  boot.initrd.systemd.enable = true;

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      {
        directory = "/home/${username}";
        user = username;
        group = "users";
        mode = "0755";
      }
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/var/lib/bluetooth"
      "/var/lib/fwupd"
      "/var/lib/incus"
      "/var/lib/logrotate"
      "/var/lib/nixos"
      "/var/lib/NetworkManager"
      "/var/lib/systemd/coredump"
      "/var/log"
    ];

    files = [
      "/etc/machine-id"
    ];
  };
}
