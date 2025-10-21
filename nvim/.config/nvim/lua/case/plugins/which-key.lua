-- File: ~/.config/nvim/lua/case/plugins/which-key.lua

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    'echasnovski/mini.nvim',
  },
  opts = {
    preset = "classic",
    delay = function(ctx)
      return ctx.plugin and 0 or 200
    end,
    show_help = false,    -- Remove bottom help/status bar
    show_keys = false,    -- Remove key hints
    win = {
      border = "rounded",
      padding = { 1, 2 },
      title = false,
      title_pos = "center",
      zindex = 1000,
      wo = {
        winblend = 10,
      },
      bo = {
        filetype = "which_key",
        buftype = "nofile",
      },
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    layout = {
      width = { min = 20, max = 50 },
      height = { min = 4, max = 25 },
      spacing = 3,
      align = "left",
    },
    keys = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    sort = { "local", "order", "group", "alphanum", "mod" },
    disable = {
      bt = { "help", "quickfix", "terminal", "prompt" },
      ft = { "neo-tree" }
    },
    triggers = {
      { "<leader>", mode = { "n", "v" } }
    }
},
  config = function(_, opts)
    -- This config function runs after the plugin is loaded
    local wk = require("which-key")
    wk.setup(opts)

    -- =========================================================================
    -- SECTION 1: GLOBAL KEYMAPS
    -- These keymaps will be available in ANY file type.
    -- =========================================================================

    -- Group for general file/window management
    wk.add({
      { "<leader>q", "<cmd>qa!<CR>", desc = "Quit Neovim", icon = "󰗼" },
      { "<leader>w", "<cmd>wa!<CR>", desc = "Write All Files", icon = "󰆓" },
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Explorer", icon = "󰙅" },
    })

    -- Group for Telescope (Find)
    wk.add({
      { "<leader>f", group = "Find (Telescope)", icon = "󰍉" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files", icon = "󰈙" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find Text (Grep)", icon = "󰊄" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers", icon = "󰓩" },
      -- THIS IS THE BIBTEX KEYMAP YOU WANTED!
      -- It's global, but will only work if a .bib file is found by the bibtex extension.
      { "<leader>fc", "<cmd>Telescope bibtex<cr>", desc = "Find Citations", icon = "󰈙" },
    })

    -- =========================================================================
    -- SECTION 2: FILETYPE-SPECIFIC KEYMAPS
    -- PATTERN: Use autocommands to register keymaps only for specific filetypes.
    -- This keeps your keybindings organized and context-aware.
    -- =========================================================================

    -- LaTeX / VimTeX Keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "latex", "bib" }, -- Trigger on these file types
      callback = function()
        -- These mappings are created ONLY when you open a file matching the pattern above.
        wk.add({
          buffer = 0, -- Apply these keymaps only to the current buffer
          { "<leader>l", group = "LaTeX (VimTeX)", icon = "󰙩" },
          { "<leader>lc", "<cmd>VimtexCompile<CR>", desc = "Compile", icon = "󰖷" },
          { "<leader>lv", "<cmd>VimtexView<CR>", desc = "View PDF", icon = "󰛓" },
          { "<leader>le", "<cmd>VimtexErrors<CR>", desc = "Show Errors", icon = "󰅚" },
          { "<leader>li", "<cmd>VimtexTocOpen<CR>", desc = "Table of Contents", icon = "󰋽" },
          { "<leader>lk", "<cmd>VimtexClean<CR>", desc = "Clean Aux Files", icon = "󰩺" },
        })
      end,
    })

    -- Example: Python Keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python" },
      callback = function()
        wk.add({
          buffer = 0,
          { "<leader>r", group = "Run Python", icon = "󰌠" },
          { "<leader>rr", "<cmd>!python %<CR>", desc = "Run Current File", icon = "󰐊" },
        })
      end,
    })

    -- Add more autocommands here for other filetypes like markdown, lua, etc.
  end,
}


