vim.g.mapleader = " "
vim.g.maplocalleader = " "

---------------------------------------
--- GENERAL SETTINGS
---------------------------------------

vim.opt.number = true
vim.opt.relativenumber = false

-- Make :find search recursively
vim.opt.path:append("**")

-- Optional: ignore common junk dirs
vim.opt.wildignore:append("*/node_modules/*,*/.git/*,*/target/*")
---

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
-- vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- TODO: dynamically check tabstop based on current file. Ideally we would render spaces where there are spaces and keep tabs as tabs, and render these tabs as 4 spaces.
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- prevent lines ending with ^M
vim.opt.fileformat = "unix"

-- set nowrap
vim.opt.wrap = false

vim.g.tex_flavor = "latex"

vim.opt.cursorline = true

vim.opt.swapfile = false

vim.opt.winborder = "rounded"

---------------------------------------
--- AUTOMATICALLY RELOAD FILES WHEN CHANGED EXTERNALLY
---------------------------------------

-- Automatically reload files when changed externally
vim.opt.autoread = true

-- Check for file changes when entering a buffer, gaining focus, or being idle
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	command = "checktime",
	desc = "Check for external file changes",
})

-- Notify when a file is changed outside of Neovim
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
	end,
	desc = "Notify when file is reloaded due to external changes",
})

---------------------------------------
---LOAD PROJECT CONFIG
---------------------------------------

local function load_project_config()
	local cwd = vim.fn.getcwd()
	local project_config_path = cwd .. "/.nvimrc/init.lua"

	if vim.fn.filereadable(project_config_path) == 1 then
		local success, err = pcall(dofile, project_config_path)
		if success then
			vim.notify("Loaded project config: " .. project_config_path, vim.log.levels.INFO)
		else
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

---------------------------------------
--- USEFUL COMMANDS
---------------------------------------

vim.api.nvim_create_user_command("RelativeLineNumber", function()
	local relative_enabled = vim.opt.relativenumber:get()

	if relative_enabled then
		vim.opt.relativenumber = false
	else
		vim.opt.relativenumber = true
	end
end, {})

vim.api.nvim_create_user_command("CopyRelPath", function(opts)
	local path = vim.fn.expand("%:p:.")
	if opts.range > 0 then
		path = path .. ":" .. opts.line1 .. "," .. opts.line2
	end
	vim.fn.setreg("+", path)
end, { range = true })

vim.api.nvim_create_user_command("Prompt", function(opts)
	---function to check if current window is on an empty buffer.
	---if it is, we will use the same window. if it isn't, we will
	---open a new window and type the prompt there.
	---@return boolean
	local is_window_empty = function()
		local buf = vim.api.nvim_get_current_buf()
		local line_count = vim.api.nvim_buf_line_count(buf)

		if line_count == 1 then
			local line_content = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
			return line_content == ""
		end

		return line_count == 0
	end

	local buffer = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_get_current_win()
	local split_type = "right"

	-- Check if a split type is specified
	if opts.args and (opts.args == "v" or opts.args == "h") then
		split_type = opts.args == "v" and "right" or "below"
	end

	if not is_window_empty() then
		win = vim.api.nvim_open_win(buffer, false, {
			split = split_type,
			win = 0,
		})
	end

	vim.api.nvim_set_option_value("filetype", "markdown", {
		buf = buffer,
	})

	vim.api.nvim_set_current_win(win)
	vim.api.nvim_set_current_buf(buffer)

	vim.api.nvim_buf_set_lines(buffer, 0, 0, false, {
		"```",
		"```",
	})
end, {
	nargs = "?",
	complete = function()
		return { "v", "w" }
	end,
})

---------------------------------------
--- KEYBINDINGS
---------------------------------------

------@diagnostic disable: missing-fields
-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to previous [E]rror message" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to next [E]rror message" })

-- quickfix navigation
vim.keymap.set("n", "[q", "<cmd>cprevious<CR>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })

-- run tmux sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Sessionizer" })

-- exit with leader q
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>tabclose<CR>", { desc = "Close tab" })

-- keep visual mode after moving lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- prevent yank when pasting from visual mode
vim.keymap.set("x", "p", '"_dP', { desc = "Prevent yank when pasting" })

-- toggle word wrap
vim.keymap.set("n", "<leader>tw", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })

-- keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
vim.keymap.set("n", "gg", "ggzz", { desc = "Scroll up" })
vim.keymap.set("n", "G", "Gzz", { desc = "Scroll up" })

-- reselect previous visual selection after indenting
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })

-- resource file
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- prevent { and } from polluting the jump list
vim.keymap.set(
	"n",
	"{",
	'<cmd>silent! execute "keepjumps norm! " . v:count1 . "{"<CR>',
	{ desc = "Move to previous paragraph" }
)
vim.keymap.set(
	"n",
	"}",
	'<cmd>silent! execute "keepjumps norm! " . v:count1 . "}"<CR>',
	{ desc = "Move to previous paragraph" }
)

vim.keymap.set("n", "<leader>rln", "<cmd>RelativeLineNumber<CR>", { desc = "Toggle relative line numbers" })


---------------------------------------
--- PLUGINS
---------------------------------------
