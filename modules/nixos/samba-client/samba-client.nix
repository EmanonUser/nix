{
  config,
  username,
  ...
}: let
  # SMB share exported by the fern NAS, mounted on demand under the user's home.
  server = "fern.home.arpa";
  share = "fern";
  mountPoint = "/home/${username}/fern";
in {
  boot.supportedFilesystems = ["cifs"];

  age.secrets.fern-samba = {
    file = ../../../users + "/${username}/fern-samba.age";
    owner = "root";
    mode = "0400";
  };

  fileSystems.${mountPoint} = {
    device = "//${server}/${share}";
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
