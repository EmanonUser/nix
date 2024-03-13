{nixvim, ...}: {
  imports = [
    nixvim.nixosModules.nixvim
    ./core
    ./packages
    ./hardware
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
  ];
}
