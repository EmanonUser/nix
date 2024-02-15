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
    mangohud
    goverlay
    ferium

    # developpement
    ansible
    ansible-lint
    sshpass # ansible requirement
    rustup
    alejandra
    cargo-watch
    cargo-expand
    strace
    ltrace
    docker
  ];
}
