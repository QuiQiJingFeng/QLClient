local UITableViewCell = class("UITableViewCell")

function UITableViewCell:extend(node,tableView)
    local peer = tolua.getpeer(node)
    if not peer then
        peer = {}
        tolua.setpeer(node, peer)
    end
    setmetatable(peer, self)
    node:setTableView(tableView)
    node:init()
    return node	
end

function UITableViewCell:init()

end

function UITableViewCell:setTableView(tableView)
    self._tableView = tableView
end

function UITableViewCell:getData()
    return self._data
end

function UITableViewCell:setData(data)
    self._data = data
    self:updateData(data)
end

function UITableViewCell:updateData(data)
end

function UITableViewCell:setIdx(idx)
    self._idx = idx
end

function UITableViewCell:getIdx()
    return self._idx
end

function UITableViewCell:getTableView()
    return self._tableView
end

function UITableViewCell:setSelectState(boolean)
    self:setBright(boolean)
end



return UITableViewCell