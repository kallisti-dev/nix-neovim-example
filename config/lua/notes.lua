-- Shared date substitutions and buffer actions for the Obsidian configuration.
local M = {}

--- Return YYYY-MM-DD for a weekday (Sunday=1), optionally offset by whole weeks.
--- Calendar arithmetic lets os.time handle month boundaries and daylight saving.
function M.weekday(day, weeks)
  assert(day >= 1 and day <= 7, "weekday must be within 1–7")
  local date = os.date("*t")
  date.day = date.day + day - date.wday + 7 * (weeks or 0)
  date.hour, date.min, date.sec, date.isdst = 12, 0, 0, nil
  return os.date("%Y-%m-%d", os.time(date))
end

--- Turn a single-line visual selection into a link to a new note from a template.
function M.link_from_template()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  local buffer = vim.api.nvim_get_current_buf()
  vim.schedule(function()
    local row, end_row = vim.fn.line("'<"), vim.fn.line("'>")
    if row ~= end_row then
      vim.notify("Select text on a single line", vim.log.levels.WARN)
      return
    end
    local line = vim.api.nvim_buf_get_lines(buffer, row - 1, row, false)[1]
    -- A linewise selection puts '< at column 0 and '> past the end of the line.
    local col, end_col = math.max(vim.fn.col("'<") - 1, 0), math.min(vim.fn.col("'>"), #line)
    -- '> marks the first byte of the last character; include all of its bytes.
    if end_col > 0 then end_col = end_col + vim.str_utf_end(line, end_col) end
    local text = line:sub(col + 1, end_col)
    if text == "" then return end
    local templates = require("obsidian.api").templates_dir()
    if not templates then
      vim.notify("The vault has no templates folder", vim.log.levels.WARN)
      return
    end
    local files = vim.fn.glob(tostring(templates) .. "/*.md", false, true)
    local names = vim.tbl_map(function(file) return vim.fn.fnamemodify(file, ":t:r") end, files)
    table.sort(names)
    vim.ui.select(names, { prompt = "Template:" }, function(template)
      if not template then return end
      -- Obsidian names the file by passing the id to note_id_func, and uses the
      -- id as the title. Note.create only builds the note; write() saves it,
      -- filled from the template.
      local note = require("obsidian.note").create { id = text, template = template }
      note:write()
      vim.api.nvim_buf_set_text(buffer, row - 1, col, end_row - 1, end_col, { note:format_link { label = text } })
    end)
  end)
end

--- Install note-specific mappings when entering a vault buffer.
function M.mappings()
  vim.keymap.set(
    "n",
    "gf",
    function() return require("obsidian.api").cursor_link() and "<cmd>Obsidian follow_link<cr>" or "gf" end,
    { buffer = true, expr = true, desc = "Follow note link" }
  )
  vim.keymap.set(
    "n",
    "<cr>",
    function() return require("obsidian.actions").smart_action() end,
    { buffer = true, expr = true, desc = "Follow link or toggle checkbox" }
  )
  for keys, command in pairs {
    ["<leader>nc"] = "toggle_checkbox",
    gb = "backlinks",
    ["<leader>nb"] = "backlinks",
    gl = "links",
    ["<leader>nl"] = "links",
  } do
    vim.keymap.set("n", keys, "<cmd>Obsidian " .. command .. "<cr>", { buffer = true, desc = "Note " .. command })
  end
  vim.keymap.set("v", "<leader>nc", ":Obsidian toggle_checkbox<cr>", { buffer = true, desc = "Toggle checkboxes" })
  vim.keymap.set("v", "<leader>ne", ":Obsidian extract_note<cr>", { buffer = true, desc = "Extract note" })
end

return M
