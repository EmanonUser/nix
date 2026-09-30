# System-wide toolchains for the dev environment. Deliberately not in
# configs/nixos-vm/home-packages: these must be on PATH for root and for
# `nixos-rebuild`/`nix` invocations that do not go through the user profile,
# which is exactly the case when a build fails halfway through a rebuild.
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

    # inspection, handy when a build fails inside someone else's flake
    file
    patch
    jq
    ripgrep
    fd
    tree
    ncdu
  ];

  # nix-ld lets foreign/32-bit dynamically linked binaries run, so a musl or
  # 32-bit build can be executed here instead of only cross-built.
  boot.extraModulePackages = [pkgs.nix-ld];
}
