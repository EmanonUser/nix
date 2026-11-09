{
  pkgs,
  username,
  stylix,
  vm ? false,
  ...
}: let
  obelMono = pkgs.callPackage ../../../packages/obel-mono.nix {};
in {
  imports = [
    stylix.nixosModules.stylix
  ];

  stylix.image =
    if vm
    then pkgs.nixos-artwork.wallpapers.nineish-dark-gray
    else /home/${username}/Pictures/wallpaper.jpg;

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";

  stylix.fonts = {
    monospace = {
      package = obelMono;
      name = "Obel Mono";
    };
    sansSerif = {
      package = obelMono;
      name = "Obel Mono";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };

    sizes = {
      applications = 10;
      terminal = 11;
      desktop = 10;
      popups = 10;
    };
  };
}
