{
  stylix,
  username,
  ...
}: {
  imports = [
    ../../modules/nixos/core
    ../../modules/nixos/core/impermanence.nix
    ../../modules/nixos/boot/memtest86.nix
    ../../hosts/zoltraak/disko.nix
    ../../modules/nixos/services/services.nix
    ../../modules/nixos/ssh-server
    ../../modules/nixos/hardware
    ../../modules/nixos/virtualisation
    ../../modules/nixos/cosmic
    stylix.nixosModules.stylix
    ../../modules/nixos/stylix
    ./nix-packages
  ];

  # zoltraak signs its host key with the emanon user CA (files provisioned out-of-band).
  services.openssh.extraConfig = ''
    TrustedUserCAKeys /etc/ssh/emanon_user_ca.pub
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
  '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username stylix;
      hostname = "zoltraak";
    };
    users.${username} = import ./home.nix;
  };
}
