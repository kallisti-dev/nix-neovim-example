-- Use Oil to edit directories and Telescope to search files, text and buffers.
return {
  {
    "oil.nvim",
    -- No triggers, so it loads at startup and can open `nvim-example <directory>`.
    before = function() require("lz.n").trigger_load("nvim-web-devicons") end,
    after = function()
      require("oil").setup {
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        constrain_cursor = "name",
        watch_for_changes = true,
        view_options = { show_hidden = true },
      }
      vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>", { desc = "Edit current directory" })
    end,
  },
  {
    "telescope.nvim",
    cmd = "Telescope",
    before = function()
      require("lz.n").trigger_load {
        "plenary.nvim",
        "nvim-web-devicons",
        "telescope-ui-select.nvim",
        "telescope-oil.nvim",
      }
    end,
    keys = {
      {
        "<leader>f",
        function()
          require("telescope.builtin").find_files { find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" } }
        end,
        desc = "Find files",
      },
      {
        "<leader>d",
        function() require("telescope").extensions.oil.oil() end,
        desc = "Find directories",
      },
      {
        "<leader>s",
        function() require("telescope.builtin").live_grep() end,
        desc = "Search project text",
      },
      {
        "<leader>s",
        function() require("telescope.builtin").grep_string() end,
        mode = "v",
        desc = "Search selection",
      },
      {
        "<leader>b",
        function() require("telescope.builtin").buffers() end,
        desc = "Find open buffers",
      },
      {
        "<leader>h",
        function() require("telescope.builtin").help_tags() end,
        desc = "Search help",
      },
      {
        "<leader>r",
        function() require("telescope.builtin").resume() end,
        desc = "Resume search",
      },
      {
        "<leader>?",
        function() require("telescope.builtin").keymaps() end,
        desc = "Search mappings",
      },
      {
        "<leader>x",
        function() require("telescope.builtin").builtin() end,
        desc = "Find a picker",
      },
      {
        "<leader>vf",
        function() require("telescope.builtin").git_files() end,
        desc = "Find Git files",
      },
      {
        "<leader>vc",
        function() require("telescope.builtin").git_commits() end,
        desc = "Find Git commits",
      },
      {
        "<leader>vb",
        function() require("telescope.builtin").git_branches() end,
        desc = "Find Git branches",
      },
      {
        "<leader>vs",
        function() require("telescope.builtin").git_status() end,
        desc = "Find changed files",
      },
      {
        "<leader>vx",
        function() require("telescope.builtin").git_stash() end,
        desc = "Find Git stashes",
      },
      {
        "<leader>gr",
        function() require("telescope.builtin").lsp_references() end,
        desc = "Find references",
      },
      {
        "<leader>gi",
        function() require("telescope.builtin").lsp_implementations() end,
        desc = "Find implementations",
      },
      {
        "<leader>gd",
        function() require("telescope.builtin").lsp_definitions() end,
        desc = "Find definitions",
      },
      {
        "<leader>go",
        function() require("telescope.builtin").lsp_type_definitions() end,
        desc = "Find type definitions",
      },
      {
        "<leader>lic",
        function() require("telescope.builtin").lsp_incoming_calls() end,
        desc = "Find incoming calls",
      },
      {
        "<leader>loc",
        function() require("telescope.builtin").lsp_outgoing_calls() end,
        desc = "Find outgoing calls",
      },
      {
        "<leader>gl",
        function() require("telescope.builtin").diagnostics() end,
        desc = "Find diagnostics",
      },
      {
        "<leader>lsb",
        function() require("telescope.builtin").lsp_document_symbols() end,
        desc = "Find buffer symbols",
      },
      {
        "<leader>lsw",
        function() require("telescope.builtin").lsp_workspace_symbols() end,
        desc = "Find workspace symbols",
      },
    },
    after = function()
      local telescope = require("telescope")
      telescope.setup {
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown {},
          oil = {
            -- A function, not a table: the extension appends --hidden to the
            -- table it's given, so a shared table would grow on every search.
            find_command = function() return { "fd", "--type", "d", "--exclude", ".git", "--color", "never" } end,
          },
        },
      }
      telescope.load_extension("oil")
      telescope.load_extension("ui-select")
    end,
  },
  {
    "nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile" },
    keys = {
      { "<leader>t", "<cmd>NvimTreeFindFile<cr>", desc = "Find current file in tree" },
      { "<leader>T", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
    before = function() require("lz.n").trigger_load("nvim-web-devicons") end,
    after = function() require("nvim-tree").setup { disable_netrw = false, filters = { dotfiles = false } } end,
  },
  -- Libraries and Telescope extensions, loaded by the specs that use them.
  { "plenary.nvim", lazy = true },
  { "nvim-web-devicons", lazy = true },
  { "telescope-ui-select.nvim", lazy = true },
  { "telescope-oil.nvim", lazy = true },
}
