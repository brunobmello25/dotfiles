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

-- move lines up and down
vim.api.nvim_set_keymap('n', '<A-j>', ':m+<CR>==', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-k>', ':m-2<CR>==', { noremap = true })
vim.api.nvim_set_keymap('v', '<A-j>', ':m+<CR>gv=gv', { noremap = true })
vim.api.nvim_set_keymap('v', '<A-k>', ':m-2<CR>gv=gv', { noremap = true })

-- indent lines with > and < in visual mode
vim.api.nvim_set_keymap('v', '<Tab>',   '>gv', { noremap = true })
vim.api.nvim_set_keymap('v', '<S-Tab>', '<gv', { noremap = true })
