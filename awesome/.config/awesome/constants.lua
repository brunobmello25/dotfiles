local M = {}

M.browser = "google-chrome-stable"
M.terminal = "alacritty"
M.editor = os.getenv("EDITOR") or "nvim"
M.editor_cmd = M.terminal .. " -e " .. M.editor

return M
