{pkgs, ...}: {
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
    wofi

    # games and tool
    steam
    mangohud
    goverlay
    ferium
    minecraft
    fabric-installer

    # developpement
    ansible
    ansible-lint
    sshpass # ansible requirement
    rustup
    alejandra
    cargo-watch
    cargo-expand
    sqlx-cli
    strace
    ltrace
    docker
  ];
}
