local cmp = require'cmp'
local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

cmp.setup({
   snippet = {
      expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
      end,
   },
   mapping = {
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = function(fallback)
      if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end
   },
   sources = {
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'buffer' },
   }
})

-- Setup lspconfig.
lspconfig.tsserver.setup {
   capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
}

lspconfig.solargraph.setup {
   capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
}

vim.cmd([[nnoremap gd :lua vim.lsp.buf.definition()<CR>]])
vim.cmd([[nnoremap gD :lua vim.lsp.buf.declaration()<CR>]])
vim.cmd([[nnoremap gr :lua vim.lsp.buf.references()<CR>]])
vim.cmd([[nnoremap <leader>rn :lua vim.lsp.buf.rename()<CR>]])
vim.cmd([[nnoremap K :lua vim.lsp.buf.hover()<CR>]])
vim.cmd([[nnoremap <leader>. :lua vim.lsp.buf.code_action()<CR>]])
