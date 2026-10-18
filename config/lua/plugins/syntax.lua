-- Treesitter highlighting and indentation, and syntax-aware text objects.
return {
  -- The parsers and queries package.nix builds.
  { "treesitter-grammars", lazy = true },
  {
    "nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    before = function() require("lz.n").trigger_load("treesitter-grammars") end,
    after = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(event)
          -- Help, plugin buffers, and unsupported languages may have no parser.
          if pcall(vim.treesitter.start, event.buf) then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    -- The plugin has no mappings of its own.
    after = function()
      require("nvim-treesitter-textobjects").setup { select = { lookahead = true } }
      local select = require("nvim-treesitter-textobjects.select")
      for keys, object in pairs {
        af = { "@function.outer", "around function" },
        ["if"] = { "@function.inner", "inside function" },
        ac = { "@class.outer", "around class" },
        ic = { "@class.inner", "inside class" },
        aa = { "@parameter.outer", "around argument" },
        ia = { "@parameter.inner", "inside argument" },
      } do
        vim.keymap.set(
          { "x", "o" },
          keys,
          function() select.select_textobject(object[1], "textobjects") end,
          { desc = "Select " .. object[2] }
        )
      end
      -- ]f and [f only replace an obsolete alias of gf. ]c and [c keep their
      -- meaning in diff windows: next and previous change.
      for keys, motion in pairs {
        ["]f"] = { "goto_next_start", "@function.outer", "Next function" },
        ["[f"] = { "goto_previous_start", "@function.outer", "Previous function" },
        ["]c"] = { "goto_next_start", "@class.outer", "Next class, or change in diff mode", diff = true },
        ["[c"] = { "goto_previous_start", "@class.outer", "Previous class, or change in diff mode", diff = true },
      } do
        local move = string.format(
          "<Cmd>lua require('nvim-treesitter-textobjects.move').%s('%s', 'textobjects')<CR>",
          motion[1],
          motion[2]
        )
        vim.keymap.set(
          { "n", "x", "o" },
          keys,
          function() return motion.diff and vim.wo.diff and keys or move end,
          { expr = true, desc = motion[3] }
        )
      end
    end,
  },
}
