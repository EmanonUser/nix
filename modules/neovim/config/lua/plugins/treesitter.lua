return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- master is archived and does not support nvim 0.12
  lazy = false, -- this plugin does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    local languages = { "c", "lua", "vim", "vimdoc", "rust", "query", "html", "markdown", "markdown_inline" }

    require("nvim-treesitter").install(languages):wait(300000)

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
  end
}
