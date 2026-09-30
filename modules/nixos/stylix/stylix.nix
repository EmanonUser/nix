{
  pkgs,
  username,
  stylix,
  vm ? false,
  ...
}: {
  imports = [
    stylix.nixosModules.stylix
  ];

  # Serves the desktop twins only: sasurai-vm / zoltraak-vm run the real DE
  # config and so need a theme, but the bare-metal wallpaper lives on the host's
  # persistent storage and is absent from a throwaway VM - hence a bundled one.
  # The headless VMs (nixos-vm, nixos-tests) never import this module at all.
  #
  # This branch has to live here rather than in hosts/vm/common.nix: stylix is
  # only an option on hosts that import it, and common.nix is imported by the
  # headless VMs that do not.
  stylix.image =
    if vm
    then pkgs.nixos-artwork.wallpapers.nineish-dark-gray
    else /home/${username}/Pictures/wallpaper.jpg;

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";

  stylix.fonts = {
    monospace = {
      package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
      name = "JetBrainsMono Nerd Font Mono";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
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
