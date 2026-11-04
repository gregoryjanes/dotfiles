vim.g.mapleader = ' '
vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python") -- needed by molten

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("case.plugins")

vim.o.background = "dark" -- or "light" for light mode
vim.opt.termguicolors = true -- exact theme hex colors, same as kitty's
vim.cmd.colorscheme("everforest")

vim.opt.clipboard = 'unnamedplus'
vim.opt.number = true
vim.opt.relativenumber = true
-- Indentation: 4 spaces everywhere. <Tab>, >>, auto-indent and <BS> all move by one 4-space step.
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = -1 -- follow shiftwidth
-- Filetype plugins (yaml, etc.) override the above per buffer; put it back. Go and Makefiles
-- keep real tabs because gofmt and make require them (still displayed 4 wide).
-- A project's .editorconfig is applied after this, so shared repos keep their own style.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local tabs = args.match == "make" or args.match == "go"
    vim.bo.expandtab = not tabs
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = -1
  end,
})

-- Spellcheck on for prose. ]s / [s jump between errors, z= suggests, zg adds the word.
vim.opt.spelllang = "en_us"
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "markdown", "text", "gitcommit" },
  callback = function() vim.opt_local.spell = true end,
})

-- nvim-tree binds 
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- nvim-ale config
vim.cmd [[
  let g:ale_linters = {
      \ 'typescript': ['ts_ls'],
      \ 'typescriptreact': ['ts_ls'],
      \ }
  let g:ale_fixers = {
      \ 'typescript': ['prettier'],
      \ 'typescriptreact': ['prettier'],
      \ }
  let g:ale_fix_on_save = 1
]]

vim.opt.clipboard = "unnamedplus"
