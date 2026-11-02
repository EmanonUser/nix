{username, ...}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostId = "6a9f8f43";

  imports = [
    ../localization.nix
    ./../../users/${username}/${username}.nix
    ./../../configs/fern/nixos.nix
  ];

  programs.ssh.startAgent = true;
}
