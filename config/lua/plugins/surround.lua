-- Install surround-editing mappings once the UI is up.
return {
  "nvim-surround",
  -- Maps are created on setup, so load before the first keystroke can use them.
  event = "DeferredUIEnter",
  after = function() require("nvim-surround").setup {} end,
}
