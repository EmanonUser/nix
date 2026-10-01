local files = vim.api.nvim_get_runtime_file('lua/lsp/*.lua', true)
local servers_to_enable = {}

for _, f in ipairs(files) do
  local server_name = vim.fn.fnamemodify(f, ':t:r')
  local config_table = require('lsp.' .. server_name)
  vim.lsp.config(server_name, config_table)
  table.insert(servers_to_enable, server_name)
end

vim.lsp.enable(servers_to_enable)
return {}
