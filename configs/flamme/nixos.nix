{
  lib,
  pkgs,
  username,
  atuinPkg,
  ...
}: {
  imports = [
    ../../modules/nixos/core/settings.nix
    ../../modules/nixos/core/fonts.nix
    ../../modules/nixos/core/agenix.nix
    ../../modules/nixos/boot/bootloader.nix
    ../../modules/nixos/core/impermanence.nix
    ../../hosts/flamme/disko.nix
    ../../modules/nixos/ssh-server/ssh-server.nix
    ../../modules/nixos/hardware/network.nix
    ./nix-packages/nix-packages.nix
    ./samba.nix
  ];

  users.users.${username}.shell = lib.mkForce pkgs.nushell;

  age.secrets.gh-token = lib.mkIf (builtins.pathExists (../../users + "/${username}/gh-token.age")) {
    file = ../../users + "/${username}/gh-token.age";
    owner = username;
    mode = "0400";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username atuinPkg;
      hostname = "flamme";
    };
    users.${username} = import ./home.nix;
  };

  systemd.services."home-manager-${username}".serviceConfig.ExecStartPre = ["${pkgs.coreutils}/bin/mkdir -p /home/${username}/.local/state/nix/profiles"];
}
