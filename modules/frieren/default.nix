{nixvim, ...}: {
  imports = [
    nixvim.homeManagerModules.nixvim
    ../home/alacritty/alacritty.nix
    ../home/atuin/atuin.nix
    ../home/git/git.nix
    ../home/neovim/neovim.nix
    ../home/packages/home-packages.nix
    ../home/settings/home-manager-settings.nix
    ../home/ssh/ssh.nix
    ../home/starship/starship.nix
    ../home/zellij/zellij.nix
    ../home/zoxide/zoxide.nix
    ../home/zsh/zsh.nix
  ];
}
