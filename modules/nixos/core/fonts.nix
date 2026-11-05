{lib, pkgs, ...}: let
  obelMono = pkgs.callPackage ../../../packages/obel-mono.nix {};
  obelMonoMasked = pkgs.callPackage ../../../packages/obel-mono.nix {masked = true;};
in {
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    obelMono
    obelMonoMasked
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = ["Obel Mono"];
    sansSerif = ["Obel Mono"];
  };
}
