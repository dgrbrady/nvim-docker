-- local NuiTree = require('nui.tree')
local Popup = require('nui.popup')

-- local popup = require('nvim-docker.popup')
-- local state = require('nvim-docker.popup-state')
-- local tree = require('nvim-docker.tree')
local extra_keymaps = require('nvim-docker.container-keymaps').extra_keymaps
local utils = require('nvim-docker.utils')
local ContainerLayout = require('nvim-docker.container-layout')
local _M = {}

_M.popup_top_text = 'Docker Containers'

function _M.get_containers()
    local containers = {}
    local result = utils.docker({
        'container',
        'ls',
        '-a',
        '--format={"id": {{json .ID}}, "name": {{json .Names}}, "image": {{json .Image}}, "command": {{json .Command}}, "status": {{json .Status}}, "networks": {{json .Networks}}, "ports": {{json .Ports}}}'
    }):sync()

    if result ~= nil then
        for _, value in ipairs(result) do
            if value ~= nil then
                local container = vim.json.decode(value)
                table.insert(containers, container)
            end
        end
    end
    return containers
end

-- function _M.render_containers(containers)
--     -- local function render(p)
--     local old_nodes = state.tree:get_nodes()
--     -- tree.create_tree(p, {
--     --     top_text = _M.popup_top_text,
--     --     extra_keymaps = extra_keymaps,
--     --     -- render = function (pop) render(pop) end
--     -- })
--     for _, container in ipairs(containers) do
--         local text = ''
--         if string.find(container.status, 'Up') then
--             text = container.name .. ' 🟢'
--         else
--             text = container.name .. ' 🔴'
--         end
--
--         local node = NuiTree.Node({ text = text, container = container }, {
--             NuiTree.Node({ text = '[ID] ' .. container.id }),
--             NuiTree.Node({ text = '[Image] ' .. container.image }),
--             NuiTree.Node({ text = '[Command] ' .. container.command }),
--             NuiTree.Node({ text = '[Status] ' .. container.status }),
--             NuiTree.Node({ text = '[Networks] ' .. container.networks }),
--             NuiTree.Node({ text = '[Ports] ' .. container.ports }),
--         })
--         state.tree:add_node(node)
--         if next(old_nodes) ~= nil then
--             for _, old_node in ipairs(old_nodes) do
--                 -- if the node was expanded before it was cleared, expand it again
--                 if old_node.container.id == node.container.id then
--                     if old_node:is_expanded() then
--                         node:expand()
--                     end
--                 end
--             end
--         end
--     end
--     state.tree:render()
--     -- end
--     --
--     -- if state.popup == nil then
--     --     popup.create_popup({
--     --         top_text = _M.popup_top_text,
--     --         extra_keymaps = extra_keymaps,
--     --         render = function (p) render(p) end
--     --     })
--     -- else
--         -- render(state.popup)
--     -- end
-- end

function _M.list_containers()
    local popup = Popup({
        enter = true,
        focusable = true,
        border = {
            style = 'rounded',
            text = {
                top = _M.popup_top_text,
                top_align = 'center',
                bottom = '<l>: Expand, <L>: Expand All, <h>: Collapse, <H>: Collapse All'
            },
        },
        position = '50%',
        size = {
            width = '80%',
            height = '60%',
        },
    })

    local containers = _M.get_containers()
    local layout = ContainerLayout({}, extra_keymaps)
    layout:show_containers(containers)
    -- if state.popup == nil then
    --     popup.create_popup({
    --         top_text = _M.popup_top_text,
    --         extra_keymaps = extra_keymaps,
    --         render = function ()
    --             tree.remove_nodes()
    --             local containers = _M.get_containers()
    --             _M.render_containers(containers)
    --         end
    --     })
    -- end
end

return _M
