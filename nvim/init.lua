require('basics')
require('colors')
require('telescope')

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
  use 'neovim/nvim-lspconfig'
end)

