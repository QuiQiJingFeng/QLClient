--[[
    积分类控件
    UILeagueScoreItem：联盟积分
    UILeagueFireItem:联盟活跃度
    UIClubScoreItem:俱乐部积分
    UIClubFireItem:俱乐部活跃度
]]
local csbPath = "ui/csb/BigLeague/UIBigLeagueMyScore.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueMyScore:UIBase
local UIBigLeagueMyScore = super.buildUIClass("UIBigLeagueMyScore", csbPath)
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local typeStr ={
    "盟主调整","调整玩家分数","管理调整","牌局输赢","抽奖消耗","每日赛事重置","获得活跃值","活跃值兑换","团队退出返还","搭档退出返还","分数转换"
}

--联盟积分变化
local UILeagueScoreItem = class("UILeagueScoreItem")

function UILeagueScoreItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UILeagueScoreItem)
    self:_initialize()
    return self
end

function UILeagueScoreItem:_initialize()
end

function UILeagueScoreItem:setData(info)
    local item = self
    item:getChildByName("Text_Day"):setString(kod.util.Time.dateWithFormat("%Y-%m-%d", info.time/1000))   --联盟名
    item:getChildByName("Text_Time"):setString(kod.util.Time.dateWithFormat("%H:%M", info.time/1000))                  --排名
    item:getChildByName("Text_Type"):setString(typeStr[info.type])     --类型
  
    if info.name == "" then
        item:getChildByName("Text_Name"):setString("/") 
        item:getChildByName("Text_Id"):setString("") 
    else
        item:getChildByName("Text_Name"):setString(getInterceptString(info.name)) 
        item:getChildByName("Text_Id"):setString(info.id)                  --id
    end

    info.score = math.round(info.score * 100) / 100

    local str = info.score > 0 and "+"..info.score or ""..info.score
    item:getChildByName("Text_Score"):setString(str)       --积分变化
    item:getChildByName("Text_LeftScore"):setString(math.round(info.afterScore * 100) / 100)       --剩余分
    item:getChildByName("Text_LeagueScore"):setString(math.round(info.remainScore * 100) / 100)       --剩余分
end

--联盟活跃变化
local UILeagueFireItem = class("UILeagueFireItem")

function UILeagueFireItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UILeagueFireItem)
    self:_initialize()
    return self
end

function UILeagueFireItem:_initialize()
end

function UILeagueFireItem:setData(info)
    local item = self
    item:getChildByName("Text_Day"):setString(kod.util.Time.dateWithFormat("%Y-%m-%d", info.time/1000))   --联盟名
    item:getChildByName("Text_Time"):setString(kod.util.Time.dateWithFormat("%H:%M", info.time/1000))                  --排名
    item:getChildByName("Text_Type"):setString(typeStr[info.type])     --类型
    info.score = math.round(info.score * 100) / 100
    local str = info.score > 0 and "+"..info.score or ""..info.score
    item:getChildByName("Text_Score"):setString(str)       --积分变化
    item:getChildByName("Text_LeftScore"):setString(math.round(info.afterScore * 100) / 100)       --剩余分

    --local clubInfo = "/"
    --if info.id ~= 0 then
    --    clubInfo = string.format("%s\n%s", getInterceptString(info.name), info.id)
    --end
    --item:getChildByName("Text_ClubInfo"):setString(clubInfo)

    item:getChildByName("Button_Record"):setVisible(info.roomId ~= 0)
    bindEventCallBack(item:getChildByName("Button_Record"), function ()
        UIManager:getInstance():show("UIBigLeagueHistory", 0, info.roomId, info.time / 1000)
    end , ccui.TouchEventType.ended)
end




--俱乐部活跃度变化
local UIClubFireItem = class("UIClubFireItem")

function UIClubFireItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIClubFireItem)
    self:_initialize()
    return self
end

function UIClubFireItem:_initialize()
end

function UIClubFireItem:setData(info)
    local item = self
    item:getChildByName("Text_Day"):setString(kod.util.Time.dateWithFormat("%Y-%m-%d", info.time/1000))   --联盟名
    item:getChildByName("Text_Time"):setString(kod.util.Time.dateWithFormat("%H:%M", info.time/1000))                  --排名
    item:getChildByName("Text_Type"):setString(typeStr[info.type])     --类型
    info.score = math.round(info.score * 100) / 100
    local str = info.score > 0 and "+"..info.score or ""..info.score
    item:getChildByName("Text_Score"):setString(str)       --积分变化
    item:getChildByName("Text_LeftScore"):setString(math.round(info.afterScore * 100) / 100)       --剩余分

    local clubInfo = "/"
    if info.id ~= 0 then
        clubInfo = string.format("%s\n%s", getInterceptString(info.name), info.id)
    end
    item:getChildByName("Text_ClubInfo"):setString(clubInfo)

    item:getChildByName("Button_Record"):setVisible(info.roomId ~= 0)
    bindEventCallBack(item:getChildByName("Button_Record"), function ()
        UIManager:getInstance():show("UIBigLeagueHistory", 0, info.roomId, info.time / 1000)
    end , ccui.TouchEventType.ended)
end


--俱乐部积分变化
local UIClubScoreItem = class("UIClubScoreItem")

function UIClubScoreItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIClubScoreItem)
    self:_initialize()
    return self
end

function UIClubScoreItem:_initialize()
end

function UIClubScoreItem:setData(info)
    local item = self
    item:getChildByName("Text_Day"):setString(kod.util.Time.dateWithFormat("%Y-%m-%d", info.time/1000))   --联盟名
    item:getChildByName("Text_Time"):setString(kod.util.Time.dateWithFormat("%H:%M", info.time/1000))                  --排名
    
    if info.name == "" then
        item:getChildByName("Text_Name"):setString("/") 
        item:getChildByName("Text_Id"):setString("") 
    else
        item:getChildByName("Text_Name"):setString(getInterceptString(info.name)) 
        item:getChildByName("Text_Id"):setString(info.id)                  --id
    end
    
    item:getChildByName("Text_Type"):setString(typeStr[info.type])     --类型
    info.score = math.round(info.score * 100) / 100
    local str = info.score > 0 and "+"..info.score or ""..info.score
    item:getChildByName("Text_Score"):setString(str)       --积分变化
    item:getChildByName("Text_LeftScore"):setString(math.round(info.afterScore * 100) / 100)       --剩余分
end



--我的积分
local UIMyScoreItem = class("UIMyScoreItem")

function UIMyScoreItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIMyScoreItem)
    self:_initialize()
    return self
end

function UIMyScoreItem:_initialize()
end

function UIMyScoreItem:setData(info)
    local item = self
    item:getChildByName("Text_Day"):setString(kod.util.Time.dateWithFormat("%Y.%m.%d", info.time/1000))   --日期
    item:getChildByName("Text_Time"):setString(kod.util.Time.dateWithFormat("%H:%M", info.time/1000))                  --时间
    item:getChildByName("Text_Name"):setString(getInterceptString(info.name))   --名称
    item:getChildByName("Text_Type"):setString(typeStr[info.type])     --类型
    local str = info.score > 0 and "+"..info.score or ""..info.score
    item:getChildByName("Text_Score"):setString(str)       --积分变化
    item:getChildByName("Text_LeftScore"):setString(info.afterScore)       --剩余分
    if info.type == 4 then
        item:getChildByName("Text_RoomId"):setString(info.roomId)
    else
        item:getChildByName("Text_RoomId"):setString("/")
        item:getChildByName("Text_Name"):setString("/")
    end
end
return {UILeagueScoreItem, UILeagueFireItem, UIClubScoreItem, UIClubFireItem, UIMyScoreItem}