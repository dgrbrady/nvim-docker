local NuiTree = require('nui.tree')
local keymaps = require('nvim-docker.popup-keymaps')
local state = require('nvim-docker.popup-state')
local _M = {}

function _M.get_expanded_nodes(tree)
  local nodes = {}

  local function process(node)
    if node:is_expanded() then
      table.insert(nodes, node)

      if node:has_children() then
        for _, child in ipairs(_M.tree:get_nodes(node:get_id())) do
          process(child)
        end
      end
    end
  end

  for _, node in ipairs(tree:get_nodes()) do
    process(node)
  end

  return nodes
end

function _M.collapse_all_nodes(tree)
  local nodes = tree:get_nodes()
  for _, node in ipairs(nodes) do
    local id = node:get_id()
    node:collapse(id)
  end
  tree:render()

  -- If you want to expand the root
  -- local root = tree:get_nodes()[1]
  -- root:expand()
end

function _M.expand_all_nodes(tree)
  local nodes = tree:get_nodes()
  for _, node in ipairs(nodes) do
    local id = node:get_id()
    node:expand(id)
  end
  tree:render()
  -- If you want to expand the root
  -- local root = tree:get_nodes()[1]
  -- root:expand()
end

function _M.remove_nodes(tree)
  local nodes = tree:get_nodes()
  if next(nodes) ~= nil then
    for _, node in ipairs(nodes) do
      if type(node.children) == 'table' and next(node.children) then
        for _, child in ipairs(node.children) do
          tree:remove_node(child:get_id())
        end
      end
      tree:remove_node(node:get_id())
    end
  end
end

function _M.create_tree(popup, config, local_state)
    local tree = NuiTree({ winid = popup.winid })
    state.tree = tree
    keymaps.create_keymaps(popup, config, local_state, tree, _M)
end

return _M
