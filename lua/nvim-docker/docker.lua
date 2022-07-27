local Job = require('plenary.job')

local function docker(args, options)
  local job_options = vim.tbl_deep_extend('force', options or {}, {
    command = 'docker',
    args = args
  })
  return Job:new(job_options)
end

return docker
