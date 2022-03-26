vim.opt.tabstop = 2
vim.opt.mouse = 'a'
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.scrolloff = 8
vim.cmd('filetype plugin indent on')

vim.g.mapleader = ' '

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- git fugitive
map('n', '<leader>gj', ':diffget //3<CR>')
map('n', '<leader>gf', ':diffget //2<CR>')
map('n', '<leader>gs', ':G<CR>')
