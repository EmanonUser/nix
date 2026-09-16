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
    taplo
    vscode-langservers-extracted
    yaml-language-server

    # runtime deps used by plugins
    git
    ripgrep
    fd
    jq
  ];
}
