{pkgs, ...}: {
  home.packages = with pkgs; [
    # GUI applications (terminals/shell tools live in modules/home/*)
    kitty
    google-chrome
    firefox
    discord
    bitwarden-desktop
    vlc
    mpv
    ffmpeg
    element-desktop
    jellyfin-media-player
    hyfetch
    zola

    # games and tool
    steam
    mangohud
    gamemode
    gamescope
    goverlay
    ferium
    fabric-installer
    zulu17

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
