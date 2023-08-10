local M = {}

function M.P(t)
  require('naughty').notify({ text = require('gears').debug.dump_return(t) })
end

return M
