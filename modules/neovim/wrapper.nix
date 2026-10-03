# Neovim built through nix-wrapper-modules.
#
# Replaces the old lazy.nvim setup: nixpkgs owns the plugin packages, so
# versions are pinned by flake.lock and telescope/plenary/nvim-treesitter can
# never skew out of compatibility. Everything loads at startup (no lazy
# loading, no packadd, no lazy-lock.json, no runtime git).
#
# `attrs` is the flake's input set (see flake.nix importApply) and `systemPkgs`
# is the target pkgs; both are bound by the caller.
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
