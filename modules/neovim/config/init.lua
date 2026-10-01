-- Plugins live under pack/*/start (installed by Nix) but the wrapper sources
-- this config before Neovim's own packloadall, so load them first.
vim.cmd("packloadall")

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lsp")
require("config.plugins")
