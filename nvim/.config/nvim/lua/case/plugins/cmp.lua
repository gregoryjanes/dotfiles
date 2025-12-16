return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    -- Snippet engine
    'L3MON4D3/LuaSnip',
    -- Snippet source for nvim-cmp
    'saadparwaiz1/cmp_luasnip',
    
    -- nvim-cmp sources
    'hrsh7th/cmp-nvim-lsp', -- Source for LSP
    'hrsh7th/cmp-buffer',   -- Source for buffer text
    'hrsh7th/cmp-path',     -- Source for file paths
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup({
      snippet = {
        -- Tell cmp to use luasnip for snippet expansion
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),

        -- 1. Disable standard Up/Down/Enter in cmp (pass to Neovim)
        ['<Down>'] = cmp.mapping(function(fallback) fallback() end),
        ['<Up>']   = cmp.mapping(function(fallback) fallback() end),
        ['<CR>']   = cmp.mapping(function(fallback) fallback() end),

        -- 2. Use Ctrl+Down/Up to cycle options
        ['<C-Down>'] = cmp.mapping.select_next_item(),
        ['<C-Up>']   = cmp.mapping.select_prev_item(),

        -- 3. TAB: Confirm ONLY if an item is manually selected
        ['<Tab>'] = cmp.mapping(function(fallback)
          -- If menu is open and an item is selected, confirm it
          if cmp.visible() and cmp.get_selected_entry() then
             cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          -- If inside a snippet, jump to next placeholder
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback() -- Otherwise insert a real tab
          end
        end, { 'i', 's' }),

        -- 4. Ctrl+Tab: Aggressively confirm (Auto-selects first item if none selected)
        ['<C-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
             cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
          else
             fallback()
          end
        end, { 'i', 's' }),
        
        -- S-Tab to jump backwards in snippets (optional but recommended)
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),      -- Order of sources matters!
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
        { name = 'path' },
      }),
    })
  end,
}
