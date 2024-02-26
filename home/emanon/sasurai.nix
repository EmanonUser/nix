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
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./packages.nix
    ./cli/git.nix
    ./cli/zsh.nix
    ./cli/atuin.nix
    ./cli/zoxide.nix
    ./features/hyprland.nix
    ./features/neovim.nix
    ./features/rnnoise.nix
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
