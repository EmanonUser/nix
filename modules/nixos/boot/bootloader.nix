{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.systemd.show_status=false"
    "systemd.show_status=false"
  ];

  boot.initrd.availableKernelModules = [
    "atkbd"
    "i8042"
    "usbhid"
    "hid"
    "hid_generic"
    "virtio_input"
  ];
}
