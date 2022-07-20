local NuiTree = require('nui.tree')
local keymaps = require('popup-keymaps')
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
  local expanded = _M.get_expanded_nodes(tree)
  for _, expanded_node in ipairs(expanded) do
    local id = expanded_node:get_id()
    local node = tree:get_node(id)
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
    -- local node = tree:get_node(id)
    node:expand(id)
  end
  tree:render()
  -- If you want to expand the root
  -- local root = tree:get_nodes()[1]
  -- root:expand()
end

function _M.create_tree(popup)
    local tree = NuiTree({ winid = popup.winid })
    keymaps.create_keymaps(popup, tree)
end

return _M
