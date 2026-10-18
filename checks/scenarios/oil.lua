-- Browse the fixture directory and open a file through Oil's selection action.
vim.cmd("Oil .")
local row
Probe.assert_true(
  "Oil lists the fixture",
  vim.wait(5000, function()
    for index, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      if line:match("tracked.txt$") then
        row = index
        return true
      end
    end
  end, 25)
)
Probe.assert_eq("directory buffer uses Oil", "oil", vim.bo.filetype)
if row then
  vim.api.nvim_win_set_cursor(0, { row, 0 })
  require("oil").select()
  Probe.assert_true(
    "selection opens the file",
    vim.wait(3000, function() return vim.fn.expand("%:t") == "tracked.txt" end, 25)
  )
end
Probe.finish("oil")
