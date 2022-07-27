local Layout = require('nui.layout')
local Tree = require('nui.tree')
local Popup = require('nui.popup')
local event = require('nui.utils.autocmd').event
local rx = require('reactivex')

local popup_keymaps = require('nvim-docker.popup-keymaps')
local tree_utils = require('nvim-docker.tree-utils')
local ContainerLayout = Layout:extend('ContainerLayout')
local docker = require('nvim-docker.docker')

---Component used to for managing containers
---@param layout_options table https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/layout#options
function ContainerLayout:init(layout_options, keymaps)
  self.mounted = false
  self.keymaps = keymaps
  self._containers = rx.Subject.create()
  local options = vim.tbl_deep_extend('force', layout_options or {}, {
    position = '50%',
    relative = 'editor',
    size = {
      height = '70%',
      width = '50%'
    }
  })

  self:_create_main_popup()
  self:_create_log_popup()
  ContainerLayout.super.init(self, options, Layout.Box({
    Layout.Box(self.main_popup, {size='50%'}),
    Layout.Box(self.log_popup, {size='50%'}),
  }, {dir = 'col'}))
end

function ContainerLayout:_setup_main_popup_on_bufleave()
   self.main_popup:on(event.BufLeave, function()
    local container_logs = require('nvim-docker.container-logs')
    container_logs.teardown()
    self.main_popup:unmount()
    local function close_timer()
      self.main_popup_timer:close()
    end
    pcall(close_timer)
    self:unmount()
  end)
end

function ContainerLayout:_create_main_popup()
  self.main_popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = 'rounded',
      text = {
        top = 'Docker Containers',
        top_align = 'center',
        bottom = '<l>: Expand, <L>: Expand All, <h>: Collapse, <H>: Collapse All'
      },
    },
  })
end

function ContainerLayout:_create_log_popup()
  self.log_popup = Popup({
    border = {
      text = {
        top = 'Logs',
        top_align = 'center',
      },
      style = 'double'
    }
  })
end

function ContainerLayout:get_containers()
    docker({
        'container',
        'ls',
        '-a',
        '--format={"id": {{json .ID}}, "name": {{json .Names}}, "image": {{json .Image}}, "command": {{json .Command}}, "status": {{json .Status}}, "networks": {{json .Networks}}, "ports": {{json .Ports}}}'
    }, {
      on_exit = function (j)
        local result = j:result()
        if result ~= nil then
          local containers = {}
          for _, value in ipairs(result) do
            if value ~= nil then
              local container = vim.json.decode(value)
              table.insert(containers, container)
            end
          end
          self._containers(containers)
        end
      end
    }):start()
    return self._containers
end

function ContainerLayout:_render_containers(containers)
    local old_nodes = self.tree:get_nodes()
    tree_utils.remove_nodes(self.tree)
    for _, container in ipairs(containers) do
      local text = ''
      if string.find(container.status, 'Up') then
        text = container.name .. ' 🟢'
      else
        text = container.name .. ' 🔴'
      end

      local node = Tree.Node({ text = text, container = container }, {
        Tree.Node({ text = '[ID] ' .. container.id }),
        Tree.Node({ text = '[Image] ' .. container.image }),
        Tree.Node({ text = '[Command] ' .. container.command }),
        Tree.Node({ text = '[Status] ' .. container.status }),
        Tree.Node({ text = '[Networks] ' .. container.networks }),
        Tree.Node({ text = '[Ports] ' .. container.ports }),
      })
      self.tree:add_node(node)
      if next(old_nodes) ~= nil then
        for _, old_node in ipairs(old_nodes) do
          -- if the node was expanded before it was cleared, expand it again
          if old_node.container.id == node.container.id then
            if old_node:is_expanded() then
              node:expand()
            end
          end
        end
      end
    end
    vim.schedule(function ()
      self.tree:render()
    end)
end

function ContainerLayout:show_containers()
  if self.mounted == false then
    self:mount()
    self.tree = Tree({ winid = self.main_popup.winid})
    popup_keymaps.create_keymaps(self.main_popup, self.keymaps, self.tree, self)
    self:_setup_main_popup_on_bufleave()
    self.mounted = true
  end
  self.main_popup_timer = vim.loop.new_timer()
  self.main_popup_timer:start(0, 5000, vim.schedule_wrap(function ()
    self:get_containers():subscribe(vim.schedule_wrap(function (containers)
      self:_render_containers(containers)
    end))
  end))
end

return ContainerLayout
