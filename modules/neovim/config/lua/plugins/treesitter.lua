return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    local languages = { "c", "lua", "vim", "vimdoc", "rust", "query", "html" }
    ts.install(languages):wait(300000)

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Enable treesitter highlighting",
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
  end
}
