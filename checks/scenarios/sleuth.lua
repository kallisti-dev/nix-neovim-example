-- Sleuth must detect the indentation of the first file read, not only files
-- opened after it loads. The fixture indents by two spaces; Python's ftplugin
-- and this config would set four.
vim.cmd.edit("greeter.py")
vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter" })
Probe.assert_eq("indentation width detected", 2, vim.bo.shiftwidth)
Probe.finish("sleuth")
