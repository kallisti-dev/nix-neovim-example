-- Check filetype detection, syntax trees, and lazy triggers across languages.
local P = Probe
for _, fixture in ipairs { { "sample.md", "markdown" }, { "sample-match.sh", "sh" }, { "sample.lua", "lua" } } do
  vim.cmd.edit(fixture[1])
  P.assert_eq(fixture[1] .. " filetype", fixture[2], vim.bo.filetype)
  P.assert_true("LSP config loads with the first file", P.loaded("nvim-lspconfig"))
  local trees = vim.treesitter.get_parser(0):parse()
  P.assert_true(fixture[1] .. " has a valid syntax tree", #trees > 0 and not trees[1]:root():has_error())
  P.assert_true(
    fixture[1] .. " has highlighting",
    vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
  )
end
P.assert_true(
  "Nix-built parsers come before Neovim's bundled ones",
  vim.api.nvim_get_runtime_file("parser/lua.*", false)[1]:match("/pack/nix/opt/treesitter%-grammars/") ~= nil
)
vim.cmd.edit("new.py")
P.assert_true("a new file has highlighting", vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil)
P.assert_eq("a new file uses treesitter indentation", "v:lua.require'nvim-treesitter'.indentexpr()", vim.bo.indentexpr)
P.assert_true("matchup loads on file open", P.loaded("vim-matchup"))
-- lz.n fires DeferredUIEnter after UIEnter, which headless Neovim never has.
-- Exercise the event explicitly to test its effect on plugin loading.
vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter" })
P.assert_true("surround loads once the UI is up", P.loaded("nvim-surround"))
P.assert_true("status line loads once the UI is up", P.loaded("lualine.nvim"))
P.assert_true("status line renders", require("lualine").statusline() ~= "")
P.finish("filetypes")
