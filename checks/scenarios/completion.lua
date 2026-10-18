-- Check insert completion, actual buffer-source results and builtin snippets.
Probe.assert_eq("completion initially lazy", false, Probe.loaded("nvim-cmp"))
vim.api.nvim_exec_autocmds("InsertEnter", {})
Probe.assert_true("insert event loads completion", Probe.loaded("nvim-cmp"))
local sources = {}
for _, source in ipairs(require("cmp").get_config().sources) do
  sources[source.name] = true
end
for _, source in ipairs { "nvim_lsp", "path", "buffer" } do
  Probe.assert_true(source .. " completion is configured", sources[source])
end
-- Sources register from their after/plugin scripts, which init.lua's lz.n
-- load function sources.
local registered = {}
for _, source in pairs(require("cmp").core.sources) do
  registered[source.name] = true
end
for _, source in ipairs { "path", "buffer", "cmdline", "git" } do
  Probe.assert_true(source .. " source registered", registered[source])
end
local ok, autocmds = pcall(vim.api.nvim_get_autocmds, { group = "cmp_nvim_lsp" })
Probe.assert_true("LSP source set up", ok and #autocmds > 0)
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "completion_word", "completion_" })
local found = false
require("cmp_buffer"):complete({
  option = {},
  context = { cursor_before_line = "completion_" },
  offset = 1,
}, function(result)
  for _, item in ipairs(result.items) do
    if item.label == "completion_word" then found = true end
  end
end)
Probe.assert_true("buffer completion returns a word from the file", vim.wait(3000, function() return found end, 25))
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
require("cmp").get_config().snippet.expand { body = "${1:hello} ${2:world}" }
Probe.assert_eq("snippet expansion inserts editable text", "hello world", vim.api.nvim_get_current_line())
Probe.finish("completion")
