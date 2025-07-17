local utils = {}

local home = os.getenv("HOME")
local debug_log_path = home .. "/.awesome_debug.log"

local function table_to_string(tbl, indent)
  indent = indent or 0
  local result = string.rep("  ", indent) .. "{\n"
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent + 1) .. tostring(k) .. " = "
    if type(v) == "table" then
      result = result .. formatting .. table_to_string(v, indent + 1)
    else
      result = result .. formatting .. tostring(v) .. ",\n"
    end
  end
  result = result .. string.rep("  ", indent) .. "},\n"
  return result
end

function utils.debug_log(message)
  local log_file = io.open(debug_log_path, "a")
  if log_file then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")

    local log_message
    if type(message) == "table" then
      log_message = table_to_string(message)
    else
      log_message = tostring(message)
    end

    log_file:write(string.format("[%s] %s\n", timestamp, log_message))
    log_file:close()
  end
end

function utils.external_connected()
  local cmd = "xrandr --query | grep -E '^(HDMI|DP|VGA)-[0-9]+ connected'"
  local ok, exit_type, code = os.execute(cmd)
  return ok or (exit_type == "exit" and code == 0)
end

function utils.read_file(path)
  local fh = io.open(path, "r")
  if not fh then
    return nil
  end
  local contents = fh:read("*all")
  fh:close()
  return (contents:gsub("^%s*(.-)%s*$", "%1"))
end

utils.debug_log_path = debug_log_path

return utils