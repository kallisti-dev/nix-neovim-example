-- Indentation detection and guides, color previews, spelling, and motion hints.
return {
  -- Sleuth detects indentation as files are read and never revisits a buffer
  -- that was already open, so it loads before the first read.
  { "vim-sleuth", event = { "BufReadPre", "BufNewFile" } },
  {
    "precognition.nvim",
    event = "DeferredUIEnter",
    after = function() require("precognition").setup {} end,
  },
  {
    "nvim-colorizer.lua",
    event = "BufReadPost",
    after = function() require("colorizer").setup() end,
  },
  {
    "indent-blankline.nvim",
    event = "BufReadPost",
    keys = { { "<leader>ig", "<cmd>IBLToggle<cr>", desc = "Toggle indent guides" } },
    after = function()
      require("ibl").setup {
        indent = { char = "▏", highlight = { "LineNr" } },
        scope = { enabled = false },
      }
    end,
  },
  {
    "programming-spell",
    event = "DeferredUIEnter",
    after = function() vim.opt.spelllang:append("programming") end,
  },
}
