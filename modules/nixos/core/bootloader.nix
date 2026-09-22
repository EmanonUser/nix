{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Silence kernel/initrd console output so plymouth owns the screen. No
  # console= params here: tty0 splits console paths and breaks the splash.
  # loglevel=3 (errors only) + quiet stop warning spam; show_status=false
  # hides systemd's status bullets in both the initrd and the real root.
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.systemd.show_status=false"
    "systemd.show_status=false"
  ];

  # The initrd needs the input/USB modules to answer the LUKS prompt (and any
  # emergency shell) before the root filesystem is mounted. Bare-metal
  # hardware-configuration.nix lists them, but VMs (virt-manager/QEMU) rely
  # on this explicit set (PS/2, USB HID and virtio keyboard).
  boot.initrd.availableKernelModules = [
    "atkbd"
    "i8042"
    "usbhid"
    "hid"
    "hid_generic"
    "virtio_input"
  ];
}
