-- Exercise matching motions and surround edits through real mapped keystrokes.
-- Load-state snapshots alone cannot establish that mappings work.
vim.cmd.edit(vim.env.FIXTURE)
-- Headless Neovim has no UIEnter, which fires lz.n's DeferredUIEnter event.
vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter" })

-- Matchup owns %, including shell keywords as well as builtin bracket pairs.
Probe.assert_eq("% is mapped by vim-matchup", "<Plug>(matchup-%)", vim.fn.maparg("%", "n"))
vim.cmd("normal! 4G0")
Probe.feed("%")
Probe.assert_eq("% jumps if -> fi", "fi", vim.trim(vim.fn.getline(".")))
Probe.feed("%")
Probe.assert_eq("% jumps fi -> if", 4, vim.fn.line("."))

vim.cmd("normal! 10G0f(")
Probe.feed("%")
Probe.assert_eq("% matches brackets", 10, vim.fn.line("."))
Probe.assert_eq("% lands on closing paren", ")", vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col(".")))

for _, motion in ipairs { "g%", "[%", "]%" } do
  Probe.assert_true("matchup motion " .. motion .. " is mapped", vim.fn.maparg(motion, "n") ~= "")
end
for _, object in ipairs { "i%", "a%" } do
  Probe.assert_true(
    "matchup textobject " .. object .. " is mapped",
    vim.fn.maparg(object, "o") ~= "" or vim.fn.maparg(object, "x") ~= ""
  )
end
-- MatchDebug belongs to builtin matchit, which would compete for %.
Probe.assert_true("builtin matchit is not loaded", vim.fn.exists(":MatchDebug") == 0)

Probe.assert_eq("cs is mapped by nvim-surround", "<Plug>(nvim-surround-change)", vim.fn.maparg("cs", "n"))
Probe.assert_eq("ys is mapped by nvim-surround", "<Plug>(nvim-surround-normal)", vim.fn.maparg("ys", "n"))
Probe.assert_eq("ds is mapped by nvim-surround", "<Plug>(nvim-surround-delete)", vim.fn.maparg("ds", "n"))

-- Change quotes, add brackets around the word, then remove those brackets.
vim.cmd("normal! 5G0")
Probe.feed("cs\"'")
Probe.assert_eq("cs\"' rewrites quotes", "echo 'hello'", vim.trim(vim.fn.getline(5)))
vim.cmd("normal! 5G0f'l")
Probe.feed("ysiw]")
Probe.assert_eq("ysiw] adds brackets", "echo '[hello]'", vim.trim(vim.fn.getline(5)))
Probe.feed("ds]")
Probe.assert_eq("ds] removes brackets", "echo 'hello'", vim.trim(vim.fn.getline(5)))

Probe.finish("match-and-surround")
