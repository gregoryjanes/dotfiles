-- File: ~/.config/nvim/lua/case/plugins/which-key.lua

return {
  "folke/which-key.nvim",
  --event = "VeryLazy",
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
      { "<leader>fc", "<cmd>Telescope bibtex<cr>", desc = "Find Citations", icon = "󰈙" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files", icon = "󰋚" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags", icon = "󰋖" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps", icon = "󰌌" },
      { "<leader>fu", "<cmd>Telescope undo<cr>", desc = "Undo History", icon = "󰕌" },
      { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Yank History", icon = "󰅇" },
      { "<leader>fs", "<cmd>Telescope spell_suggest<cr>", desc = "Spelling Suggestions", icon = "󰓆" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics", icon = "󰒡" },
    })

    -- Group for LSP (works in any file with a language server attached)
    -- Non-leader defaults from lsp-zero also exist: K hover, gd definition, gr references, [d / ]d diagnostics
    wk.add({
      { "<leader>c", group = "Code (LSP)", icon = "󰅩" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", icon = "󰌵" },
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Symbol", icon = "󰑕" },
      { "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format File", icon = "󰉼" },
      { "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics", icon = "󰒡" },
      { "<leader>cg", "<cmd>Telescope lsp_definitions<cr>", desc = "Go to Definition", icon = "󰈮" },
      { "<leader>cR", "<cmd>Telescope lsp_references<cr>", desc = "References", icon = "󰈇" },
      { "<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols", icon = "󰘦" },
      { "<leader>ci", "<cmd>LspInfo<cr>", desc = "LSP Info", icon = "󰋽" },
    })

    -- Group for toggles
    wk.add({
      { "<leader>t", group = "Toggle", icon = "󰔡" },
      { "<leader>ts", "<cmd>setlocal spell!<cr>", desc = "Spellcheck", icon = "󰓆" },
      { "<leader>tw", "<cmd>setlocal wrap!<cr>", desc = "Line Wrap", icon = "󰖶" },
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
        -- These mappings are created ONLY when you open a file matching the pattern.
        -- Using `buffer = 0` makes them buffer-local.
        wk.add({
          buffer = 0,
          { "<leader>l", group = "LaTeX (VimTeX)", icon = "󰙩" },
          { "<leader>lc", "<cmd>VimtexCompile<CR>", desc = "Compile", icon = "󰖷" },
          { "<leader>lv", "<cmd>VimtexView<CR>", desc = "View PDF", icon = "󰛓" },
          { "<leader>le", "<cmd>VimtexErrors<CR>", desc = "Show Errors", icon = "󰅚" },
          { "<leader>li", "<cmd>VimtexTocOpen<CR>", desc = "Table of Contents", icon = "󰋽" },
          { "<leader>lk", "<cmd>VimtexClean<CR>", desc = "Clean Aux Files", icon = "󰩺" },
          { "<leader>ls", "<cmd>VimtexStop<CR>", desc = "Stop Compiler", icon = "󰓛" },
          { "<leader>lo", "<cmd>VimtexCompileOutput<CR>", desc = "Compiler Output", icon = "󰆍" },
          { "<leader>lw", "<cmd>VimtexCountWords<CR>", desc = "Word Count", icon = "󰆿" },
          { "<leader>lb", "<cmd>Telescope bibtex<CR>", desc = "Insert Citation (search)", icon = "󰈙" },
        })
      end,
    })

    -- Python / Jupyter (Molten) Keymaps
    -- Active venv ($VIRTUAL_ENV), else ./.venv in the cwd, else nil (system python3)
    local function venv()
      if vim.env.VIRTUAL_ENV then return vim.env.VIRTUAL_ENV end
      local local_venv = vim.fn.getcwd() .. "/.venv"
      if vim.fn.isdirectory(local_venv) == 1 then return local_venv end
    end

    local function run_file()
      local v = venv()
      local py = v and (v .. "/bin/python") or "python3"
      vim.cmd("write")
      vim.cmd("botright split | terminal " .. py .. " " .. vim.fn.shellescape(vim.fn.expand("%:p")))
    end

    -- Kernel name matches `mkkernel` in zshrc: venv dir name, or project dir name for .venv/venv
    local function molten_init()
      local v = venv()
      if not v then return vim.cmd("MoltenInit python3") end
      local name = vim.fs.basename(v)
      if name == ".venv" or name == "venv" then name = vim.fs.basename(vim.fs.dirname(v)) end
      vim.cmd("MoltenInit " .. name:lower())
    end

    -- Run the `# %%` cell under the cursor, then jump to the next one
    local function run_cell()
      local s = vim.fn.search("^# %%", "bcnW") + 1
      local e = vim.fn.search("^# %%", "nW") - 1
      if e < 0 then e = vim.fn.line("$") end
      vim.fn.MoltenEvaluateRange(s, e)
      vim.fn.cursor(math.min(e + 2, vim.fn.line("$")), 1)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python" },
      callback = function()
        wk.add({
          buffer = 0,
          { "<leader>r", group = "Run Python", icon = "󰌠" },
          { "<leader>rr", run_file, desc = "Run Current File (venv)", icon = "󰐊" },

          { "<leader>j", group = "Jupyter (Molten)", icon = "󰠮" },
          { "<leader>ji", molten_init, desc = "Init Kernel (venv)", icon = "󰐊" },
          { "<leader>jI", "<cmd>MoltenInit<CR>", desc = "Init Kernel (pick)", icon = "󰐊" },
          { "<leader>jc", run_cell, desc = "Run Cell", icon = "󰐊" },
          { "<leader>jl", "<cmd>MoltenEvaluateLine<CR>", desc = "Run Line", icon = "󰐊" },
          { "<leader>jr", "<cmd>MoltenReevaluateCell<CR>", desc = "Re-run Cell", icon = "󰑐" },
          { "<leader>jo", "<cmd>noautocmd MoltenEnterOutput<CR>", desc = "Open Output", icon = "󰈈" },
          { "<leader>jh", "<cmd>MoltenHideOutput<CR>", desc = "Hide Output", icon = "󰈉" },
          { "<leader>jd", "<cmd>MoltenDelete<CR>", desc = "Delete Cell Output", icon = "󰆴" },
          { "<leader>jx", "<cmd>MoltenInterrupt<CR>", desc = "Interrupt Kernel", icon = "󰓛" },
          { "<leader>jR", "<cmd>MoltenRestart!<CR>", desc = "Restart Kernel", icon = "󰜉" },
          { "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>gv<Esc>", desc = "Run Selection", mode = "v", icon = "󰐊" },
        })
      end,
    })

    -- Markdown Keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "md" }, -- Adjusted to only trigger on Markdown files
      callback = function()
        wk.add({
          buffer = 0,
          -- Define the Markdown group with an icon
          { "<leader>m", group = "Markdown", icon = "" },
          
          -- Example markdown bindings (update <cmd> with your actual plugins, e.g., MarkdownPreview)
          { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Preview", icon = "󰈈" },
          { "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Render", icon = "󰽉" },
        })
      end,
    })
    
    -- Add more autocommands here for other filetypes like markdown, lua, etc.
  end,
}


