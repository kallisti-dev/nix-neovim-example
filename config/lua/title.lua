-- Show the current file in the terminal title, relative to the tmux session.
local prefix

--- Cache the session directory for this editor, abbreviating HOME as ~.
local function session_prefix()
  if prefix ~= nil then return prefix end
  prefix = ""
  if vim.env.TMUX then
    local result = vim.fn.system({ "tmux", "display-message", "-p", "#{session_path}" }):gsub("\n$", "")
    if vim.v.shell_error == 0 and result ~= "" then prefix = vim.fn.fnamemodify(result, ":~") .. "/" end
  end
  return prefix
end

--- Called by titlestring; strip Oil's URI prefix and keep the modified marker.
function _G.custom_titlestring()
  local name = vim.api.nvim_buf_get_name(0)
  local file = vim.fn.fnamemodify(name:match("^oil://(.*)") or name, ":~")
  local base = session_prefix()
  if base ~= "" then file = file:gsub("^" .. vim.pesc(base), "") end
  return "nvim" .. (file ~= "" and " " .. file or "") .. (vim.bo.modified and " [+]" or "")
end

vim.opt.title = true
vim.opt.titlestring = "%{v:lua.custom_titlestring()}"
