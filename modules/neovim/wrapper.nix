# Neovim built through nix-wrapper-modules.
#
# Replaces the old lazy.nvim setup: nixpkgs owns the plugin packages, so
# versions are pinned by flake.lock and telescope/plenary/nvim-treesitter can
# never skew out of compatibility. Everything loads at startup (no lazy
# loading, no packadd, no lazy-lock.json, no runtime git).
#
# `attrs` is the flake's input set (see flake.nix importApply) and `systemPkgs`
# is the target pkgs; both are bound by the caller.
{
  attrs,
  systemPkgs,
}: {
  config,
  wlib,
  lib,
  ...
}: {
  config.pkgs = systemPkgs;
  imports = [wlib.wrapperModules.neovim];

  # Plugins not in nixpkgs, auto-built from `plugins-*` flake inputs
  # (currently plugins-typr and plugins-volt).
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" attrs;
  };

  # Helper from the upstream template: turn every `plugins-<name>` input into
  # `config.nvim-lib.neovimPlugins.<name>` via the wrapper's mkPlugin.
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default = prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input: let
            name = lib.removePrefix prefix input;
          in {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };

  config.settings.config_directory = ./config;
  config.runtimePkgs = with systemPkgs; [
    ansible-language-server
    dockerfile-language-server
    lua-language-server
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
    opencode-nvim

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
    ]))

    # not in nixpkgs;
    config.nvim-lib.neovimPlugins.volt
    config.nvim-lib.neovimPlugins.typr
  ];
}
