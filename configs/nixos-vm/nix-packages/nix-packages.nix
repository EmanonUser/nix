{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # nix tooling
    nix-index
    nix-tree
    nix-diff
    nix-du
    nixfmt
    alejandra
    statix
    deadnix
    nil
    nixpkgs-review

    # native toolchain
    gnumake
    gcc
    clang
    clang-tools
    lld
    binutils
    cmake
    ninja
    meson
    pkg-config
    ccache
    gdb
    valgrind
    strace
    ltrace
    patchelf

    # headers a nix build tends to reach for
    zlib
    openssl
    libffi
    readline
    ncurses
    pcre2

    # language runtimes
    go
    rustup
    python3
    python3Packages.pip
    python3Packages.setuptools
    nodejs

    # shell / script tooling
    bash
    bash-completion
    shellcheck
    shfmt
    file
    patch
    jq
    ripgrep
    fd
    tree
    ncdu
    opencode
  ];

  boot.extraModulePackages = [pkgs.nix-ld];
}
