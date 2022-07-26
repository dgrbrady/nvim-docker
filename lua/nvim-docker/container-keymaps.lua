local event = require('nui.utils.autocmd').event
local utils = require('nvim-docker.utils')
local container_logs = require('nvim-docker.container-logs')

local _M = {}

-- starts the container associated with the current tree node
local function start_container(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Starting container: ' .. node.container.name)
    utils.docker({'container', 'start', node.container.id}):start()
  end
end

-- stops the container associated with the current tree node
local function stop_container(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Stopping container: ' .. node.container.name)
    utils.docker({'container', 'stop', node.container.id}):start()
  end
end

-- restarts the container associated with the current tree node
local function restart_container(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Restarting container: ' .. node.container.name)
    utils.docker({'container', 'restart', node.container.id}):start()
  end
end

-- deletes the container associated with the current tree node
local function delete_container(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.ui.select({'Yes', 'No'},{
      prompt = 'Delete ' .. node.container.name .. '[y/n]?',
    }, function (choice)
      if choice == 'Yes' then
        vim.notify('Deleting container: ' .. node.container.name)
        utils.docker({'container', 'rm', node.container.id}):start()
      end
    end)
  end
end

-- view logs of the container associated with the current tree node
local function view_logs(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
      local layout = params.layout

    vim.keymap.set('n', '<Tab>', function ()
      layout.main_popup:off(event.BufLeave)
      vim.api.nvim_set_current_win(layout.log_popup.winid)
    end, {buffer = layout.main_popup.bufnr})

    vim.keymap.set('n', '<S-Tab>', function ()
      vim.api.nvim_set_current_win(layout.main_popup.winid)
      layout:_setup_main_popup_on_bufleave()
    end, {buffer = layout.log_popup.bufnr})

    local log_popup = params.layout.log_popup
    container_logs.follow_logs(node.container.name, function (logs)
      if log_popup.bufnr ~= nil then
        for index, log in ipairs(logs) do
          vim.api.nvim_buf_set_lines(log_popup.bufnr, index, index + 1, false, {log})
        end
      end
    end)
  end
end

_M.extra_keymaps = {
    {'n', 'u', start_container, 'Start the highlighted container'},
    {'n', 'd', stop_container, 'Stop the highlighted container'},
    {'n', 'r', restart_container, 'Restart the highlighted container'},
    {'n', 'dd', delete_container, 'Delete the highlighted container'},
    {'n', 't', view_logs, 'View container logs'},
}

return _M
