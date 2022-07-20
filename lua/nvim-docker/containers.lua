local popup = require('nvim-docker.popup')
local state = require('nvim-docker.popup-state')
local tree = require('nvim-docker.tree')

local NuiTree = require('nui.tree')
local Job = require('plenary.job')

local _M = {}

local function render_tree(container_data, p)
    if container_data == nil then
        return
    end
    local old_nodes = tree.tree:get_nodes()
    tree.tree.set_nodes({})
    for index, value in ipairs(container_data) do
        if value ~= nil then
            local container = vim.json.decode(value)
            local text = ''
            if string.find(container.status, 'Up') then
                text = container.name .. ' 🟢'
            else
                text = container.name .. ' 🔴'
            end

            local node = NuiTree.Node({ text = text, container = container }, {
                NuiTree.Node({ text = '[ID] ' .. container.id }),
                NuiTree.Node({ text = '[Image] ' .. container.image }),
                NuiTree.Node({ text = '[Command] ' .. container.command }),
                NuiTree.Node({ text = '[Status] ' .. container.status }),
                NuiTree.Node({ text = '[Networks] ' .. container.networks }),
                NuiTree.Node({ text = '[Ports] ' .. container.ports }),
            })
            tree.tree:add_node(node)

            -- if the node was expanded before it was cleared, expand it again
            for index, old_node in ipairs(old_nodes) do
                if old_node.container.id == node.container.id then
                    if old_node:is_expanded() then
                        node:expand()
                    end
                end
            end
        end
    end
    tree.tree:render()
end

local function get_containers(p)
    local result = Job:new({
        command = 'docker',
        args = {
            'container',
            'ls',
            '-a',
            '--format={"id": {{json .ID}}, "name": {{json .Names}}, "image": {{json .Image}}, "command": {{json .Command}}, "status": {{json .Status}}, "networks": {{json .Networks}}, "ports": {{json .Ports}}}'
        },
    }):sync()
    if result ~= nil then
        render_tree(result, p)
    end
end

function _M.list_containers()
    if state.popup == nil then
        popup.create_popup(
            'Docker Containers',
            '<l>: Expand, <L>: Expand All, <h>: Collapse, <H>: Collapse All, <u>: Container UP, <d>: Container DOWN, <q>: Quit'
        )
    end
    get_containers(state.popup)

    -- background refresh the tree every 5000ms
    state.timer:start(1000, 5000, vim.schedule_wrap(function ()
        if state.timer_stopped == false then
            local p = state.popup
            get_containers(p)
        end
    end))

end

return _M
