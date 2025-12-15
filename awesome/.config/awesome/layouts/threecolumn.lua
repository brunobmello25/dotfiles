-- Three column layout for ultrawide monitors
local awful = require("awful")
local gears = require("gears")

local threecolumn = {}

threecolumn.name = "threecolumn"

function threecolumn.arrange(p)
  local area = p.workarea
  local t = p.tag or screen[p.screen].selected_tag
  local clients = p.clients
  
  if #clients == 0 then return end
  
  local master_width_factor = t.master_width_factor or 0.34
  local column_width = area.width * master_width_factor
  
  if #clients == 1 then
    -- Single client takes full width
    local g = {
      x = area.x,
      y = area.y,
      width = area.width,
      height = area.height
    }
    p.geometries[clients[1]] = g
  elseif #clients == 2 then
    -- Two clients split the screen
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
    -- Three or more clients: three column layout
    local third_width = math.floor(area.width / 3)
    
    -- Left column
    local left_clients = {}
    -- Middle column
    local middle_clients = {}
    -- Right column
    local right_clients = {}
    
    -- Distribute clients across columns
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
        width = third_width,
        height = height
      }
    end
    
    -- Arrange middle column
    local middle_height = math.floor(area.height / #middle_clients)
    for i, c in ipairs(middle_clients) do
      local y_offset = (i - 1) * middle_height
      local height = (i == #middle_clients) and (area.height - y_offset) or middle_height
      
      p.geometries[c] = {
        x = area.x + third_width,
        y = area.y + y_offset,
        width = third_width,
        height = height
      }
    end
    
    -- Arrange right column
    local right_height = math.floor(area.height / #right_clients)
    for i, c in ipairs(right_clients) do
      local y_offset = (i - 1) * right_height
      local height = (i == #right_clients) and (area.height - y_offset) or right_height
      
      p.geometries[c] = {
        x = area.x + 2 * third_width,
        y = area.y + y_offset,
        width = area.width - 2 * third_width,
        height = height
      }
    end
  end
end

return threecolumn
