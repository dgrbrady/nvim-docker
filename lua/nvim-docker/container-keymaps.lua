local state = require('nvim-docker.popup-state')
local Job = require('plenary.job')
local utils = require('nvim-docker.utils')

local _M = {}

-- starts the container associated with the current tree node
local function start_container()
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Starting container: ' .. node.container.name)
    utils.docker({'container', 'start', node.container.id})
  end
end

-- stops the container associated with the current tree node
local function stop_container()
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Stopping container: ' .. node.container.name)
    utils.docker({'container', 'stop', node.container.id})
  end
end

-- restarts the container associated with the current tree node
local function restart_container()
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Restarting container: ' .. node.container.name)
    utils.docker({'container', 'restart', node.container.id})
  end
end

_M.extra_keymaps = {
    {'n', 'u', start_container, 'Start the highlighted container'},
    {'n', 'd', stop_container, 'Stop the highlighted container'},
    {'n', 'r', restart_container, 'Restart the highlighted container'},
}

return _M
