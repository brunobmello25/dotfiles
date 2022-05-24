vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }

vim.cmd([[
  augroup qs_colors
    autocmd!
    autocmd ColorScheme * highlight QuickScopePrimary guifg='#33ff00' gui=underline ctermfg=155 cterm=underline
    autocmd ColorScheme * highlight QuickScopeSecondary guifg='#ff00f7' gui=underline ctermfg=81 cterm=underline
  augroup END
]])
