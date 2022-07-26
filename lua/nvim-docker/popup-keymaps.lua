local _M = {}

-- local help_popup = Popup({
--     enter = true,
--     focusable = true,
--     border = {
--         style = 'rounded',
--         text = {
--             top = 'Help',
--             top_align = 'center',
--         },
--     },
--     position = '50%',
--     size = {
--         width = '40%',
--         height = '60%',
--     },
-- })

function _M.create_keymaps(popup, extra_keymaps, tree, layout)
    local tree_utils = require('nvim-docker.tree')
    local map_options = { remap = false, nowait = true }

    -- help_popup:map('n', '?', function ()
    --     help_popup:unmount()
    --     popup:update_layout({
    --         position = '50%',
    --         size = {
    --             width = '80%',
    --             height = '60%',
    --         },
    --     })
    --     popup:on(event.BufLeave, function()
    --         state.popup = nil
    --         state.tree = nil
    --         local function unmount()
    --             state.popup_timer:close()
    --             popup:unmount()
    --         end
    --         pcall(unmount)
    --     end)
    -- end)

    -- popup:map('n', '?', function ()
    --     -- if help_opened == nil then
    --         popup:off(event.BufLeave)
    --         popup:update_layout({
    --             size = {
    --                 width = '30%',
    --                 height = '60%'
    --             },
    --             position = {
    --                 row = '50%',
    --                 col = '0%'
    --             }
    --         })
    --         help_popup:mount()
    --         if config.extra_keymaps ~= nil then
    --             for index, keymap in ipairs(config.extra_keymaps) do
    --                 vim.api.nvim_buf_set_lines(help_popup.bufnr, index, index + 1, false, {'[Key]: ' .. keymap[2] .. '      ' .. keymap[4]})
    --             end
    --         end
    -- end)


    -- collapse
    popup:map('n', 'h', function()
        local node, linenr = tree:get_node()
        if not node:has_children() then
            node, linenr = tree:get_node(node:get_parent_id())
        end
        if node and node:collapse() then
            vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
            tree:render()
        end
    end, map_options)

    -- collapse all
    popup:map('n', 'H', function ()
        tree_utils.collapse_all_nodes(tree)
    end, map_options)

    -- expand
    popup:map("n", "l", function()
        local node, linenr = tree:get_node()
        if not node:has_children() then
            node, linenr = tree:get_node(node:get_parent_id())
        end
        if node and node:expand() then
            if not node.checked then
                node.checked = true
            end

            vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
            tree:render()
        end
    end, map_options)

    -- expand all
    popup:map('n', 'L', function ()
        tree_utils.expand_all_nodes(tree)
    end, map_options)

    if extra_keymaps ~= nil then
        for _, keymap in ipairs(extra_keymaps) do
            popup:map(
                keymap[1],
                keymap[2],
                function () keymap[3]({popup = popup, tree = tree, layout = layout}) end,
                map_options
            )
        end
    end
end

return _M
