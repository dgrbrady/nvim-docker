local _M = {}

function _M.create_keymaps(popup, tree_instance, tree_mod)
    local map_options = { remap = false, nowait = true }

    -- collapse
    popup:map('n', 'h', function()
        local node, linenr = tree_instance:get_node()
        if not node:has_children() then
            node, linenr = tree_instance:get_node(node:get_parent_id())
        end
        if node and node:collapse() then
            vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
            tree_instance:render()
        end
    end, map_options)

    -- collapse all
    popup:map('n', 'H', function ()
        tree_mod.collapse_all_nodes(tree_instance)
    end, map_options)

    -- expand
    popup:map("n", "l", function()
        local node, linenr = tree_instance:get_node()
        if not node:has_children() then
            node, linenr = tree_instance:get_node(node:get_parent_id())
        end
        if node and node:expand() then
            if not node.checked then
                node.checked = true
            end

            vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
            tree_instance:render()
        end
    end, map_options)

    -- expand all
    popup:map('n', 'L', function ()
        tree_mod.expand_all_nodes(tree_instance)
    end, map_options)

    -- popup:map('n', 'u', function ()
    --     local node = tree_instance:get_node()
    --     container_up(node)
    -- end)
    --
    -- popup:map('n', 'd', function ()
    --     local node = tree_instance:get_node()
    --     container_down(node)
    -- end)

    -- popup:map('n', 'q', function ()
    --     popup:unmount()
    -- end)
end

return _M
