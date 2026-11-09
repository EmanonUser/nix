{
  config,
  lib,
  pkgs,
  ...
}: let
  entry = pkgs.writeText "memtest86.conf" ''
    title    Memtest86+
    efi      /efi/memtest86/memtest.efi
    sort-key o_memtest86
  '';
  lanzaboote = config.boot ? lanzaboote && config.boot.lanzaboote.enable;
in {
  boot.loader.systemd-boot.memtest86.enable = true;

  systemd.services.memtest86-esp = lib.mkIf lanzaboote {
    description = "Install Memtest86+ to the EFI System Partition";
    wantedBy = ["multi-user.target"];
    after = ["local-fs.target"];
    path = [pkgs.sbctl];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      install -D -m 0644 ${pkgs.memtest86plus.efi} /boot/efi/memtest86/memtest.efi
      install -D -m 0644 ${entry} /boot/loader/entries/memtest86.conf
      sbctl sign -s /boot/efi/memtest86/memtest.efi || true
    '';
  };
}
