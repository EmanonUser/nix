{
  nixvim,
  stylix,
  ...
}: {
  imports = [
    nixvim.homeManagerModules.nixvim
    stylix.homeManagerModules.stylix
    ../nixos/stylix/default.nix
    ./home-packages
    ../home/alacritty/alacritty.nix
    ../home/atuin/atuin.nix
    ../home/direnv/direnv.nix
    ../home/git/git.nix
    ../home/hyprland
    ../home/neovim/neovim.nix
    ../home/rnnoise/rnnoise.nix
    ../home/settings/home-manager-settings.nix
    ../home/ssh/ssh.nix
    ../home/starship/starship.nix
    ../home/zellij/zellij.nix
    ../home/zoxide/zoxide.nix
    ../home/zsh/zsh.nix
  ];
}
