{nixvim, ...}: {
  imports = [
    nixvim.nixosModules.nixvim
    ./core
    ./hardware/audio/pipewire.nix
    ./neovim/neovim.nix
    ./rnnoise/rnnoise.nix
    ./git/git.nix
    ./zsh/zsh.nix
    ./zoxide/zoxide.nix
    ./atuin/atuin.nix
  ];
}
