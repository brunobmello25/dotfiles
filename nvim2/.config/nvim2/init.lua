vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

-------------------------------------------
-------------- BASIC KEYMAPS --------------
-------------------------------------------

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Go to previous [E]rror message' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Go to next [E]rror message' })

-- quickfix navigation
vim.keymap.set('n', '[q', '<cmd>cprevious<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', ']q', '<cmd>cnext<CR>', { desc = 'Next quickfix item' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- yank to system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to clipboard' })

-- run tmux sessionizer
vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>', { desc = 'Sessionizer' })

-- exit with leader q
-- TODO: unify these two in a single keymap
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>Q', '<cmd>tabclose<CR>', { desc = 'Close tab' })

vim.keymap.set("n", "<leader>m", "'")


-------------------------------------------
--- LOAD PROJECT-SPECIFIC CONFIGURATION ---
-------------------------------------------
local function load_project_config()
	local cwd = vim.fn.getcwd()
	local project_config_path = cwd .. "/.nvimrc/init.lua"

	if vim.fn.filereadable(project_config_path) == 1 then
		local success, err = pcall(dofile, project_config_path)
		if not success then
			vim.notify("Error loading project config: " .. err, vim.log.levels.ERROR)
		end
	end
end

vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Load project-specific configuration",
	callback = load_project_config,
})

vim.api.nvim_create_autocmd("DirChanged", {
	desc = "Load project-specific configuration when changing directories",
	callback = load_project_config,
})
