{
  config,
  pkgs,
  ...
}: {
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
    };
  };
}
