{pkgs, ...}: {
  home.packages = with pkgs; [
    # GUI applications (terminals/shell tools live in modules/*)
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

    # games and tool
    steam
    mangohud
    gamemode
    gamescope
    goverlay

    # developpement
    opencode
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
