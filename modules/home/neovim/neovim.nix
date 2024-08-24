{
  pkgs,
  home-manager,
  username,
  ...
}: let
  precognition = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "precognition";
      src = pkgs.fetchFromGitHub {
        owner = "tris203";
        repo = "precognition.nvim";
        rev = "5255b72c52b1159e9757f50389bde65e05e3bfb1";
        hash = "sha256-AqWYV/59ugKyOWALOCdycWVm0bZ7qb981xnuw/mAVzM=";
      };
    })
  ];
in {
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.nixvim = {
    enable = true;
    colorschemes.cyberdream.enable = true;
    colorschemes.tokyonight = {
      enable = false;
      settings.style = false;
    };

    colorschemes.kanagawa = {
      enable = false;
      settings.background.dark = "dragon";
    };

    clipboard.providers.wl-copy.enable = true;
    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      smarttab = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      softtabstop = 2;
    };

    autoCmd = [
      {
        event = ["BufWritePre"];
        pattern = ["*"];
        callback = {
          __raw = ''
            function()
              local cursor = vim.fn.getpos(".")
              pcall(function() vim.cmd [[%s/\s\+$//e]] end)
              vim.fn.setpos(".", cursor)
            end
          '';
        };
      }

      {
        event = ["BufWritePre"];
        pattern = ["*"];
        callback = {
          __raw = ''
            function()
              vim.lsp.buf.format()
            end
          '';
        };
      }
    ];

    keymaps = [
      {
        key = "<leader>fd";
        action = "<cmd>lua vim.lsp.buf.format()<CR>";
        mode = "n";
      }
      {
        key = "<leader>pv";
        action = "<cmd>Oil<CR>";
        mode = "n";
      }
      {
        key = "<leader>ff";
        action = "<cmd>Telescope find_files initial_mode=normal<CR>";
        mode = "n";
      }
      {
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep initial_mode=normal<CR>";
        mode = "n";
      }
      {
        key = "<leader>fb";
        action = "<cmd>Telescope buffers initial_mode=normal<CR>";
        mode = "n";
      }
      {
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags initial_mode=normal<CR>";
        mode = "n";
      }
      {
        key = "<leader>fi";
        action = "<cmd>Telescope git_files initial_mode=normal<CR>";
        mode = "n";
      }
      {
        key = "<leader>gs";
        action = "<cmd>Git<CR>";
        mode = "n";
      }
    ];

    plugins.lsp = {
      enable = true;
      servers = {
        ansiblels.enable = true;
        lua-ls.enable = true;
        dockerls.enable = true;
        taplo.enable = true;
        jsonls.enable = true;
        html.enable = true;
        yamlls.enable = true;

        nil-ls = {
          enable = true;
          settings.formatting.command = ["alejandra"];
        };

        rust-analyzer = {
          enable = true;
          installRustc = false;
          installCargo = false;
        };
      };

      keymaps.lspBuf = {
        gD = "declaration";
        gd = "definition";
        K = "hover";
        gi = "implementation";
        "<C-k>" = "signature_help";
        "<space>D" = "type_definition";
        "<space>rn" = "rename";
        "<space>ca" = "code_action";
        "<space>gr" = "references";
      };
    };

    plugins.treesitter = {
      enable = true;
      settings.highlight.enable = true;
    };

    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        snippet.expand = ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
          {name = "luasnip";}
        ];
        mapping = {
          "<C-l>" = "cmp.mapping.select_next_item()";
          "<C-m>" = "cmp.mapping.select_prev_item()";
          "<C-space>" = "cmp.mapping.complete()";
          "<C-y>" = "cmp.mapping.confirm({ select = true })";
          "<C-e>" = "cmp.mapping.abort()";
        };
      };
    };

    plugins = {
      alpha.enable = true;
      alpha.theme = "startify";
    };

    plugins.oil = {
      enable = true;
      settings.view_options.show_hidden = true;
      settings.columns = [
        "icon"
        "type"
        "permissions"
        "size"
      ];
    };

    plugins.codesnap = {
      enable = true;
      settings = {
        has_breadcrumbs = true;
        has_line_number = true;
        show_workspace = true;
        mac_window_bar = false;
        watermark = "";
      };
    };

    plugins = {
      telescope.enable = true;
      luasnip.enable = true;
      fugitive.enable = true;
      presence-nvim.enable = true;
      which-key.enable = true;
      lspkind.enable = true;
      gitsigns.enable = true;
      trouble.enable = true;
      schemastore.enable = true;
      glow.enable = true;
    };

    extraPlugins =
      [
        pkgs.vimPlugins.nvim-web-devicons
        pkgs.vimPlugins.nordic-nvim
        pkgs.vimPlugins.monokai-pro-nvim
        pkgs.vimPlugins.rose-pine
      ]
      ++ precognition;

    extraConfigLua = ''
      require('precognition').setup({});
    '';
  };
}
