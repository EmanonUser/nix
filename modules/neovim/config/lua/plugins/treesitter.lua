-- Treesitter highlighting/indentation. The grammars are provided by Nix
-- (nvim-treesitter.withPlugins in wrapper.nix), so there is no install step.
local languages = { "c", "lua", "vim", "vimdoc", "rust", "query", "html", "markdown", "markdown_inline" }

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable treesitter highlighting",
  pattern = languages,
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable treesitter-based indentation",
  pattern = languages,
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
