-- Load the undo-history browser when its command or Space-u mapping is used.
return {
  "undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Show Undo Tree (UndotreeToggle)" },
  },
}
