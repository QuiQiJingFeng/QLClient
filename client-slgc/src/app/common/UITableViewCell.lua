local UITableViewCell = class("UITableViewCell")
--这里用双冒号是为了将继承的子类传递过来,而不是是用UITableViewCell这个基类
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
    return self:updateData(data)
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

--设置偏移 UITableViewEx2 的Item 用
function UITableViewCell:setDiffDelt(pos)
    self._diffDelt = pos
end

function UITableViewCell:getDiffDelt()
    return self._diffDelt or cc.p(0,0)
end

function UITableViewCell:setCellType(type)
    self._type = type
end

function UITableViewCell:getCellType()
    return self._type
end



return UITableViewCell