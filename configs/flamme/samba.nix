{
  config,
  username,
  ...
}: let
  server = "fern.home.arpa";
in {
  boot.supportedFilesystems = ["cifs"];

  age.secrets.fern-samba = {
    file = ../../users + "/${username}/fern-samba.age";
    owner = "root";
    mode = "0400";
  };

  systemd.tmpfiles.rules = [
    "d /fern 0755 root root -"
    "d /fern/emanonlab 0755 root root -"
    "d /fern/emanonlab/dev 0755 ${username} users -"
  ];

  fileSystems."/fern/emanonlab/dev" = {
    device = "//${server}/dev";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.fern-samba.path}"
      "uid=${username}"
      "gid=${config.users.users.${username}.group}"
      "file_mode=0644"
      "dir_mode=0755"
      "iocharset=utf8"
      "_netdev"
      "nofail"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=120"
      "x-systemd.mount-timeout=30"
    ];
  };
}
