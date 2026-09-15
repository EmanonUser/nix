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
      "/var/lib/bluetooth"
      "/var/lib/docker"
      "/var/lib/fwupd"
      "/var/lib/libvirt"
      "/var/lib/logrotate"
      "/var/lib/nixos"
      "/var/lib/NetworkManager"
      "/var/lib/systemd/coredump"
      "/var/log"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ecdsa_key"
      "/etc/ssh/ssh_host_ecdsa_key.pub"
    ];
  };
}