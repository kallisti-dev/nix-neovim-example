-- Render Markdown images in terminals that support Kitty's graphics protocol.
return {
  "image.nvim",
  ft = "markdown",
  after = function()
    if #vim.api.nvim_list_uis() == 0 then return end
    require("image").setup {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          floating_windows = true,
          filetypes = { "markdown", "vimwiki" },
          resolve_image_path = function(document, path, fallback)
            if _G.Obsidian and Obsidian.dir then
              local candidate = tostring(Obsidian.dir) .. "/" .. path
              if vim.fn.filereadable(candidate) == 1 then return candidate end
            end
            return fallback(document, path)
          end,
        },
        neorg = { enabled = false },
        typst = { enabled = false },
        html = { enabled = false },
        css = { enabled = false },
      },
      max_width_window_percentage = 100,
      max_height_window_percentage = 33,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
      tmux_show_only_in_active_window = true,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
    }
  end,
}
