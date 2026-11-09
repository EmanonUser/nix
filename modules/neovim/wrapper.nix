{systemPkgs}: {
  config,
  wlib,
  ...
}: {
  config.pkgs = systemPkgs;
  imports = [wlib.wrapperModules.neovim];

  config.settings.config_directory = ./config;
  config.runtimePkgs = with systemPkgs; [
    ansible-language-server
    dockerfile-language-server
    lua-language-server
    opencode
    ruff
    rust-analyzer
    systemd-lsp
    taplo
    tofu-ls
    vscode-langservers-extracted
    yaml-language-server
  ];

  config.specs.general = with systemPkgs.vimPlugins; [
    # UI / navigation
    nvim-web-devicons
    plenary-nvim
    telescope-nvim
    oil-nvim
    trouble-nvim
    lualine-nvim
    which-key-nvim

    # editing / completion
    blink-cmp
    luasnip
    vim-fugitive
    gitsigns-nvim

    # colorschemes
    cyberdream-nvim
    kanagawa-nvim
    everforest

    presence-nvim
    tardis-nvim
    codecompanion-nvim

    (nvim-treesitter.withPlugins (p: [
      p.c
      p.lua
      p.vim
      p.vimdoc
      p.rust
      p.query
      p.html
      p.markdown
      p.markdown_inline
      p.yaml
    ]))

    nvzone-typr
  ];
}
