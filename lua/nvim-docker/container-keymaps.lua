local event = require('nui.utils.autocmd').event
local docker = require('nvim-docker.docker')
local container_logs = require('nvim-docker.container-logs')

local _M = {}

-- starts the container associated with the current tree node
local function start_container(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Starting container: ' .. node.container.name)
    docker({'container', 'start', node.container.id}):start()
  end
end

-- stops the container associated with the current tree node
local function stop_container(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Stopping container: ' .. node.container.name)
    docker({'container', 'stop', node.container.id}):start()
  end
end

-- restarts the container associated with the current tree node
local function restart_container(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
    vim.notify('Restarting container: ' .. node.container.name)
    docker({'container', 'restart', node.container.id}):start()
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
        docker({'container', 'rm', node.container.id}):start()
      end
    end)
  end
end

-- view logs of the container associated with the current tree node
local function view_logs(params)
  local node, _ = params.tree:get_node()
  if node ~= nil and node.container ~= nil then
    local layout = params.layout
    local log_popup = layout.log_popup
    local log_bufnr = log_popup.bufnr
    log_popup.border:set_text('top', node.container.name .. ' Logs', 'center')
    local line_count = vim.api.nvim_buf_line_count(log_bufnr)
    vim.api.nvim_buf_set_lines(log_bufnr, 0, line_count, false, {})
    local cursor_follow_logs = false


    local function toggle_cursor_follow_logs()
      cursor_follow_logs = not cursor_follow_logs
      if cursor_follow_logs == true then
        log_popup.border:set_text('bottom', '[stuck to bottom]', 'center')
      else
        log_popup.border:set_text('bottom', '')
      end
    end

    local function focus_logs()
      layout.main_popup:off(event.BufLeave)
      vim.api.nvim_set_current_win(layout.log_popup.winid)
      layout:_setup_main_popup_on_bufleave()
      vim.keymap.set('n', 't', toggle_cursor_follow_logs, {buffer = log_bufnr})
    end

    local function focus_main()
      cursor_follow_logs = false
      vim.api.nvim_set_current_win(layout.main_popup.winid)
      layout:_setup_main_popup_on_bufleave()
      vim.keymap.del('n', 't', {buffer=log_bufnr})
    end


    vim.keymap.set('n', '<Tab>', focus_logs, {buffer = layout.main_popup.bufnr})

    vim.keymap.set('n', '<S-Tab>', focus_main, {buffer = log_bufnr})

    focus_logs()

    container_logs.follow_logs(node.container.name, function (logs)
      if log_popup.bufnr ~= nil then
        for index, log in ipairs(logs) do
          vim.api.nvim_buf_set_lines(log_popup.bufnr, index, index + 1, false, {log})
        end
        vim.schedule(function ()
          if cursor_follow_logs == true then
            vim.api.nvim_win_set_cursor(log_popup.winid, {
              vim.api.nvim_buf_line_count(log_bufnr),
              0
            })
          end
        end)
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
