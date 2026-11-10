return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
    init = function()
      -- Disable automatic setup, we are doing it manually
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },
  {
    'williamboman/mason.nvim',
    lazy = false,
    opts = {
      auto_install = true,
    },
    config = true,
  },

  -- snippets
  {
  	"L3MON4D3/LuaSnip",
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets' },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
      -- Here is where you configure the autocompletion settings.
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_cmp()

      -- And you can configure cmp even more, if you want to.
      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action()

      -- friendly-snippets' LaTeX set would flood the \begin{ menu; ours live in snippets/tex.lua
      require("luasnip.loaders.from_vscode").lazy_load({ exclude = { "tex" } })
      require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

      cmp.setup({
        formatting = lsp_zero.cmp_format({details = true}),
        sources = {
          {name = 'nvim_lsp'},
          {name = 'luasnip'},
          },
        -- same menu keys as the rocky-linux branch
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),

          -- Up/Down never touch the menu
          ['<Down>'] = cmp.mapping(function(fallback) fallback() end),
          ['<Up>']   = cmp.mapping(function(fallback) fallback() end),

          -- Shift (or Ctrl) + Down/Up cycle options
          ['<S-Down>'] = cmp.mapping.select_next_item(),
          ['<S-Up>']   = cmp.mapping.select_prev_item(),
          ['<C-Down>'] = cmp.mapping.select_next_item(),
          ['<C-Up>']   = cmp.mapping.select_prev_item(),

          -- Enter confirms only an item you picked, otherwise it's a normal newline
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ select = false })
            else
              fallback()
            end
          end),

          -- Tab confirms only a manually selected item, else jumps in a snippet, else a real tab
          ['<Tab>'] = cmp.mapping(function(fallback)
            local luasnip = require('luasnip')
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Ctrl+Tab confirms, picking the first item if none is selected
          ['<C-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<S-Tab>'] = cmp.mapping(function(fallback)
            local luasnip = require('luasnip')
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
      })

      -- LaTeX: inside `\begin{` show only our environment templates (snippets/tex.lua),
      -- not texlab's bare names, and open the menu as soon as `\begin{` is typed.
      local in_begin = '\\begin{[%a%*]*$'
      cmp.setup.filetype('tex', {
        sources = {
          { name = 'nvim_lsp', entry_filter = function(_, ctx) return not ctx.cursor_before_line:find(in_begin) end },
          { name = 'luasnip', keyword_pattern = [[\w*]], entry_filter = function(e, ctx)
            return e.completion_item.data.filetype == 'tex' or not ctx.cursor_before_line:find(in_begin)
          end },
        },
      })
      vim.api.nvim_create_autocmd('TextChangedI', {
        pattern = '*.tex',
        callback = function()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          if vim.api.nvim_get_current_line():sub(1, col):find('\\begin{$') then cmp.complete() end
        end,
      })
    end
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    cmd = {'LspInfo', 'LspInstall', 'LspStart'},
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
      {'williamboman/mason-lspconfig.nvim'},
    },
    config = function()
      -- This is where all the LSP shenanigans will live
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()

      --- if you want to know more about lsp-zero and mason.nvim
      --- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
      lsp_zero.on_attach(function(client, bufnr)
        -- see :help lsp-zero-keybindings
        -- to learn the available actions
        lsp_zero.default_keymaps({buffer = bufnr})
      end)

      -- mason-lspconfig v2 calls vim.lsp.enable() on every installed server,
      -- so per-server tweaks go through vim.lsp.config() (Neovim 0.11+).
      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      -- Python: use the active venv, else <project root>/.venv, else whatever `python` is on PATH
      vim.lsp.config('pyright', {
        before_init = function(_, config)
          local venv = vim.env.VIRTUAL_ENV or (config.root_dir and config.root_dir .. '/.venv')
          if venv and vim.fn.executable(venv .. '/bin/python') == 1 then
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = venv .. '/bin/python'
          end
        end,
      })

      -- LaTeX: texlab completes \cite{} keys from your .bib files, \ref{} labels, and environments
      require('mason-lspconfig').setup({
        ensure_installed = { 'ts_ls', 'pyright', 'texlab' },
      })
    end
  }
}
