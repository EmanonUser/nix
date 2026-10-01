-- Completion: blink.cmp with LuaSnip as the snippet engine.
local luasnip = require("luasnip")
luasnip.config.set_config({
  region_check_events = "InsertEnter",
  delete_check_events = "InsertLeave",
})
luasnip.setup({})

---@module 'blink.cmp'
---@type blink.cmp.Config
require("blink.cmp").setup({
  -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- 'enter' for enter to accept
  -- 'none' for no mappings
  keymap = { preset = "super-tab" },
  snippets = { preset = "luasnip" },
  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    nerd_font_variant = "mono",
  },
  -- (Default) Only show the documentation popup when manually triggered
  completion = { documentation = { auto_show = false } },
  sources = {
    default = { "snippets", "lsp", "path", "buffer" },
  },
  -- Rust fuzzy matcher for typo resistance and better performance.
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
