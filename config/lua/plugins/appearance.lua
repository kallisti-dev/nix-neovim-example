-- Nightfox by default, alternate themes on demand, and a status line.

-- The schemes in an optional plugin's colors/ directory. :colorscheme with any
-- of them loads the plugin first.
local opt = vim.fs.joinpath(vim.opt.packpath:get()[1], "pack/nix/opt")
local function schemes(plugin)
  local names = {}
  for file in vim.fs.dir(vim.fs.joinpath(opt, plugin, "colors")) do
    local name = file:match("^(.+)%.%w+$")
    if name and not vim.tbl_contains(names, name) then table.insert(names, name) end
  end
  return names
end

--- An alternate theme, loaded when :colorscheme names one of its schemes.
--- lazy = true keeps a plugin without a colors/ directory from loading at startup.
local function alternate(plugin, spec)
  return vim.tbl_extend("error", { plugin, lazy = true, colorscheme = schemes(plugin) }, spec or {})
end

return {
  {
    "nightfox.nvim",
    priority = 1000,
    after = function() vim.cmd.colorscheme("nightfox") end,
  },
  {
    "lualine.nvim",
    event = "DeferredUIEnter",
    before = function() require("lz.n").trigger_load("nvim-web-devicons") end,
    after = function()
      require("lualine").setup {
        extensions = { "oil", "nvim-tree", "fugitive", "quickfix" },
      }
    end,
  },
  alternate("tokyonight.nvim", {
    after = function()
      require("tokyonight").setup {
        styles = { comments = { italic = true }, keywords = { italic = false }, sidebars = "dark", floats = "dark" },
        lualine_bold = true,
      }
    end,
  }),
  alternate("oceanic-next"),
  alternate("palenight.vim"),
  alternate("onehalf"),
  alternate("rose-pine"),
  alternate("iceberg.vim"),
  alternate("nord.nvim"),
  alternate("tender.vim"),
  alternate("catppuccin-nvim"),
  alternate("melange-nvim"),
  alternate("kanagawa.nvim"),
  alternate("seoul256.vim"),
  alternate("srcery-vim"),
  alternate("gruvbox"),
  alternate("dracula.nvim"),
}
