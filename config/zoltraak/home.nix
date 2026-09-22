{
  # zoltraak's GPUs only reach OpenGL 3.3, below Ghostty's 4.3 requirement.
  ghostty.softwareRendering = true;

  imports = [
    ./home-packages
    ../../modules/atuin/atuin.nix
    ../../modules/direnv/direnv.nix
    ../../modules/ghostty/ghostty.nix
    ../../modules/git/git.nix
    ../../modules/neovim/neovim.nix
    ../../modules/niri/niri.nix
    ../../modules/settings/home-manager-settings.nix
    ../../modules/ssh/ssh.nix
    ../../modules/starship/starship.nix
    ../../modules/zellij/zellij.nix
    ../../modules/zoxide/zoxide.nix
    ../../modules/zsh/zsh.nix
  ];
}
