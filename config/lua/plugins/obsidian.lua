-- Notes, daily journals, templates, and links in the vault selected by NVIM_VAULT.
local vault = vim.env.NVIM_VAULT
return {
  "obsidian.nvim",
  enabled = vault ~= nil and vault ~= "",
  cmd = "Obsidian",
  ft = "markdown",
  -- Obsidian uses Telescope for its pickers only if Telescope has loaded by
  -- the time a picker opens, and it doesn't load it itself.
  before = function() require("lz.n").trigger_load("telescope.nvim") end,
  keys = {
    { "<leader>nn", "<cmd>Obsidian new<cr>", desc = "New note" },
    { "<leader>nn", "<cmd>Obsidian link_new<cr>", mode = "v", desc = "Link selection to new note" },
    { "<leader>nd", "<cmd>Obsidian today<cr>", desc = "Today's note" },
    { "<leader>nD", "<cmd>Obsidian tomorrow<cr>", desc = "Tomorrow's note" },
    { "<leader>ny", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's note" },
    { "<leader>nf", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
    { "<leader>nt", "<cmd>Obsidian new_from_template<cr>", desc = "New note from template" },
    {
      "<leader>nt",
      function() require("notes").link_from_template() end,
      mode = "v",
      desc = "Create template note from selection",
    },
    { "<leader>nT", "<cmd>Obsidian tags<cr>", desc = "Find tags" },
  },
  beforeAll = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function() vim.opt_local.conceallevel = 2 end,
    })
  end,
  after = function()
    local notes = require("notes")
    require("obsidian").setup {
      workspaces = { { name = "vault", path = vault } },
      daily_notes = { folder = "daily", template = "today.md", default_tags = { "daily" } },
      new_notes_location = "notes_subdir",
      notes_subdir = "notebox",
      note_id_func = function(title)
        local slug = title and title:gsub("[ _/]", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        return tostring(os.time()) .. (slug and "-" .. slug or "")
      end,
      note_path_func = function(spec) return (spec.dir / tostring(spec.id)):with_suffix(".md") end,
      picker = { name = "telescope.nvim" },
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        -- {{start_of_week}} and the like in a template become these dates.
        substitutions = {
          start_of_week = function() return notes.weekday(2) end,
          end_of_week = function() return notes.weekday(6) end,
          start_of_next_week = function() return notes.weekday(2, 1) end,
          end_of_next_week = function() return notes.weekday(6, 1) end,
          start_of_last_week = function() return notes.weekday(2, -1) end,
          end_of_last_week = function() return notes.weekday(6, -1) end,
        },
        -- Per-template settings: a note made from templates/weekly.md goes
        -- in weekly/ and is named after this week's Monday.
        customizations = {
          weekly = {
            notes_subdir = "weekly",
            note_id_func = function() return notes.weekday(2) end,
          },
        },
      },
      callbacks = { enter_note = notes.mappings },
      attachments = {
        folder = "assets/imgs",
        img_name_func = function() return tostring(os.time()) end,
      },
      legacy_commands = false,
    }
  end,
}
