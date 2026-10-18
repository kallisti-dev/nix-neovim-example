-- Select and move by functions and classes through the configured mappings.
vim.cmd.edit("greeter.py")

local function selection() return vim.fn.line("'<") .. "-" .. vim.fn.line("'>") end
local function move(line, keys)
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  Probe.feed(keys)
  return vim.fn.line(".")
end

vim.api.nvim_win_set_cursor(0, { 8, 2 })
Probe.feed("vaf<Esc>")
Probe.assert_eq("af selects the enclosing function", "7-8", selection())
vim.api.nvim_win_set_cursor(0, { 4, 4 })
Probe.feed("vac<Esc>")
Probe.assert_eq("ac selects the enclosing class", "2-4", selection())
Probe.assert_eq("]f moves to the next function", 3, move(1, "]f"))
Probe.feed("]f")
Probe.assert_eq("]f again moves to the one after", 7, vim.fn.line("."))
Probe.assert_eq("[c moves to the previous class", 2, move(8, "[c"))
vim.wo.diff = true
Probe.assert_eq("]c is Vim's next change in diff mode", "]c", vim.fn.maparg("]c", "n", false, true).callback())
vim.wo.diff = false
Probe.finish("textobjects")
