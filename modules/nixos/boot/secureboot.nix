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
  };

  environment.systemPackages = [
    # Key generation/enrollment for Secure Boot.
    pkgs.sbctl
  ];
}
