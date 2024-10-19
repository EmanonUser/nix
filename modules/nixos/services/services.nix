{pkgs, ...}: {
  services = {
    fstrim.enable = true;
    printing.enable = true;
    fwupd.enable = true;
  };
  services.udev.packages = with pkgs; [
    via
  ];
}
