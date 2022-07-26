local Job = require('plenary.job')

local function docker(args)
  return Job:new({
    command = 'docker',
    args = args,
  })
end

return docker
