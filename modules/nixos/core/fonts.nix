{lib, pkgs, ...}: let
  obelMono = pkgs.callPackage ../../../packages/obel-mono.nix {};
  obelMonoMasked = pkgs.callPackage ../../../packages/obel-mono.nix {masked = true;};
in {
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    obelMono
    obelMonoMasked
  ];

  # OS-wide default. Ghostty overrides the family in its own config and turns
  # on the masking feature (ss01) there.
  fonts.fontconfig.defaultFonts = {
    monospace = ["Obel Mono"];
    sansSerif = ["Obel Mono"];
  };
}
