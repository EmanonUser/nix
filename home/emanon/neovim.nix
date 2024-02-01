{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.nixvim = {
    enable = true;
    colorschemes.tokyonight.enable = true;
    colorschemes.tokyonight.style = "night";
    globals.mapleader = " ";

    options = {
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
        action = "<cmd>Telescope find_files<CR>";
        mode = "n";
      }
      {
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        mode = "n";
      }
      {
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        mode = "n";
      }
      {
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        mode = "n";
      }
      {
        key = "<leader>fi";
        action = "<cmd>Telescope git_files<CR>";
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

        nil_ls = {
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

    plugins.nvim-cmp = {
      enable = true;
      autoEnableSources = true;
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
      snippet.expand = "luasnip";
    };

    plugins.oil = {
      enable = true;
      extraOptions = {
        columns = {
          icon = true;
          type = true;
          permissions = true;
          size = true;
        };
      };
    };

    plugins = {
      telescope.enable = true;
      treesitter.enable = true;
      luasnip.enable = true;
      fugitive.enable = true;
      presence-nvim.enable = true;
      which-key.enable = true;
      lspkind.enable = true;
      gitsigns.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      nvim-web-devicons
    ];
  };
}
