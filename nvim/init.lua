require('quickscope-config')
require('basics-config')
require('fugitive-config')
require('colors-config')
require('telescope-config')
require('lsp-installer-config')
require('lsp-config')
require('harpoon-config')
require('signify-config')
require('treesitter-config')
require('comment-config')
require('neoformat-config')
require('copilot-config')
require('todo-config')
require('lualine-config')

return require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- plugin manager
  use 'nvim-treesitter/nvim-treesitter' -- syntax highlighting
  use { 'catppuccin/nvim', as = 'catppuccin' } -- color theme
  use 'nvim-lua/plenary.nvim' -- requirement for other plugins
  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } }
  } -- fuzzy finder
  use 'hrsh7th/nvim-cmp' -- autocompletion
  use 'saadparwaiz1/cmp_luasnip' -- autocompletion
  use 'L3MON4D3/LuaSnip' -- autocompletion
  use 'hrsh7th/cmp-nvim-lsp' -- autocompletion
  use {
    "williamboman/nvim-lsp-installer",
    "neovim/nvim-lspconfig",
  }
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
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
  use 'mfussenegger/nvim-dap' -- Debugger
  use 'windwp/nvim-ts-autotag' -- autoclose and autorename tags using treesitter
  use 'gennaro-tedesco/nvim-peekup' -- see all registers in a floating window
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
  }
end)
