-- Shared integration-test helpers, loaded once as global Probe before init.lua.
-- Assertions accumulate failures; finish() checks editor health and exits.
-- The harness supplies REPORT for snapshots and a process timeout.
---@class Probe
local Probe = {}
local failures = 0
local notifications = {}

-- Capture warnings/errors without printing duplicate headless notifications.
-- lz.n reports plugins that fail to load, and hooks that raise errors, here.
local function capture(msg, level)
  if (level or vim.log.levels.INFO) >= vim.log.levels.WARN then
    table.insert(notifications, tostring(msg))
  end
end
vim.notify = capture
vim.notify_once = capture

--- Compare values with Lua's == operator and record the result without stopping.
---@param label string
---@param expected any
---@param actual any
function Probe.assert_eq(label, expected, actual)
  if actual == expected then
    io.write("ok: " .. label .. "\n")
  else
    failures = failures + 1
    io.write(string.format("FAIL: %s (expected %q, got %q)\n", label, tostring(expected), tostring(actual)))
  end
  io.flush()
end

--- Record whether condition is truthy, using Lua's boolean conversion.
---@param label string
---@param condition any
function Probe.assert_true(label, condition)
  Probe.assert_eq(label, true, not not condition)
end

--- Every plugin in the package directory, and whether it has loaded: lz.n
--- loads a plugin with :packadd, which adds it to 'runtimepath'.
---@return table<string, boolean>
function Probe.plugins()
  local runtime = {}
  for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
    runtime[vim.fs.normalize(path)] = true
  end
  local plugins = {}
  for _, path in ipairs(vim.fn.globpath(vim.o.packpath, "pack/nix/opt/*", false, true)) do
    plugins[vim.fs.basename(path)] = runtime[vim.fs.normalize(path)] == true
  end
  return plugins
end

--- Return whether the named plugin has loaded; unknown names are false.
---@param name string Plugin name, such as "vim-matchup".
---@return boolean
function Probe.loaded(name)
  return Probe.plugins()[name] == true
end

--- Execute mapped keystrokes synchronously so assertions observe the result.
--- Expands notation such as <Esc>; normal! would bypass the plugin mappings.
---@param keys string
function Probe.feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", false)
end

--- Write sorted plugin load states to REPORT for comparison or reviewed copying.
function Probe.snapshot()
  local lines = {}
  for name, loaded in pairs(Probe.plugins()) do
    table.insert(lines, name .. ": " .. (loaded and "loaded" or "not loaded"))
  end
  table.sort(lines)
  vim.fn.writefile(lines, vim.env.REPORT)
end

--- Assert that nothing warned or failed, print a summary, and exit with status 0/1.
--- Call last in a scenario; any assertion or health-check failure sets exit 1.
---@param name string Scenario name used in the summary.
function Probe.finish(name)
  -- lz.n reports errors from scheduled callbacks; let pending ones run first.
  vim.wait(50)
  Probe.assert_eq("no warnings or errors", "", table.concat(notifications, "\n"))
  io.write(string.format("%s: %d failure(s)\n", name, failures))
  io.flush()
  vim.cmd(failures == 0 and "qa!" or "cquit! 1")
end

--- Open Python and check Ruff formatting, Basedpyright completion and key setup.
--- Supports existing/new files in the fixture project; finishes and exits.
---@param file string Path relative to the harness's writable fixture project.
function Probe.python(file)
  vim.cmd.edit(file)
  Probe.assert_eq("Python filetype", "python", vim.bo.filetype)
  Probe.assert_true("lspconfig loads for Python", Probe.loaded("nvim-lspconfig"))
  Probe.assert_true("Ruff executable comes from Nix", vim.fn.exepath("ruff"):match("^/nix/store/") ~= nil)
  local attached = vim.wait(10000, function()
    local client = vim.lsp.get_clients({ bufnr = 0, name = "ruff" })[1]
    return client and client.initialized
  end, 25)
  Probe.assert_true("Ruff initializes and attaches to this buffer", attached)
  Probe.assert_true("Basedpyright initializes and attaches", vim.wait(10000, function()
    local client = vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })[1]
    return client and client.initialized
  end, 25))
  if attached then
    -- Formatting is registered asynchronously after initialization.
    Probe.assert_true("Ruff registers formatting", vim.wait(10000, function()
      local client = vim.lsp.get_clients({ bufnr = 0, name = "ruff" })[1]
      return client and client:supports_method("textDocument/formatting", 0)
    end, 25))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "x=  1" })
    vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
    Probe.assert_eq("real LSP formatting rewrites the buffer", "x = 1", vim.api.nvim_get_current_line())
    Probe.assert_true("buffer format key is installed", vim.fn.maparg("<Space>cf", "n") ~= "")
  end
  local client = vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })[1]
  if client and client.initialized then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "import os", "os.pa" })
    local buffer = vim.api.nvim_get_current_buf()
    local response, err = client:request_sync("textDocument/completion", {
      textDocument = { uri = vim.uri_from_bufnr(0) },
      position = { line = 1, character = 5 },
    }, 5000, buffer)
    local found = false
    for _, item in ipairs(response and response.result and (response.result.items or response.result) or {}) do
      if item.label == "path" then found = true end
    end
    Probe.assert_true("Python LSP completes os.path", found)
    if err then io.write("completion request: " .. tostring(err) .. "\n") end
  end
  Probe.finish(file)
end

--- Execute a scenario, reporting uncaught Lua errors with a traceback and exit 1.
--- Scenarios call finish() themselves; the shell timeout bounds hangs.
---@param path string Absolute path to a Lua scenario.
function Probe.run(path)
  local ok, err = xpcall(function() dofile(path) end, debug.traceback)
  if not ok then
    io.stderr:write(tostring(err) .. "\n")
    vim.cmd("cquit! 1")
  end
end

return Probe
