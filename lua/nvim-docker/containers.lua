local popup = require('nvim-docker.popup')
local state = require('nvim-docker.popup-state')
local tree = require('nvim-docker.tree')

local NuiTree = require('nui.tree')
local Job = require('plenary.job')

local _M = {}

local popup_top_text = 'Docker Containers'
local popup_bottom_text = '<l>: Expand, <L>: Expand All, <h>: Collapse, <H>: Collapse All, <u>: Container UP, <d>: Container DOWN, <q>: Quit'

local function render_containers(containers)
    local function render(p)
        local old_nodes = state.tree:get_nodes()
        tree.create_tree(p)
        for index, container in ipairs(containers) do
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
            state.tree:add_node(node)

            -- if the node was expanded before it was cleared, expand it again
            for index, old_node in ipairs(old_nodes) do
                if old_node.container.id == node.container.id then
                    if old_node:is_expanded() then
                        node:expand()
                    end
                end
            end
        end
        state.tree:render()
    end

    if state.popup == nil then
        popup.create_popup(popup_top_text, popup_bottom_text, function (p)
            render(p)
        end)
    else
        render(state.popup)
    end
end

local function get_containers()
    local containers = {}
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
        for index, value in ipairs(result) do
            if value ~= nil then
                local container = vim.json.decode(value)
                table.insert(containers, container)
            end
        end
    end
    return containers
end

function _M.list_containers()
    if state.popup == nil then
        popup.create_popup(popup_top_text, popup_bottom_text, function ()
            local containers = get_containers()
            render_containers(containers)
        end)
    end

    -- background refresh the tree every 5000ms
    state.timer:start(5000, 5000, vim.schedule_wrap(function ()
        if state.timer_stopped == false then
            local containers = get_containers()
            render_containers(containers)
        end
    end))
end

return _M
