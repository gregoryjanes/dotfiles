return {
  "ellisonleao/gruvbox.nvim",
  
  priority = 1000, -- This is correct, keep it to load the theme first.
  
  -- Your custom options are good! We'll keep them.
  opts = {
    transparent_mode = true, -- Note: the option is 'transparent_mode'
    styles = {
      sidebars = "transparent", -- Note: the option is 'sidebars' (plural)
      floats = "transparent",   -- Note: the option is 'floats' (plural)
    },
  },

  -- This is the corrected config block.
  config = function(_, opts)
    -- This line applies the options from the 'opts' table above.
    require("gruvbox").setup(opts)
    
    -- This line ACTUALLY sets the colorscheme for Neovim.
    vim.cmd.colorscheme "gruvbox"
  end,
}

