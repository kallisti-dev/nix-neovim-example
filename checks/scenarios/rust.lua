-- Exercise rust-analyzer completion, formatting, and macro expansion in a crate.
local indexed = false
vim.lsp.config("rust_analyzer", {
  handlers = {
    ["experimental/serverStatus"] = function(_, status) indexed = status.quiescent end,
  },
})
vim.cmd.edit("rust/src/main.rs")
local buffer = vim.api.nvim_get_current_buf()
local client
Probe.assert_true(
  "rust-analyzer attaches",
  vim.wait(10000, function()
    client = vim.lsp.get_clients({ bufnr = buffer, name = "rust_analyzer" })[1]
    return client and client.initialized
  end, 25)
)
Probe.assert_true("Rust syntax tree", not vim.treesitter.get_parser(buffer):parse()[1]:root():has_error())
if client and client.initialized then
  -- Initialization can finish before the Cargo workspace is indexed. A request
  -- may briefly succeed during loading, then return nil when the crate graph changes.
  Probe.assert_true("Rust workspace indexing completes", vim.wait(10000, function() return indexed end, 25))
  local response
  Probe.assert_true(
    "macro expands to 42",
    vim.wait(10000, function()
      response = client:request_sync("rust-analyzer/expandMacro", {
        textDocument = { uri = vim.uri_from_bufnr(buffer) },
        position = { line = 8, character = 30 },
      }, 1000, buffer)
      return response and response.result and response.result.expansion:match("42") ~= nil
    end, 100)
  )
  vim.api.nvim_win_set_cursor(0, { 9, 30 })
  vim.cmd.ExpandMacro()
  Probe.assert_true(
    "ExpandMacro opens a Rust buffer",
    vim.wait(10000, function()
      return vim.api.nvim_get_current_buf() ~= buffer
        and vim.bo.filetype == "rust"
        and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "42"
    end, 25)
  )
  vim.api.nvim_set_current_buf(buffer)
  vim.api.nvim_buf_set_lines(buffer, 9, 10, false, { "    let _ = item.va" })
  local completion = client:request_sync("textDocument/completion", {
    textDocument = { uri = vim.uri_from_bufnr(buffer) },
    position = { line = 9, character = 19 },
  }, 5000, buffer)
  local found = false
  for _, item in ipairs(completion and completion.result and (completion.result.items or completion.result) or {}) do
    if item.label:match("^value") then found = true end
  end
  Probe.assert_true("Rust completion finds a struct field", found)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "fn main(){let answer=42;}" })
  vim.lsp.buf.format { async = false, timeout_ms = 5000, bufnr = buffer }
  Probe.assert_true(
    "rustfmt formats the buffer",
    table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n"):match("let answer = 42;") ~= nil
  )
end
Probe.finish("rust")
