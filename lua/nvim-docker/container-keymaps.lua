local state = require('nvim-docker.popup-state')
local Job = require('plenary.job')
local _M = {}

-- brings the container associated with the current tree node UP
local function container_up()
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Starting container: ' .. node.container.name)
    Job:new({
        command = 'docker',
        args = {
            'container',
            'start',
            node.container.id
        },
    }):start()
  end
end

-- brings the container associated with the current tree node DOWN
local function container_down()
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Stopping container: ' .. node.container.name)
    Job:new({
      command = 'docker',
      args = {
        'container',
        'stop',
        node.container.id
      },
    }):start()
  end
end

_M.extra_keymaps = {
    {'n', 'u', container_up, 'Start the highlighted container'},
    {'n', 'd', container_down, 'Stop the highlighted container'},
}

return _M
