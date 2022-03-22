-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- BASIC LUA SETUP
  use 'wbthomason/packer.nvim'
  use 'nvim-treesitter/nvim-treesitter'

  -- COLOR THEME
  use {'catppuccin/nvim', as = 'catppuccin'}

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
      }
    end
  }

  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-lua/plenary.nvim'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzy-native.nvim'},
      {'nvim-treesitter/nvim-treesitter'}
    }
  }
  use 'neovim/nvim-lspconfig'
end)
