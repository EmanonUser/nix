{
  pkgs,
  lib,
  ...
}: {
  # lanzaboote replaces the systemd-boot module (installs systemd-boot
  # externally and signs everything with the Secure Boot db key).
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";

    # A fresh install has no signing keys yet. Set allowUnsigned implicitly so
    # nixos-anywhere can install the (still unsigned) bootloader, then generate
    # the keys on first boot and enroll them via systemd-boot. Microsoft keys
    # are included so Windows 11 keeps booting. Requires the firmware to be in
    # Setup Mode (Secure Boot keys cleared) before the enrollment boot.
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
  };

  environment.systemPackages = [
    # Key generation/enrollment for Secure Boot.
    pkgs.sbctl
  ];
}
