{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-69f07c4f-4348-468f-8dd2-caff60fd31fe" = {
    device = "/dev/disk/by-uuid/69f07c4f-4348-468f-8dd2-caff60fd31fe";
    allowDiscards = true;
    bypassWorkqueues = true;
  };
}
