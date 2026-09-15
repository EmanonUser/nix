{
  stylix,
  username,
  ...
}: {
  imports = [
    ../nixos/core
    ../nixos/core/impermanence.nix
    ../nixos/disko/sasurai.nix
    ../nixos/services/services.nix
    ../nixos/ssh-server
    ../nixos/hardware
    ../nixos/virtualisation
    ../nixos/kde
    #../nixos/greetd/greetd.nix
    ../nixos/steam/steam.nix
    stylix.nixosModules.stylix
    ../nixos/stylix
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