return {
  "williamboman/mason.nvim",
  priority = 0,
  config = function()
    require("mason").setup()
  end,
}
