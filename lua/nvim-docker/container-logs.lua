local rx = require('reactivex')
local docker = require('nvim-docker.docker')

local _M = {
  _timer = nil,
  _logs_subscription = nil
}

local function reset_timer()
  if _M._timer ~= nil then
    _M._timer:close()
    _M._timer = nil
  end
end

local function reset_logs_subscription()
  if _M._logs_subscription ~= nil then
    _M._logs_subscription:unsubscribe()
    _M._logs_subscription = nil
  end
end

function _M.teardown()
  reset_timer()
  reset_logs_subscription()
end

function _M.follow_logs(container_name, cb)
  _M.teardown()
  local logs_stream = rx.Subject.create()
  _M._logs_subscription = logs_stream:subscribe(function (logs)
    cb(logs)
  end)
  _M._timer = vim.loop.new_timer()
  _M._timer:start(0, 5000, vim.schedule_wrap(function ()
    -- FORMAT: yyyy-mm-ddThh:mm:ssZ
    local start_from = os.date('%Y-%m-%dT%H:%M:%SZ')
    print('container_name: ' .. container_name .. 'time: ' .. start_from)
    local logs = docker({'logs', container_name, '--since', start_from}):sync()
    logs_stream(logs)
  end))
end

return _M
