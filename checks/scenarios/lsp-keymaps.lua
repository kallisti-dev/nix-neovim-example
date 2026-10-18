-- gd and gD go to a server's definition and declaration only where it has
-- them, and the other LSP keys are Neovim's own.
local function buffer_map(keys) return vim.fn.maparg(keys, "n", false, true).buffer == 1 end

--- Open a file and wait until the server has attached and Neovim has mapped K.
local function open(file, server)
  vim.cmd.edit(file)
  Probe.assert_true(
    server .. " attaches to " .. file,
    vim.wait(10000, function() return #vim.lsp.get_clients { bufnr = 0, name = server } > 0 and buffer_map("K") end, 25)
  )
end

open("sample.py", "basedpyright")
Probe.assert_true("Python: gd goes to the LSP definition", buffer_map("gd"))
Probe.assert_true("Python: gD goes to the LSP declaration", buffer_map("gD"))
open("sample.lua", "lua_ls")
Probe.assert_true("Lua: gd goes to the LSP definition", buffer_map("gd"))
Probe.assert_true("Lua: gD keeps Vim's search, as lua_ls has no declarations", not buffer_map("gD"))
for _, keys in ipairs { "grr", "gri", "grt", "grn", "gra", "gO" } do
  Probe.assert_true(keys .. " is Neovim's LSP mapping", not vim.tbl_isempty(vim.fn.maparg(keys, "n", false, true)))
end
for _, keys in ipairs { "gr", "gi", "go", "gs", "gl" } do
  Probe.assert_true(keys .. " keeps Vim's meaning", vim.tbl_isempty(vim.fn.maparg(keys, "n", false, true)))
end
Probe.assert_eq("diagnostics show as virtual lines", true, vim.diagnostic.config().virtual_lines)
Probe.finish("lsp-keymaps")
