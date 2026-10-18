-- Adjust Neovim for the build sandbox; the harness sources this before init.lua.
--
-- Language servers must not watch files here: recursive watchers can exceed
-- the Darwin sandbox's file descriptor limit, and no check depends on
-- file-change notifications. Clearing the capability in
-- vim.lsp.start reaches every server, including Obsidian's, which starts
-- itself with its own capabilities instead of using vim.lsp.config.
local start = vim.lsp.start
vim.lsp.start = function(config, options)
  config = vim.tbl_extend("force", config, {
    capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, {
      workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
    }),
  })
  return start(config, options)
end
