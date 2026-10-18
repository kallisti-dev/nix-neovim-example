-- Check executable wiring for every server and real attachment for common formats.
require("lz.n").trigger_load("nvim-lspconfig")
for _, name in ipairs {
  "rust_analyzer",
  "marksman",
  "bashls",
  "taplo",
  "ts_ls",
  "gopls",
  "buf_ls",
  "perlpls",
  "jsonls",
  "jsonnet_ls",
  "nixd",
  "lua_ls",
  "basedpyright",
  "ruff",
  "yamlls",
} do
  local config = vim.lsp.config[name]
  Probe.assert_true(name .. " is enabled", vim.lsp.is_enabled(name))
  -- Some configs use a function to prefer a project's node_modules executable.
  local commands =
    { ts_ls = "typescript-language-server", jsonls = "vscode-json-language-server", yamlls = "yaml-language-server" }
  local command = commands[name] or config.cmd[1]
  Probe.assert_true(name .. " executable exists", vim.fn.executable(command) == 1)
end
vim.fn.mkdir(".git", "p")
vim.fn.writefile({ '{"compilerOptions": {"strict": true}}' }, "tsconfig.json")
vim.fn.writefile({ "version: v2" }, "buf.yaml")
vim.fn.writefile({ "module example.invalid/editor", "go 1.23" }, "go.mod")
for _, fixture in ipairs {
  { "sample.toml", "answer = 42", "taplo" },
  { "sample.yaml", "answer: 42", "yamlls" },
  { "sample.json", '{"answer":42}', "jsonls" },
  { "sample.jsonnet", "{ answer: 42 }", "jsonnet_ls" },
  { "sample.ts", "const answer: number = 42;", "ts_ls" },
  { "sample.proto", 'syntax = "proto3"; message Example { int32 answer = 1; }', "buf_ls" },
  { "sample.pl", 'use strict; use warnings; print "hello\\n";', "perlpls" },
  { "sample.sh", '#!/bin/sh\nprintf "hello\\n"', "bashls" },
  { "sample.md", "# Hello", "marksman" },
  { "sample.go", "package main\nfunc main() {}", "gopls" },
} do
  vim.fn.writefile(vim.split(fixture[2], "\n"), fixture[1])
  vim.cmd.edit(fixture[1])
  Probe.assert_true(
    fixture[3] .. " attaches to " .. fixture[1],
    vim.wait(5000, function()
      local client = vim.lsp.get_clients({ bufnr = 0, name = fixture[3] })[1]
      return client and client.initialized
    end, 25)
  )
end
Probe.finish("languages")
