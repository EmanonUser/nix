{vm ? false, ...}: {
  services.smartd.enable = !vm;
  services.glances.enable = true;
  services.vnstat.enable = true;
  powerManagement.powertop.enable = true;
}
