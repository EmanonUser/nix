{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    alacritty
    starship
    htop
  ];
}
