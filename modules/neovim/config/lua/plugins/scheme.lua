return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("cyberdream")
    end,
  },


  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      --vim.cmd.colorscheme('kanagawa')
    end
  },

  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_enable_italic = false
      vim.g.everforest_background = "hard"
      --vim.cmd.colorscheme("everforest")
    end
  }
}
