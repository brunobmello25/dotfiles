-- LOAD PLUGINS
require('plugins')

-- BASIC CONFIG
local opt = vim.opt
local cmd = vim.cmd

opt.tabstop = 2
opt.mouse = 'a'
opt.expandtab = true
opt.number = true
opt.relativenumber = true
opt.shiftwidth = 2
opt.scrolloff = 8

cmd('filetype plugin indent on')

-- COLORS CONFIG
require('catppuccin').setup({
	transparent_background=true,
})
cmd[[colorscheme catppuccin]]

-- SHORTCUTS
vim.g.mapleader = ' '

