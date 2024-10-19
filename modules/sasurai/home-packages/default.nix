{pkgs, ...}: {
  home.packages = with pkgs; [
    zsh
    alacritty
    kitty
    starship
    atuin
    google-chrome
    firefox
    discord
    bitwarden
    vlc
    mpv
    ffmpeg
    element-desktop
    wofi
    slurp
    jellyfin-media-player
    wf-recorder
    grimblast
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
