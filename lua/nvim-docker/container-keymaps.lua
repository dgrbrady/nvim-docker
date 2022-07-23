local Layout = require('nui.layout')
local Popup = require('nui.popup')

local state = require('nvim-docker.popup-state')
local utils = require('nvim-docker.utils')
local create_popup = require('nvim-docker.popup').create_popup
local container_logs = require('nvim-docker.container-logs')

local _M = {}

-- starts the container associated with the current tree node
local function start_container()
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Starting container: ' .. node.container.name)
    utils.docker({'container', 'start', node.container.id}):start()
  end
end

-- stops the container associated with the current tree node
local function stop_container()
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Stopping container: ' .. node.container.name)
    utils.docker({'container', 'stop', node.container.id}):start()
  end
end

-- restarts the container associated with the current tree node
local function restart_container()
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Restarting container: ' .. node.container.name)
    utils.docker({'container', 'restart', node.container.id}):start()
  end
end

-- deletes the container associated with the current tree node
local function delete_container()
  local node, _ = state.tree:get_node()
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

-- TODO finish implementation
-- view logs of the container associated with the current tree node
local function view_logs(popup_config)
  local node, _ = state.tree:get_node()
  if node ~= nil and node.container ~= nil then
    local container_lib = require('nvim-docker.containers')
    local create_layout = require('nvim-docker.layout').create_layout
    state.popup:unmount()

    local main_popup = create_popup({
      mount = false,
      top_text = container_lib.popup_top_text,
      extra_keymaps = {
        {'n', 'u', start_container, 'Start the highlighted container'},
        {'n', 'd', stop_container, 'Stop the highlighted container'},
        {'n', 'r', restart_container, 'Restart the highlighted container'},
        {'n', 'dd', delete_container, 'Delete the highlighted container'},
        {'n', 't', view_logs, 'View container logs'},
      },
      render = function ()
        local containers = container_lib.get_containers()
        container_lib.render_containers(containers)
      end
    })
    state.popup = main_popup.popup

    local log_popup = Popup({
      border = {
        text = {
          top = node.container.name .. 'Logs',
          top_align = 'center',
        },
        style = 'double'
      },
    })

    table.insert(state.extra_popups, log_popup)
    local main_box = Layout.Box(state.popup, {size = '30%'})
    local other_boxes = {
      Layout.Box(log_popup, {size = '70%'})
    }

    create_layout(main_box, other_boxes, 'col')
    main_popup.create_timer()
    main_popup.create_tree(main_popup.popup, popup_config, state)

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
