{
  stylix,
  username,
  ...
}: {
  imports = [
    ../../modules/nixos/core
    ../../modules/nixos/core/impermanence.nix
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

  # sasurai signs its host key with the emanon user CA (files provisioned out-of-band).
  services.openssh.extraConfig = ''
    TrustedUserCAKeys /etc/ssh/emanon_user_ca.pub
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
  '';

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
