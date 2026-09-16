{
  stylix,
  username,
  ...
}: {
  imports = [
    ../../modules/nixos/core
    ../../modules/nixos/core/impermanence.nix
    ../../modules/nixos/boot/plymouth.nix
    ../../modules/nixos/boot/secureboot.nix
    ../../modules/nixos/boot/memtest86.nix
    ../../hosts/sasurai/disko.nix
    ../../modules/nixos/services/services.nix
    ../../modules/nixos/ssh-server
    ../../modules/nixos/hardware
    ../../modules/nixos/virtualisation
    ../../modules/nixos/kde
    #../../modules/nixos/greetd/greetd.nix
    ../../modules/nixos/steam/steam.nix
    stylix.nixosModules.stylix
    ../../modules/nixos/stylix
    ./nix-packages
  ];

  # Log straight into the desktop as emanon (KDE/SDDM).
  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  # sasurai signs its host key with the emanon user CA (files provisioned out-of-band).
  services.openssh.extraConfig = ''
    TrustedUserCAKeys /etc/ssh/emanon_user_ca.pub
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
  '';

  # Impermanence: keep the Secure Boot PKI (keys live under /var/lib on tmpfs).
  environment.persistence."/persist".directories = [
    "/var/lib/sbctl"
  ];

  # Allow unlocking the LUKS root via a FIDO2 hardware token at boot;
  # falls back to the passphrase when the token isn't present.
  boot.initrd.luks.devices."crypt".crypttabExtraOpts = [
    "fido2-device=auto"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username stylix;
      hostname = "sasurai";
    };
    users.${username} = import ./home.nix;
  };
}
