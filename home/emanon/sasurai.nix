{
  config,
  pkgs,
  inputs,
  ...
}: {
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
