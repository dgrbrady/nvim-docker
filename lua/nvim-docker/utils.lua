local Job = require('plenary.job')
local _M = {}

function _M.docker(args)
  Job:new({
    command = 'docker',
    args = args,
  }):start()
end

return _M
