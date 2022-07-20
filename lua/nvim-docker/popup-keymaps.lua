local state = require('nvim-docker.popup-state')
local tree = require('nvim-docker.tree')

local _M = {}

function _M.create_keymaps()
    local map_options = { remap = false, nowait = true }

    -- collapse
    state.popup:map('n', 'h', function()
        local node, linenr = tree.tree:get_node()
        if not node:has_children() then
            node, linenr = tree.tree:get_node(node:get_parent_id())
        end
        if node and node:collapse() then
            vim.api.nvim_win_set_cursor(state.popup.winid, { linenr, 0 })
            tree.tree:render()
        end
    end, map_options)

    -- collapse all
    state.popup:map('n', 'H', function ()
        tree.collapse_all_nodes(tree.tree)
    end, map_options)

    -- expand
    state.popup:map("n", "l", function()
        local node, linenr = tree.tree:get_node()
        if not node:has_children() then
            node, linenr = tree.tree:get_node(node:get_parent_id())
        end
        if node and node:expand() then
            if not node.checked then
                node.checked = true

                -- vim.schedule(function()
                --     for _, n in ipairs(tree:get_nodes(node:get_id())) do
                --         check_query_file_health(n)
                --     end
                --     tree:render()
                -- end)
            end

            vim.api.nvim_win_set_cursor(state.popup.winid, { linenr, 0 })
            tree.tree:render()
        end
    end, map_options)

    -- expand all
    state.popup:map('n', 'L', function ()
        tree.expand_all_nodes(tree.tree)
    end, map_options)

    -- popup:map('n', 'u', function ()
    --     local node = tree.tree:get_node()
    --     container_up(node)
    -- end)
    --
    -- popup:map('n', 'd', function ()
    --     local node = tree.tree:get_node()
    --     container_down(node)
    -- end)

    state.popup:map('n', 'q', function ()
        state.popup:unmount()
    end)
end

return _M
