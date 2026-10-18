-- Check that the packaged Lua language server initializes for a Lua file.
vim.cmd.edit("sample.lua")
Probe.assert_true(
  "Lua language server initializes and attaches",
  vim.wait(10000, function()
    local client = vim.lsp.get_clients({ bufnr = 0, name = "lua_ls" })[1]
    return client and client.initialized
  end, 25)
)
Probe.finish("lua")
