-- Load keyword/bracket matching on file reads; set Vimscript options beforehand.
return {
  "vim-matchup",
  event = "BufReadPost",
  -- Vimscript plugin: it reads its g: options when it's sourced.
  before = function()
    -- Show the match in a floating window when it's scrolled off-screen.
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end,
}
