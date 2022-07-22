local docker = require('nvim-docker.utils').docker

local _M = {}

function _M.follow_logs(container_name)
  return docker({'logs', container_name}):sync()
end

return _M
