{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ./config;
    recursive = true;
  };

  home.packages = with pkgs; [
    neovim

    # language servers required by the LSP config
    ansible-language-server
    dockerfile-language-server
    lua-language-server
    ruff
    systemd-lsp
    taplo
    tofu-ls
    tree-sitter
    vscode-langservers-extracted
    yaml-language-server

    # runtime deps used by plugins
    git
    ripgrep
    fd
    jq
    gnumake
    clang
  ];
}
