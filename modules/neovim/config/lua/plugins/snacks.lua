---@type snacks.Config
require("snacks").setup({
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
})

vim.keymap.set({ "n", "x" }, "<leader>mp", function() Snacks.markdown.preview() end,
  { desc = "[M]arkdown [P]review" })
vim.keymap.set("n", "<leader>mt", function() Snacks.markdown.toc() end,
  { desc = "Markdown [T]able of contents" })
