{username, ...}: {
  imports = [
    ../../modules/nixos/core/settings.nix
    ../../modules/nixos/core/fonts.nix
    ../../modules/nixos/core/agenix.nix
    ../../modules/nixos/boot/bootloader.nix
    ../../modules/nixos/core/impermanence.nix
    ../../hosts/vm/disko.nix
    ../../modules/nixos/ssh-server/ssh-server.nix
    ../../modules/nixos/hardware/network.nix
  ];

  # The point of this box is to activate a system config, so keep it lean: no
  # desktop, no audio, no printing, no fwupd. The heavy dev toolchains live on
  # nixos-vm instead.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username;
      hostname = "nixos-tests";
    };
    users.${username} = import ./home.nix;
  };
}
