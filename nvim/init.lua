require('basics')
require('colors')
require('telescope')
require('lsp')

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'nvim-treesitter/nvim-treesitter'
  use {'catppuccin/nvim', as = 'catppuccin'}
  use 'nvim-lua/plenary.nvim'
  use 'hrsh7th/nvim-cmp'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use 'hrsh7th/cmp-nvim-lsp'
  use 'neovim/nvim-lspconfig'
end)

