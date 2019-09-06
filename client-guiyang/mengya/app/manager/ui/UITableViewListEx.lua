local super = app.UITableViewEx
--忽略重用Cell，只当ListView用  --支持多行多列
--[[
    某些情况下可能需要这样做,比如头像商城
    如果在刷新数据的时候动态创建csb(头像动画)就会显得比较卡
    这种时候一次创建完所有的就比较合适了
]]
local UITableViewListEx = class("UITableViewListEx",super)

function UITableViewListEx:update(dt)
end

function UITableViewListEx:checkRemoveCell()
end

function UITableViewListEx:isInRectView(idx)
    return true
end
 

return UITableViewListEx