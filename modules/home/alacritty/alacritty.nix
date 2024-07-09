{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    alacritty
  ];

  programs.alacritty = {
    enable = true;

    settings = {
      window.opacity = lib.mkForce 1.0;
    };
  };
}
