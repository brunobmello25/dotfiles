vim.opt.tabstop = 2
vim.opt.mouse = 'a'
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.scrolloff = 8
vim.cmd('filetype plugin indent on')

vim.g.mapleader = ' '

-- yank to clipboard
vim.api.nvim_set_keymap('n', '<leader>y', '"+y<CR>', { noremap = true })
vim.api.nvim_set_keymap('v', '<leader>y', '"+y<CR>', { noremap = true })

