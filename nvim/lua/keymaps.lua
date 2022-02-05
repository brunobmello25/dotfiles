local g = vim.g
local set = vim.api.nvim_set_keymap
local ns = { noremap = true, silent = true }

g.mapleader = ' '

-- Telescope
set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", ns) -- find file
set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", ns) -- find text
set("n", "<leader>tt", "<cmd>NERDTreeToggle<cr>", ns) -- find text
set("n", "<leader>tf", "<cmd>NERDTreeFocus<cr>", ns) -- find text
set("n", "<leader>tF", "<cmd>NERDTreeFind<cr>", ns) -- find text
