{lib, ...}: let
  keyFiles = builtins.readDir ../zfs-keys;
  keys = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".age" name) keyFiles;
in {
  age.secrets = lib.mapAttrs' (file: _: let
    key = lib.removeSuffix ".age" file;
  in
    lib.nameValuePair "zfs-key-${key}" {
      file = ../zfs-keys + "/${file}";
      path = "/root/zfs_datasets_keys/${key}";
      owner = "root";
      group = "root";
      mode = "0400";
    })
  keys;

  systemd.services."fern-zfs-load-keys".after = lib.mkAfter ["agenix-install-secrets.service"];
}
