-- Check nixd attachment and formatting through nixfmt.
vim.cmd.edit("sample.nix")
local client
Probe.assert_true(
  "nixd initializes and attaches",
  vim.wait(10000, function()
    client = vim.lsp.get_clients({ bufnr = 0, name = "nixd" })[1]
    return client and client.initialized
  end, 25)
)
if client and client.initialized then
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "{answer=42;}" })
  vim.lsp.buf.format { async = false, timeout_ms = 5000 }
  Probe.assert_true(
    "Nix formatting rewrites the attribute",
    table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):match("answer = 42;") ~= nil
  )
end
Probe.finish("nix")
