return {
  "sainnhe/everforest",
  lazy = false,
  priority = 1000, -- load the theme before other plugins
  init = function()
    vim.g.everforest_background = "hard" -- matches kitty's everforest.conf
    vim.g.everforest_transparent_background = 1 -- let kitty's background/opacity show through
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_better_performance = 1
  end,
}
