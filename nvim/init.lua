require('basics')
require('colors')
require('telescope')
require('lsp')

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'nvim-treesitter/nvim-treesitter'
  use {'catppuccin/nvim', as = 'catppuccin'}
  use 'nvim-lua/plenary.nvim'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'neovim/nvim-lspconfig'
  use 'vim-airline/vim-airline'
  use 'tpope/vim-fugitive'
  use 'jiangmiao/auto-pairs'
  use 'tpope/vim-surround'
  use 'lukas-reineke/lsp-format.nvim'
end)

