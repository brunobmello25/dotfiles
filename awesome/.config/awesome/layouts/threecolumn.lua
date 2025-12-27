-- Three column layout for ultrawide monitors
local awful = require("awful")

local threecolumn = {}

threecolumn.name = "threecolumn"

local function get_column_data(t)
  local data = awful.tag.getdata(t)
  if not data.threecolumn then
    data.threecolumn = {
      left_factor = 0.25,
      right_factor = 0.25,
      last_mwfact = t.master_width_factor
    }
  end
  return data.threecolumn
end

local function get_focused_column(clients, area, col_data)
  local c = client.focus
  if not c then return nil end
  
  local dominated_clients = {}
  for _, cl in ipairs(clients) do
    dominated_clients[cl] = true
  end
  if not dominated_clients[c] then return nil end
  
  local g = c:geometry()
  local center_x = g.x + g.width / 2
  
  local left_width = area.width * col_data.left_factor
  local right_width = area.width * col_data.right_factor
  
  if center_x < area.x + left_width then
    return "left"
  elseif center_x > area.x + area.width - right_width then
    return "right"
  else
    return "middle"
  end
end

function threecolumn.arrange(p)
  local area = p.workarea
  local t = p.tag or screen[p.screen].selected_tag
  local clients = p.clients
  
  if #clients == 0 then return end
  
  local col_data = get_column_data(t)
  local mwfact = t.master_width_factor
  
  -- Detect mwfact changes and apply to focused column
  if col_data.last_mwfact ~= mwfact then
    local delta = mwfact - col_data.last_mwfact
    local focused_col = get_focused_column(clients, area, col_data)
    
    if focused_col == "left" then
      -- l (increase) shrinks left, h (decrease) grows left
      col_data.left_factor = math.max(0.1, math.min(0.4, col_data.left_factor + delta))
    elseif focused_col == "right" then
      -- l (increase) grows right, h (decrease) shrinks right
      col_data.right_factor = math.max(0.1, math.min(0.4, col_data.right_factor - delta))
    elseif focused_col == "middle" then
      -- l (increase) grows middle by shrinking both sides
      col_data.left_factor = math.max(0.1, math.min(0.4, col_data.left_factor - delta / 2))
      col_data.right_factor = math.max(0.1, math.min(0.4, col_data.right_factor - delta / 2))
    end
    
    col_data.last_mwfact = mwfact
  end
  
  if #clients == 1 then
    p.geometries[clients[1]] = {
      x = area.x,
      y = area.y,
      width = area.width,
      height = area.height
    }
  elseif #clients == 2 then
    local half_width = math.floor(area.width / 2)
    
    p.geometries[clients[1]] = {
      x = area.x,
      y = area.y,
      width = half_width,
      height = area.height
    }
    
    p.geometries[clients[2]] = {
      x = area.x + half_width,
      y = area.y,
      width = area.width - half_width,
      height = area.height
    }
  else
    local left_width = math.floor(area.width * col_data.left_factor)
    local right_width = math.floor(area.width * col_data.right_factor)
    local middle_width = area.width - left_width - right_width
    
    local left_clients = {}
    local middle_clients = {}
    local right_clients = {}
    
    for i, c in ipairs(clients) do
      local col = (i - 1) % 3
      if col == 0 then
        table.insert(left_clients, c)
      elseif col == 1 then
        table.insert(middle_clients, c)
      else
        table.insert(right_clients, c)
      end
    end
    
    -- Arrange left column
    local left_height = math.floor(area.height / #left_clients)
    for i, c in ipairs(left_clients) do
      local y_offset = (i - 1) * left_height
      local height = (i == #left_clients) and (area.height - y_offset) or left_height
      
      p.geometries[c] = {
        x = area.x,
        y = area.y + y_offset,
        width = left_width,
        height = height
      }
    end
    
    -- Arrange middle column
    local middle_height = math.floor(area.height / #middle_clients)
    for i, c in ipairs(middle_clients) do
      local y_offset = (i - 1) * middle_height
      local height = (i == #middle_clients) and (area.height - y_offset) or middle_height
      
      p.geometries[c] = {
        x = area.x + left_width,
        y = area.y + y_offset,
        width = middle_width,
        height = height
      }
    end
    
    -- Arrange right column
    local right_height = math.floor(area.height / #right_clients)
    for i, c in ipairs(right_clients) do
      local y_offset = (i - 1) * right_height
      local height = (i == #right_clients) and (area.height - y_offset) or right_height
      
      p.geometries[c] = {
        x = area.x + left_width + middle_width,
        y = area.y + y_offset,
        width = right_width,
        height = height
      }
    end
  end
end

return threecolumn
