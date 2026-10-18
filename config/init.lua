-- Editor entry point: set options, then load plugins from the package
-- directory package.nix builds beside this file.
vim.loader.enable()

-- Use only Nix-built runtime files. Neovim's own parsers are in lib/nvim,
-- beside its runtime. Plugins in this directory's pack/ load ahead of
-- $VIMRUNTIME, so the Nix-built treesitter parsers and queries win over
-- Neovim's bundled ones.
local config = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local parsers = vim.fn.fnamemodify(vim.env.VIMRUNTIME, ":h:h:h") .. "/lib/nvim"
vim.opt.runtimepath = { config, vim.env.VIMRUNTIME, parsers, config .. "/after" }
vim.opt.packpath = { config, vim.env.VIMRUNTIME }

vim.g.mapleader = " "
vim.keymap.set("n", "<Space>", "<Nop>", { desc = "Leader key" })
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftround = true
vim.opt.autoindent = true
vim.opt.smartindent = false
vim.opt.backup = true
vim.opt.swapfile = true
vim.opt.undofile = true
for option, directory in pairs { backupdir = "backup", directory = "swap", undodir = "undo" } do
  local path = vim.fn.stdpath("state") .. "/" .. directory
  vim.fn.mkdir(path, "p")
  vim.opt[option] = path .. "//"
end
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 100
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.inccommand = "split"
vim.opt.cmdwinheight = 20
vim.opt.autoread = true
vim.opt.history = 10000
vim.opt.formatoptions:append("j")
vim.opt.wrap = false
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.scrolloff = 0
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.wildmode = "longest:full"
vim.opt.wildoptions = { "pum", "tagfile", "fuzzy" }
vim.opt.wildcharm = 26 -- Ctrl-Z: reopen completion from a command-line mapping.
for key, replacement in pairs {
  ["<Up>"] = "<Left>",
  ["<Down>"] = "<Right>",
  ["<Left>"] = "<Up>",
  ["<Right>"] = " <BS><C-Z>",
} do
  vim.keymap.set("c", key, function() return vim.fn.wildmenumode() == 1 and replacement or key end, { expr = true })
end
vim.opt.cedit = "\005"
vim.opt.spell = true
vim.opt.spelllang = { "en" }
vim.opt.spelloptions = "camel"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
-- Show diagnostics below the lines they refer to; Neovim only shows signs by default.
vim.diagnostic.config { virtual_lines = true }
require("title")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix" })
vim.keymap.set("n", "<leader>qn", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>qp", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(event)
    vim.keymap.set("n", "<Tab>", "<CR>:copen<CR>", { buffer = event.buf, desc = "Preview quickfix item" })
  end,
})
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

-- lz.n loads each plugin when one of its spec's triggers fires (lua/plugins/),
-- or right away if it has none. Neovim sources a plugin's plugin/ scripts,
-- then after/plugin/ scripts, in its load-plugins step after this file.
-- Plugins loaded before then only need adding to 'runtimepath' (packadd!);
-- a plain packadd would source plugin/ twice. Later, packadd sources plugin/
-- but not after/plugin/, where nvim-cmp's sources register.
vim.g.lz_n = {
  load = function(name)
    if vim.v.vim_did_init == 0 then
      vim.cmd.packadd { name, bang = true }
      return
    end
    vim.cmd.packadd(name)
    local after = "pack/*/opt/" .. name .. "/after/plugin/**/*.{vim,lua}"
    for _, file in ipairs(vim.fn.globpath(vim.o.packpath, after, false, true)) do
      vim.cmd.source(file)
    end
  end,
}
require("lz.n").load("plugins")

-- Neovim's optional quickfix filter and text justification packages. Its
-- matchit stays off: vim-matchup also maps %, and loads on the first read.
vim.g.loaded_matchit = 1
vim.cmd.packadd { "cfilter", bang = true }
vim.cmd.packadd { "justify", bang = true }

local function spell_highlights()
  for _, group in ipairs { "SpellRare", "SpellCap", "SpellLocal" } do
    vim.api.nvim_set_hl(0, group, {})
  end
end
spell_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = spell_highlights })

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank { timeout = 150 } end,
})
