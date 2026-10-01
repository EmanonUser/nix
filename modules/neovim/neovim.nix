{pkgs, ...}: {
  home.packages = with pkgs; [
    neovim

    # runtime deps used by plugins (kept system-wide)
    git
    ripgrep
    fd
    jq
    gnumake
    clang
    tree-sitter
  ];
}
