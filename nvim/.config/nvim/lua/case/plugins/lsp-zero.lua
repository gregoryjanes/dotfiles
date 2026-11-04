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

      require("luasnip").config.setup({ enable_autosnippets = true })
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
      -- autopairs steps over its own `}` without changing text, so `\begin{equation}` never
      -- fires TextChangedI. Re-check autosnippets on cursor move too, skipping the move
      -- caused by entering insert mode (so `A` on an existing \begin{..} line doesn't re-expand).
      -- ponytail: still fires if you arrow-key to the end of an existing \begin{..} line in insert mode
      local just_entered = false
      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*.tex",
        callback = function() just_entered = true end,
      })
      vim.api.nvim_create_autocmd("CursorMovedI", {
        pattern = "*.tex",
        callback = function()
          if just_entered then just_entered = false return end
          require("luasnip").expand_auto()
        end,
      })

      cmp.setup({
        formatting = lsp_zero.cmp_format({details = true}),
        sources = {
          {name = 'nvim_lsp'},
          {name = 'luasnip'},
          },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({select = false}),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }),
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
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
