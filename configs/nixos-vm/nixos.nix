{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../modules/nixos/core/settings.nix
    ../../modules/nixos/core/fonts.nix
    ../../modules/nixos/core/agenix.nix
    ../../modules/nixos/boot/bootloader.nix
    ../../modules/nixos/core/impermanence.nix
    ../../hosts/vm/disko.nix
    ../../modules/nixos/ssh-server/ssh-server.nix
    ../../modules/nixos/services/services.nix
    ../../modules/nixos/hardware/network.nix
    ./nix-packages/nix-packages.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username;
      hostname = "nixos-vm";
    };
    users.${username} = import ./home.nix;
  };

  # With impermanence /home/emanon starts empty: home-manager refuses to run
  # until its profile directory exists, so create it before every activation.
  systemd.services."home-manager-${username}".serviceConfig.ExecStartPre = ["${pkgs.coreutils}/bin/mkdir -p /home/${username}/.local/state/nix/profiles"];
}
