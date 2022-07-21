local Job = require('plenary.job')
local _M = {}

function _M.docker(args)
  return Job:new({
    command = 'docker',
    args = args,
  })
end

return _M
