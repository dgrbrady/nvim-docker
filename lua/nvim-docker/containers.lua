local popup = require('nvim-docker.popup')
local state = require('nvim-docker.popup-state')
local tree = require('nvim-docker.tree')

local NuiTree = require('nui.tree')
local Job = require('plenary.job')

local _M = {}

local popup_top_text = 'Docker Containers'
local popup_bottom_text = '<l>: Expand, <L>: Expand All, <h>: Collapse, <H>: Collapse All, <u>: Container UP, <d>: Container DOWN, <q>: Quit'

local function render_tree(container_data)
    if container_data == nil then
        return
    end
    
    if state.popup == nil then
        popup.create_popup(popup_top_text, popup_bottom_text, function (p)
            local old_nodes = state.tree:get_nodes()
            print(vim.pretty_print(p))
            tree.create_tree(p.winid)
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
            end
            state.tree:render()
        end)
    end
end

local function get_containers()
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
        render_tree(result)
    end
end

function _M.list_containers()
    if state.popup == nil then
        popup.create_popup(popup_top_text, popup_bottom_text, function ()
            get_containers()
        end)
    end

    -- background refresh the tree every 5000ms
    state.timer:start(5000, 5000, vim.schedule_wrap(function ()
        if state.timer_stopped == false then
            get_containers()
        end
    end))
end

return _M
