-- Stage a real hunk with Gitsigns, open Fugitive's status, and browse to GitHub.
vim.cmd.edit("tracked.txt")
local gs = require("gitsigns")
Probe.assert_true(
  "Gitsigns attaches to the tracked file",
  vim.wait(5000, function() return vim.b.gitsigns_head == "main" end, 25)
)
vim.api.nvim_buf_set_lines(0, 1, 2, false, { "Changed second line." })
Probe.assert_true("Gitsigns detects the change", vim.wait(5000, function() return #(gs.get_hunks() or {}) > 0 end, 25))
gs.stage_hunk { 2, 2 }
Probe.assert_true(
  "hunk reaches the Git index",
  vim.wait(
    5000,
    function() return vim.fn.system({ "git", "diff", "--cached", "--name-only" }):match("tracked.txt") ~= nil end,
    25
  )
)
vim.cmd.Git()
Probe.assert_eq("Git opens Fugitive status", "fugitive", vim.bo.filetype)
vim.cmd.close()
-- Rhubarb supplies GitHub URLs, and Fugitive opens them with vim.ui.open.
local opened
vim.ui.open = function(url) opened = url end
vim.cmd.GBrowse()
Probe.assert_true(
  "GBrowse opens the file on GitHub",
  opened and opened:match("^https://github%.com/example/project/blob/.+/tracked%.txt$")
)
Probe.finish("git")
