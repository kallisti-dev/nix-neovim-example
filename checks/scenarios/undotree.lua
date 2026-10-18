-- Check that the lazy command opens an undo-tree window and toggles it closed.
local P = Probe
P.assert_eq("undotree initially lazy", false, P.loaded("undotree"))
local before = #vim.api.nvim_list_wins()
vim.cmd.UndotreeToggle()
P.assert_true("command loads undotree", P.loaded("undotree"))
P.assert_true("command opens a window", #vim.api.nvim_list_wins() > before)
local found = false
for _, win in ipairs(vim.api.nvim_list_wins()) do
  if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "undotree" then found = true end
end
P.assert_true("window contains the undo tree", found)
vim.cmd.UndotreeToggle()
P.assert_eq("toggle closes the tree", before, #vim.api.nvim_list_wins())
P.finish("undotree")
