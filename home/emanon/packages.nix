{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    zsh
    alacritty
    starship
    atuin
    google-chrome
    discord
    bitwarden
    vlc
    mpv
    rustdesk
    steam

    # developpement
    ansible
    ansible-lint
    rustup
    alejandra
    cargo-watch
    cargo-expand
    strace
    ltrace
    docker
  ];
}
