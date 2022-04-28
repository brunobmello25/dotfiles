require('basics-config')
require('fugitive-config')
require('colors-config')
require('telescope-config')
require('lsp-config')
require('quickscope-config')
require('harpoon-config')
require('signify-config')
require('treesitter-config')
require('comment-config')
require('neoformat-config')

return require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- plugin manager
  use 'nvim-treesitter/nvim-treesitter' -- syntax highlighting
  use {'catppuccin/nvim', as = 'catppuccin'} -- color theme
  use 'nvim-lua/plenary.nvim' -- requirement for other plugins
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  } -- fuzzy finder
  use 'hrsh7th/nvim-cmp' -- autocompletion
  use 'saadparwaiz1/cmp_luasnip' -- autocompletion
  use 'L3MON4D3/LuaSnip' -- autocompletion
  use 'hrsh7th/cmp-nvim-lsp' -- autocompletion 
  use 'neovim/nvim-lspconfig' -- neovim lsp
  use 'vim-airline/vim-airline' -- statusbar
  use 'tpope/vim-fugitive' -- git integration
  use 'jiangmiao/auto-pairs' -- autoclose pairs
  use 'tpope/vim-surround' -- easy change surrounding tags and quotes
  use 'lukas-reineke/lsp-format.nvim' -- format on save with lsp
  use 'unblevable/quick-scope' -- horizontal finder highlight
  use 'ThePrimeagen/harpoon' -- mark files for navigation
  use 'mhinz/vim-signify' -- line changes with git
  use 'github/copilot.vim' -- github copilot
  use 'sheerun/vim-polyglot' -- languages support
  use 'f-person/git-blame.nvim' -- inline git blame
  use 'terrortylor/nvim-comment'
  use 'romainl/vim-cool' -- disable search highlight after cursor movement
  use 'sbdchd/neoformat'
end)

