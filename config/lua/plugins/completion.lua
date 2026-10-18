-- Complete from language servers, open buffers, paths and the command line.
return {
  {
    "nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    after = function()
      -- The sources register with nvim-cmp from their after/plugin scripts, so
      -- they load after it.
      require("lz.n").trigger_load { "cmp-nvim-lsp", "cmp-path", "cmp-buffer", "cmp-cmdline", "cmp-git" }
      local cmp = require("cmp")
      cmp.setup {
        snippet = {
          expand = function(args) vim.snippet.expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<Tab>"] = cmp.mapping.confirm { select = true },
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, { { name = "buffer", option = { get_bufnrs = vim.api.nvim_list_bufs } } }),
      }
      require("cmp_git").setup()
      cmp.setup.filetype({ "gitcommit", "octo" }, {
        sources = cmp.config.sources({ { name = "git" } }, { { name = "buffer" } }),
      })
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },
  -- Loaded by nvim-cmp, and cmp-nvim-lsp by nvim-lspconfig too.
  { "cmp-nvim-lsp", lazy = true },
  { "cmp-path", lazy = true },
  { "cmp-buffer", lazy = true },
  { "cmp-cmdline", lazy = true },
  { "cmp-git", lazy = true },
}
