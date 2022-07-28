local extra_keymaps = require('nvim-docker.container-keymaps').extra_keymaps
local ContainerLayout = require('nvim-docker.container-layout')
local _M = {}

function _M.list_containers()
    local layout = ContainerLayout({}, extra_keymaps)
    layout:show_containers()
end

return _M
