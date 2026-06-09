vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

-- Suprime o ftplugin padrão do nvim que tenta iniciar treesitter
-- com o parser bundled (incompatível no 0.12.2) antes do arborist carregar
vim.g.loaded_ftplugin_lua = 1

-------------------------------------------
-------------- BASIC KEYMAPS --------------
-------------------------------------------

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
-- TODO: unify these two in a single keymap
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>tabclose<CR>", { desc = "Close tab" })

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

-----------------------------------------------------
--- PLUGINS ---
-----------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"arborist-ts/arborist.nvim",
		lazy = false, -- carrega no startup, antes de qualquer buffer
		priority = 1000,
		config = function()
			require("arborist").setup({
				auto_install = true, -- instala parser automaticamente ao abrir arquivo
			})
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			require("telescope").setup({
				pickers = {
					find_files = {
						hidden = false,
						-- Use fd if available for better performance
						find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
					},
					live_grep = {
						-- Additional args for ripgrep to search hidden files
						additional_args = function()
							return { "--hidden", "--glob", "!.git/*" }
						end,
					},
				},

				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set({ "n", "v" }, "<leader>fw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "[S]earch [C]ommands" })

			-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
			-- If you later switch picker plugins, this is where to update these mappings.
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf

					vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
					vim.keymap.set(
						"n",
						"gi",
						builtin.lsp_implementations,
						{ buffer = buf, desc = "[G]oto [I]mplementation" }
					)
					vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
					vim.keymap.set(
						"n",
						"gO",
						builtin.lsp_document_symbols,
						{ buffer = buf, desc = "Open Document Symbols" }
					)
					vim.keymap.set(
						"n",
						"gW",
						builtin.lsp_dynamic_workspace_symbols,
						{ buffer = buf, desc = "Open Workspace Symbols" }
					)
					vim.keymap.set(
						"n",
						"gT",
						builtin.lsp_type_definitions,
						{ buffer = buf, desc = "[G]oto [T]ype Definition" }
					)
				end,
			})

			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })
			vim.keymap.set("n", "<leader>f/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>fn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	{
		"cbochs/grapple.nvim",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
		},
		config = function()
			vim.keymap.set("n", "<leader>ha", require("grapple").tag)
			vim.keymap.set("n", "<leader>hh", require("grapple").toggle_tags)

			vim.keymap.set("n", "<leader>1", "<cmd>Grapple select index=1<cr>")
			vim.keymap.set("n", "<leader>2", "<cmd>Grapple select index=2<cr>")
			vim.keymap.set("n", "<leader>3", "<cmd>Grapple select index=3<cr>")
			vim.keymap.set("n", "<leader>4", "<cmd>Grapple select index=4<cr>")
			vim.keymap.set("n", "<leader>5", "<cmd>Grapple select index=5<cr>")
			vim.keymap.set("n", "<leader>6", "<cmd>Grapple select index=6<cr>")
			vim.keymap.set("n", "<leader>7", "<cmd>Grapple select index=7<cr>")
			vim.keymap.set("n", "<leader>8", "<cmd>Grapple select index=8<cr>")
			vim.keymap.set("n", "<leader>9", "<cmd>Grapple select index=9<cr>")
		end,
	},

	{
		"bluz71/vim-moonfly-colors",
		init = function()
			vim.g.moonflyWinSeparator = 2
			vim.g.moonflyTransparent = true

			vim.cmd("colorscheme moonfly")

			vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#20303b" })
			vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#37222c" })
			vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1f2231" })
			vim.api.nvim_set_hl(0, "DiffText", { bg = "#394b70" })
		end,
	},
})
