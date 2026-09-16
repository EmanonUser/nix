{pkgs, ...}: {
  home.packages = with pkgs; [
    kitty
    google-chrome
    firefox
    discord
    bitwarden-desktop
    vlc
    mpv
    ffmpeg
    element-desktop
    hyfetch
    zola

    # developpement
    ansible
    ansible-lint
    sshpass # ansible requirement
    rustup
    lld
    alejandra
    cargo-watch
    cargo-expand
    cargo-tarpaulin
    sqlx-cli
    strace
    ltrace
    docker
    postgresql
    oha
  ];
}
