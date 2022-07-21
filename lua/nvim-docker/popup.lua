local popup_ok, Popup = pcall(require, 'nui.popup')
if popup_ok == false then
    vim.notify('NUI not installed, please install it from MunifTanjim/nui.nvim')
    return
end
local event = require('nui.utils.autocmd').event
local state = require('nvim-docker.popup-state')
local tree = require('nvim-docker.tree')

local _M = {}

local function create_popup(config)
    local mount
    if config.mount == nil then
        mount = true
    end
     local popup = Popup({
        enter = true,
        focusable = true,
        border = {
            style = 'rounded',
            text = {
                top = config.top_text,
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

    local function create_timer()
        local timer = vim.loop.new_timer()
        -- background refresh the tree every 5000ms
        timer:start(0, 5000, vim.schedule_wrap(config.render))
        -- unmount component when cursor leaves buffer
        popup:on(event.BufLeave, function()
            state.popup = nil
            state.tree = nil
            local function unmount()
                timer:close()
                popup:unmount()
                if state.extra_popups then
                    for _, extra_popup in ipairs(state.extra_popups) do
                        extra_popup:unmount()
                    end
                    state.extra_popups = {}
                end
            end
            pcall(unmount)
        end)
    end

    if mount == true then
        popup:mount()
        state.popup = popup
        tree.create_tree(popup, config, state)
        create_timer()
    else
        return {
            popup = popup,
            create_timer = create_timer,
            create_tree = tree.create_tree
        }
    end
end

_M.create_popup = create_popup

return _M
