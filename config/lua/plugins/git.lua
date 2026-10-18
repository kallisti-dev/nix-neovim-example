-- Show changed lines with Gitsigns and use Fugitive for repository commands.
return {
  {
    "gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("gitsigns").setup {
        on_attach = function(buffer)
          local gs = require("gitsigns")
          for _, binding in ipairs {
            { "<leader>ghs", "Stage hunk", gs.stage_hunk },
            { "<leader>ghr", "Reset hunk", gs.reset_hunk },
            { "<leader>ghp", "Preview hunk", gs.preview_hunk },
            { "<leader>gb", "Blame line", gs.blame_line },
            { "<leader>gB", "Blame file", gs.blame },
            -- Not <leader>gd, which finds LSP definitions (navigation.lua).
            { "<leader>gD", "Diff file", gs.diffthis },
          } do
            vim.keymap.set("n", binding[1], binding[3], { buffer = buffer, desc = binding[2] })
          end
          vim.keymap.set(
            "v",
            "<leader>ghs",
            function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
            { buffer = buffer, desc = "Stage selected lines" }
          )
          vim.keymap.set(
            "v",
            "<leader>ghr",
            function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
            { buffer = buffer, desc = "Reset selected lines" }
          )
          vim.keymap.set("n", "<leader>ghu", gs.undo_stage_hunk, { buffer = buffer, desc = "Undo last staged hunk" })
        end,
      }
    end,
  },
  {
    "vim-fugitive",
    -- Fugitive's commands, :GBrowse included. Rhubarb adds the GitHub URLs
    -- :GBrowse opens, so it loads with Fugitive.
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Ghdiffsplit",
      "Gread",
      "Gwrite",
      "Gwq",
      "Gedit",
      "Gsplit",
      "Gvsplit",
      "Gtabedit",
      "Gpedit",
      "Gdrop",
      "Gclog",
      "Gllog",
      "Ggrep",
      "Glgrep",
      "Gcd",
      "Glcd",
      "GMove",
      "GRename",
      "GDelete",
      "GRemove",
      "GUnlink",
      "GBrowse",
    },
    before = function() require("lz.n").trigger_load("vim-rhubarb") end,
  },
  { "vim-rhubarb", lazy = true },
  -- Editors started in a terminal buffer open their files here instead of nesting.
  { "nvim-unception", event = "DeferredUIEnter" },
  {
    "octo.nvim",
    cmd = "Octo",
    before = function() require("lz.n").trigger_load { "plenary.nvim", "telescope.nvim", "nvim-web-devicons" } end,
    after = function() require("octo").setup() end,
  },
}
