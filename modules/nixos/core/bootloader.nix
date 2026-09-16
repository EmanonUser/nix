{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Route /dev/console input to the VGA/display terminal (keyboard on the
  # graphics console) while keeping serial available for output/remote debug.
  # console= order matters: the LAST entry is the interactive input console.
  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "console=tty0"
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
