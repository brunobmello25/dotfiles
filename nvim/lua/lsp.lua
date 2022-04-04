local cmp = require'cmp'
local lspconfig = require('lspconfig')

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

-- on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  if client.name == 'tsserver' then
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.resolved_capabilities.document_formatting = false
  elseif client.name == 'efm' then
    client.resolved_capabilities.document_formatting = true
    client.resolved_capabilities.goto_definition = false
  end

  -- enable format on save
  require "lsp-format".on_attach(client)

  local opts = { noremap=true, silent=true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n',    'gd',           '<cmd>lua vim.lsp.buf.definition()<CR>',       opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n',    'gD',           '<cmd>lua vim.lsp.buf.declaration()<CR>',      opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n',    'gr',           '<cmd>lua vim.lsp.buf.references()<CR>',       opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n',    'gi',           '<cmd>lua vim.lsp.buf.implementation()<CR>',   opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n',    '<leader>rn',   '<cmd>lua vim.lsp.buf.rename()<CR>',           opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n',    'K',            '<cmd>lua vim.lsp.buf.hover()<CR>',            opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n',    '<leader>.',     '<cmd>lua vim.lsp.buf.code_action()<CR>',      opts)
end

lspconfig.tsserver.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilites = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
}

lspconfig.gopls.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilites = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
}

lspconfig.jdtls.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilites = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
}

-- eslint config
local function eslint_config_exists()
  local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)

  if not vim.tbl_isempty(eslintrc) then
    return true
  end

  return false
end

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

lspconfig.efm.setup {
  on_attach = on_attach,
  root_dir = function()
    if not eslint_config_exists() then
      return nil
    end
    return vim.fn.getcwd()
  end,
  settings = {
    languages = {
      javascript = {eslint},
      javascriptreact = {eslint},
      ["javascript.jsx"] = {eslint},
      typescript = {eslint},
      ["typescript.tsx"] = {eslint},
      typescriptreact = {eslint}
    }
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact"
  },
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
}
