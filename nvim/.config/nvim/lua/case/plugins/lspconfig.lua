return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- We depend on mason to ensure servers are installed
    'williamboman/mason.nvim',
  },
  config = function()
    -- This is the list of servers to *enable*.
    -- It should match the list in mason.lua
    local servers = {
      'pyright',
      'fortls',
      'clangd',
      'texlab',
      'lua_ls',
      -- Add new servers here
    }

    -- Loop through the server list and enable each one.
    -- `nvim-lspconfig` provides the default configurations.
    for _, server_name in ipairs(servers) do
      -- This is the new function you asked about.
      -- It tells Neovim to load the default config for this server
      -- and start it when you open a file of the correct filetype.
      vim.lsp.enable(server_name)
    end
    
    -- (OPTIONAL) Add custom keymaps for LSP features.
    -- This runs when an LSP attaches to a buffer.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local keymaps
        -- See :help vim.lsp.buf and :help vim.keymap.set
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
          vim.lsp.buf.format { async = true }
        end, opts)
      end,
    })
  end,
}
