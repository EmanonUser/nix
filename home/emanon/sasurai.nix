{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.username = "emanon";
  home.homeDirectory = "/home/emanon";

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./packages.nix
    ./neovim.nix
    ./cli/git.nix
    ./cli/zsh.nix
    ./features/hyprland.nix
  ];

  programs.starship = {
    enable = true;
  };

  programs.alacritty = {
    enable = true;
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };
}
