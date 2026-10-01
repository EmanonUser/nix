-- CodeCompanion driven by opencode's ACP server (`opencode acp`).
require("codecompanion").setup({
  strategies = {
    chat = { adapter = "opencode" },
    inline = { adapter = "opencode" },
  },
})

vim.keymap.set("n", "<leader>oa", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion actions" })
vim.keymap.set("n", "<leader>oc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "CodeCompanion chat" })
vim.keymap.set("n", "<leader>oi", "<cmd>CodeCompanion<cr>", { desc = "CodeCompanion inline" })
vim.keymap.set("v", "<leader>oa", ":CodeCompanionChat Add<cr>", { desc = "Add selection to CodeCompanion" })
