return {
  'williamboman/mason.nvim',
  dependencies = {
    -- This plugin bridges mason and lspconfig
    'williamboman/mason-lspconfig.nvim',
  },
  config = function()
    -- Enable mason
    require('mason').setup()
    
    local mason_lspconfig = require('mason-lspconfig')

    -- This is the list of servers you want to automatically install.
    -- Add or remove any servers you want from this list.
    -- Find server names here: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
    local servers_to_install = {
      'pyright',     -- Python
      'fortls',      -- Fortran
      'clangd',      -- C / C++
      'texlab',      -- LaTeX
      'lua_ls',       -- Lua
    }

    -- Setup mason-lspconfig to automatically install the servers in the list
    mason_lspconfig.setup({
      ensure_installed = servers_to_install,
      automatic_installation = true, -- Automatically install new servers in the list
    })
  end,
}
