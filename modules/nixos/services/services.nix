{pkgs, ...}: {
  services = {
    fstrim.enable = true;
    printing.enable = true;
    fwupd.enable = true;
  };
}
