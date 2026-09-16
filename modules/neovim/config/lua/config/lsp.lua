-- 1. Get all config files from your lua/lsp/ directory
local files = vim.api.nvim_get_runtime_file('lua/lsp/*.lua', true)
local servers_to_enable = {}

for _, f in ipairs(files) do
  local server_name = vim.fn.fnamemodify(f, ':t:r')

  -- 2. Load the table from the file
  -- 'require' returns the table you defined in lua_ls.lua
  local config_table = require('lsp.' .. server_name)

  -- 3. Register it with the native Neovim 0.11 registry
  -- This tells Neovim: "If I enable 'lua_ls', use this config."
  vim.lsp.config(server_name, config_table)

  -- 4. Track the name to enable it bulk
  table.insert(servers_to_enable, server_name)
end

-- 5. Enable everything at once
vim.lsp.enable(servers_to_enable)

return {}
