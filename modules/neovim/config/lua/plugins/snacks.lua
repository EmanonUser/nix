return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    markdown = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    {
      "<leader>mp",
      function() Snacks.markdown.preview() end,
      desc = "[M]arkdown [P]review",
      mode = { "n", "x" },
    },
    {
      "<leader>mt",
      function() Snacks.markdown.toc() end,
      desc = "Markdown [T]able of contents",
      mode = { "n" },
    },
  },
}
