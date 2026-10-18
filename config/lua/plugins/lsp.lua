-- Language servers, the LSP mappings Neovim lacks, and Rust macro expansion.
return {
  "nvim-lspconfig",
  -- Opening any file loads it; vim.lsp.enable then starts the servers for
  -- each filetype. BufNewFile covers files that don't exist yet.
  event = { "BufReadPre", "BufNewFile" },
  before = function() require("lz.n").trigger_load { "cmp-nvim-lsp", "fidget.nvim" } end,
  after = function()
    vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
    vim.lsp.config("ruff", {
      on_attach = function(client)
        -- Basedpyright provides type-aware hover for the shared Python buffer.
        client.server_capabilities.hoverProvider = false
      end,
    })
    vim.lsp.config("basedpyright", {
      settings = {
        basedpyright = {
          disableOrganizeImports = true,
          analysis = {
            typeCheckingMode = "standard",
            autoImportCompletions = true,
            inlayHints = { variableTypes = true, callArgumentNames = true, functionReturnTypes = true },
          },
        },
      },
    })
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          telemetry = { enable = false },
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        },
      },
    })
    vim.lsp.config("nixd", {
      settings = { nixd = { formatting = { command = { "nixfmt" } } } },
    })
    vim.lsp.config("yamlls", { settings = { redhat = { telemetry = { enabled = false } } } })
    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          cargo = { features = "all" },
          completion = {
            fullFunctionSignatures = { enable = true },
            privateEditable = { enable = true },
          },
        },
      },
    })
    vim.api.nvim_create_user_command("ExpandMacro", function()
      local client = vim.lsp.get_clients({ bufnr = 0, name = "rust_analyzer" })[1]
      if not client then
        vim.notify("No rust-analyzer attached to this buffer", vim.log.levels.WARN)
        return
      end
      client:request(
        "rust-analyzer/expandMacro",
        vim.lsp.util.make_position_params(0, client.offset_encoding),
        function(err, result)
          if err then
            vim.notify(err.message, vim.log.levels.ERROR)
          elseif result then
            local buffer = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(result.expansion, "\n"))
            vim.bo[buffer].filetype = "rust"
            vim.api.nvim_open_win(buffer, true, { split = "right", win = 0 })
          else
            vim.notify("No macro under the cursor")
          end
        end,
        vim.api.nvim_get_current_buf()
      )
    end, { desc = "Expand Rust macro under cursor" })
    vim.lsp.enable {
      "ruff",
      "basedpyright",
      "lua_ls",
      "nixd",
      "marksman",
      "bashls",
      "taplo",
      "ts_ls",
      "gopls",
      "buf_ls",
      "perlpls",
      "jsonls",
      "jsonnet_ls",
      "yamlls",
      "rust_analyzer",
    }
    -- Neovim maps most LSP actions when a server attaches: K (hover), grr
    -- (references), gri (implementations), grt (type definition), grn
    -- (rename), gra (code action), gO (document symbols), ]d and [d (next and
    -- previous diagnostic), Ctrl-W d (diagnostic float), and Ctrl-S in insert
    -- mode (signature help). These are the ones it leaves out.
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
        -- LspAttach runs once per server. gd and gD use the definition and
        -- declaration of a server that has them, and otherwise keep Vim's own
        -- search for the word under the cursor.
        for _, binding in ipairs {
          { "gd", "textDocument/definition", "Go to definition", vim.lsp.buf.definition },
          { "gD", "textDocument/declaration", "Go to declaration", vim.lsp.buf.declaration },
        } do
          if client:supports_method(binding[2], event.buf) then
            vim.keymap.set("n", binding[1], binding[4], { buffer = event.buf, desc = binding[3] })
          end
        end
        vim.keymap.set("n", "<leader>cf", function()
          vim.lsp.buf.format {
            filter = function(formatter) return formatter.name ~= "basedpyright" end,
          }
        end, { buffer = event.buf, desc = "Format buffer with LSP" })
      end,
    })
  end,
}
