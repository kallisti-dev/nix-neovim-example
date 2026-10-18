-- Work with notes in an isolated vault: a daily note from a template, checkbox
-- editing, the note mappings, and a new note linked from a selection.
vim.cmd.edit("vault/welcome.md")
Probe.assert_true("Obsidian loads for the configured vault", Probe.loaded("obsidian.nvim"))
Probe.assert_eq("notes conceal link syntax", 2, vim.wo.conceallevel)
Probe.assert_true(
  "Obsidian's pickers use Telescope",
  require("obsidian.api").get_plugin_info("telescope.nvim") ~= nil
)
local function attached(name) return #vim.lsp.get_clients { bufnr = 0, name = name } > 0 end
Probe.assert_true(
  "Obsidian's and Marksman's language servers attach",
  vim.wait(10000, function() return attached("obsidian-ls") and attached("marksman") end, 25)
)
Probe.assert_eq("gl lists the note's links", "<cmd>obsidian links<cr>", vim.fn.maparg("gl", "n"):lower())

-- Visual Space nt replaces the selection with a link to a new note from a
-- template. Telescope's picker replaced vim.ui.select once Obsidian loaded.
vim.ui.select = function(items, _, choose) choose(items[1]) end
vim.api.nvim_win_set_cursor(0, { 1, 2 })
Probe.feed("viw<leader>nt")
local note
Probe.assert_true(
  "a note from the template is written",
  vim.wait(5000, function()
    note = vim.fn.glob("vault/notebox/*-welcome.md", false, true)[1]
    return note ~= nil and table.concat(vim.fn.readfile(note), "\n"):find("Write a note", 1, true) ~= nil
  end, 25)
)
Probe.assert_true(
  "the selection links to the note",
  vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]:match("^# %[%[%d+%-welcome|Welcome%]%]$")
)

vim.cmd("Obsidian today")
Probe.assert_true(
  "daily note opens",
  vim.wait(
    3000,
    function() return vim.fn.expand("%:p:h:t") == "daily" and vim.fn.expand("%:t") == os.date("%Y-%m-%d") .. ".md" end,
    25
  )
)
local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
local checkbox
for index, line in ipairs(lines) do
  if line == "- [ ] Write a note" then checkbox = index end
end
Probe.assert_true("template content inserted", checkbox ~= nil)
if checkbox then
  vim.api.nvim_win_set_cursor(0, { checkbox, 0 })
  vim.cmd("Obsidian toggle_checkbox")
  Probe.assert_eq("checkbox advances to in-progress", "- [~] Write a note", vim.api.nvim_get_current_line())
  for _ = 1, 3 do
    vim.cmd("Obsidian toggle_checkbox")
  end
  Probe.assert_eq("checkbox advances to done", "- [x] Write a note", vim.api.nvim_get_current_line())
end
Probe.finish("notes")
