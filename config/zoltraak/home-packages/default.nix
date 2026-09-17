{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    discord
    bitwarden-desktop
    vlc
    mpv
    ffmpeg
    element-desktop
    fladder
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
    postgresql
    oha
  ];
}
