{nixvim, ...}: {
  imports = [
    nixvim.nixosModules.nixvim
    ./core
    ./hardware
    ./hyprland
    ./packages
    ./virtualisation

    ./alacritty/alacritty.nix
    ./atuin/atuin.nix
    ./git/git.nix
    ./neovim/neovim.nix
    ./rnnoise/rnnoise.nix
    ./services/services.nix
    ./ssh/ssh.nix
    ./starship/starship.nix
    ./steam/steam.nix
    ./zellij/zellij.nix
    ./zoxide/zoxide.nix
    ./zsh/zsh.nix
  ];
}
