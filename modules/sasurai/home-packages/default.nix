{pkgs, ...}: {
  home.packages = with pkgs; [
    zsh
    alacritty
    starship
    atuin
    google-chrome
    firefox
    discord
    bitwarden
    vlc
    mpv
    ffmpeg
    rustdesk
    element-desktop
    wofi
    slurp
    wf-recorder
    grimblast

    # games and tool
    steam
    mangohud
    gamemode
    gamescope
    goverlay
    ferium
    minecraft
    fabric-installer

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
  ];
}
