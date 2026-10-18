-- Load editing tools, open the file tree, and switch to an alternate theme.
vim.cmd.edit("sample.lua")
vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter" })
Probe.assert_true("indent guides initialized", require("ibl.config").get_config(0).enabled)
-- Defined in an after/plugin script, which init.lua's lz.n load function sources.
Probe.assert_eq("indent guides command defined", 2, vim.fn.exists(":IBLToggle"))
Probe.assert_true(
  "programming dictionary available",
  #vim.api.nvim_get_runtime_file("spell/programming.utf-8.spl", false) > 0
)
Probe.assert_true("programming spell language enabled", vim.tbl_contains(vim.opt.spelllang:get(), "programming"))
Probe.assert_eq("programming words are accepted", "", vim.fn.spellbadword("deserialization allowlisting")[1])
Probe.assert_eq("misspellings are still caught", "speling", vim.fn.spellbadword("speling")[1])
Probe.assert_eq("builtin quickfix filter available", 2, vim.fn.exists(":Cfilter"))
vim.cmd.NvimTreeOpen()
Probe.assert_eq("file tree opens", "NvimTree", vim.bo.filetype)
vim.cmd.NvimTreeClose()
vim.cmd.colorscheme("tokyonight")
Probe.assert_true("alternate theme loads on demand", Probe.loaded("tokyonight.nvim"))
Probe.assert_true("Tokyo Night applied", vim.g.colors_name:match("^tokyonight") ~= nil)
require("lz.n").trigger_load("octo.nvim")
Probe.assert_eq("GitHub commands registered", 2, vim.fn.exists(":Octo"))
Probe.finish("editing")
