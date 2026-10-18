-- Run a real file picker and open the selected result.
Probe.assert_eq("Telescope initially lazy", false, Probe.loaded("telescope.nvim"))
vim.cmd("Telescope find_files default_text=tracked.txt")
local prompt = vim.api.nvim_get_current_buf()
local picker = require("telescope.actions.state").get_current_picker(prompt)
Probe.assert_true(
  "file search finds the fixture",
  vim.wait(5000, function()
    local entry = picker:get_selection()
    return entry and entry.value:match("tracked.txt$") ~= nil
  end, 25)
)
require("telescope.actions").select_default(prompt)
Probe.assert_eq("selected file opens", "tracked.txt", vim.fn.expand("%:t"))
vim.cmd("Telescope live_grep default_text=First")
prompt = vim.api.nvim_get_current_buf()
picker = require("telescope.actions.state").get_current_picker(prompt)
Probe.assert_true(
  "ripgrep finds text in the fixture",
  vim.wait(5000, function()
    local entry = picker:get_selection()
    return entry and entry.filename:match("tracked.txt$") ~= nil
  end, 25)
)
require("telescope.actions").select_default(prompt)
Probe.assert_eq("text search opens the matching line", "First line.", vim.api.nvim_get_current_line())
Probe.finish("telescope")
