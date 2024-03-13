{nixvim, ...}: {
  imports = [
    nixvim.nixosModules.nixvim
    ./core
    ./packages
    ./hardware
    ./virtualisation
    ./hyprland/hyprland.nix
    ./neovim/neovim.nix
    ./rnnoise/rnnoise.nix
    ./git/git.nix
    ./zsh/zsh.nix
    ./zoxide/zoxide.nix
    ./atuin/atuin.nix
    ./alacritty/alacritty.nix
    ./zellij/zellij.nix
    ./starship/starship.nix
    ./services/services.nix
    ./steam/steam.nix
  ];
}
