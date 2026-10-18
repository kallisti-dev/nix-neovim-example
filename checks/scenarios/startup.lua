-- Check cold-start plugin state and that every runtime file comes from Nix.
local P = Probe
P.assert_true("lz.n loaded", package.loaded["lz.n"] ~= nil)
P.assert_true("theme loads at startup", P.loaded("nightfox.nvim"))
P.assert_eq("Nightfox is active", "nightfox", vim.g.colors_name)
P.assert_true("Oil handles directories from startup", P.loaded("oil.nvim"))
P.assert_eq("completion waits for insert mode", false, P.loaded("nvim-cmp"))
P.assert_eq("Telescope waits for a command", false, P.loaded("telescope.nvim"))
P.assert_eq("lspconfig waits for a file", false, P.loaded("nvim-lspconfig"))
P.assert_eq("undotree stays lazy", false, P.loaded("undotree"))
P.assert_eq("matchup waits for a file", false, P.loaded("vim-matchup"))
P.assert_eq("surround waits for the UI", false, P.loaded("nvim-surround"))
for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
  P.assert_true("runtime path is Nix supplied", path:match("^/nix/store/") ~= nil)
end
for _, path in ipairs(vim.opt.packpath:get()) do
  P.assert_true("package path is Nix supplied", path:match("^/nix/store/") ~= nil)
end
P.snapshot()
P.finish("startup")
