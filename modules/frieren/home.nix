{nixvim, ...}: {
  imports = [
    nixvim.homeManagerModules.nixvim
    ./home-packages
    ../home/atuin/atuin.nix
    ../home/git/git.nix
    ../home/neovim/neovim.nix
    ../home/settings/home-manager-settings.nix
    ../home/ssh/ssh.nix
    ../home/starship/starship.nix
    ../home/direnv/direnv.nix
    ../home/zellij/zellij.nix
    ../home/zoxide/zoxide.nix
    ../home/zsh/zsh.nix
  ];
}
