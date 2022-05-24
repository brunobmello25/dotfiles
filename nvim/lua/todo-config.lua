require("todo-comments").setup {
}

vim.api.nvim_set_keymap('n', '<leader>lt', ':TodoTelescope<CR>', { noremap = true })
