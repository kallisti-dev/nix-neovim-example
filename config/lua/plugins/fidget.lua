-- Show LSP progress in a small window, with a bounded notification history.
-- Loaded by nvim-lspconfig (lsp.lua).
return {
  "fidget.nvim",
  lazy = true,
  after = function()
    require("fidget").setup {
      progress = {
        suppress_on_insert = true,
        display = { render_limit = 8, done_ttl = 3, progress_ttl = 60 },
      },
      notification = {
        history_size = 128,
        -- Leave notifications alone in headless checks so Probe can capture them.
        override_vim_notify = #vim.api.nvim_list_uis() > 0,
        window = { max_height = 6 },
      },
      integration = { ["nvim-tree"] = { enable = true } },
    }
  end,
}
