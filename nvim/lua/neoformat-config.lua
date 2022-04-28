
vim.cmd([[
	augroup fmt
		autocmd!
		autocmd BufWritePre * undojoin | Neoformat
	augroup END

	let g:neoformat_enabled_python = ['yapf']
]])
