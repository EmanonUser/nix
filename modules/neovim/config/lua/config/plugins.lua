-- Plugin setup, loaded once at startup. The plugins themselves are installed
-- by Nix (modules/neovim/wrapper.nix) and already on the runtimepath, so each
-- module just calls the plugin's setup()/keymaps directly. There is no lazy
-- loading and no plugin manager.
require("plugins.scheme")
require("plugins.cmp")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.lualine")
require("plugins.which-key")
require("plugins.oil")
require("plugins.trouble")
require("plugins.fugitive")
require("plugins.presence")
require("plugins.tardis")
require("plugins.opencode")
require("plugins.typr")
