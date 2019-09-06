--[[
比赛详情奖励子页面
--]]
local csbPath = "ui/csb/Campaign/campaignUtils/elem/UIDetaileRwardElem.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local super = require("app.game.ui.UIBase")
----------------------------------------------------------------------
-- 单行item显示
----------------------------------------------------------------------
local UIElemCampaignRewardsItem = class("UIElemCampaignRewardsItem")

function UIElemCampaignRewardsItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemCampaignRewardsItem)
    self:_initialize()
    return self
end

function UIElemCampaignRewardsItem:_initialize()
    -- 实际上这条list显示的是一行有4个item，每个item在setdata的时候进行处理
    self.elem = {}
    self.elem[1] =  seekNodeByName(self, "Panel_box_Battlehelp", "ccui.Layout")
    self.elem[2] =  seekNodeByName(self, "Panel_box_Battlehelp_0", "ccui.Layout")
    self.elem[3] =  seekNodeByName(self, "Panel_box_Battlehelp_1", "ccui.Layout")
    self.elem[4] =  seekNodeByName(self, "Panel_box_Battlehelp_2", "ccui.Layout")
    self.elem[5] =  seekNodeByName(self, "Panel_box_Battlehelp_2_0", "ccui.Layout")
end

function UIElemCampaignRewardsItem:getData()
    return self._data
end

-- 整体设置数据
function UIElemCampaignRewardsItem:setData (applicationInfo)
    self._data = applicationInfo
    -- 先全部隐藏起来
    table.foreach(self.elem, function(key, val)
        val:setVisible(false)
    end)

    -- -- 将其显示出来 关联按钮事件
    for i = 1 , #applicationInfo do
        self.elem[i]:setVisible(true)
        self:setItem( self.elem[i], applicationInfo[i])
    end
end

function UIElemCampaignRewardsItem:setItem( ui, data)
    local rank = ui:getChildByName("BitmapFontLabel_px_Battlehelp")
    local txt = ui:getChildByName("BitmapFontLabel_jp_Battlehelp")

    rank:setString("第" .. data.value .. "名")
    
    txt:setString(self:generateReward(data))
end

function UIElemCampaignRewardsItem:generateReward(param)
    local result = {}
    table.foreach(param.item,function(key,value)
        local item = ""
        local units = ""
        if PropReader.getTypeById(value.id) == "RedPackage" then
            units = "元"
        end
        item = PropReader.getNameById(value.id) .. "X" ..value.count .. units
        table.insert( result, item)
    end)

    local s =""
    table.foreach(result, function (k,v)
        s = s .. v .."\n"
    end)
    return s
end
----------------------------------------------------------------------
local UIElemCampaignRewards = class("UIElemCampaignRewards", super, function () return cc.CSLoader:createNode(csbPath) end)

function UIElemCampaignRewards:ctor(parent)
    self._parent = parent;
    self._reusedList = nil

    self._reusedList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_1_Battlehelp", "ccui.ListView"), UIElemCampaignRewardsItem)
    self._onlyOnePanel = seekNodeByName(self, "Panel_0_Battlehelp", "ccui.Layout")
    self._noneText = seekNodeByName(self, "noneText", "ccui.Text")
    self._reusedList:setScrollBarEnabled(false)
    self._reusedList:setBounceEnabled(false)    
end

function UIElemCampaignRewards:show(data)
    self:setVisible(true)

    -- 生成显示的数据
    local items = self:generateRewardName(data)

    if #data == 0 then 
        self._onlyOnePanel:setVisible(false)
        self._noneText:setVisible(true)
        return
    else
        self._noneText:setVisible(false)
    end
    if #data > 1 then
        self._onlyOnePanel:setVisible(false)
        self._reusedList:deleteAllItems()
        -- 给每个items分组
        local afterSlicing = {}
        local group = (#items - 1)/ 5 + 1
        for i = 1, group do
            for j = 1,5 do
                if items[(i-1) * 5 + j] then
                    if afterSlicing[i] == nil then
                        afterSlicing[i] = {}
                    end
                    table.insert(afterSlicing[i],items[(i-1) * 5 + j])
                end
            end
        end
        for idx,member in ipairs(afterSlicing) do
            self._reusedList:pushBackItem(member)
        end
    else
        self._onlyOnePanel:setVisible(true)
        local rank = seekNodeByName(self._onlyOnePanel, "1_BitmapFontLabel_px_Battlehelp", "ccui.TextBMFont")
        local reward = seekNodeByName(self._onlyOnePanel, "1_BitmapFontLabel_jp_Battlehelp", "ccui.TextBMFont")
        rank:setString("第"..items[1].value.."名")
        reward:setString(self:generateReward(items[1]))
    end
end

function UIElemCampaignRewards:hide()
    self:setVisible(false)
end

--  生成奖品统计list
function UIElemCampaignRewards:generateRewardName(list)
    local map = {}
    local result = {}
    -- 生成每种奖品的map 键为 "奖励房卡&奖励礼券",把所有相同奖励的都放在一起
    table.foreach(list, function(key, val)
        if map[PropReader.generatePropTxt(val.item)] == nil then
            map[PropReader.generatePropTxt(val.item)] = {}
        end
        table.insert(map[PropReader.generatePropTxt(val.item)], { rank = val.rank, item = val.item})
    end)

    -- 根据奖品map所需要的最低排名进行排序 获得相同奖励情况下，最低的排名，和最高的排名
    table.foreach(map, function(key, val)
        local low = val[1].rank
        local high = val[1].rank
        table.foreach(val, function( key2,val2 )
            if val2.rank < low then
                low = val2.rank
            end
            if val2.rank>high then 
                high = val2.rank
            end
        end
        )
        if #val > 1 then
            table.insert( result, {rank = low, item = val[1].item ,value = low .. "-" .. high})
        else
            table.insert( result, {rank = low, item = val[1].item ,value = low})
        end
    end)
    table.sort( result, function ( a,b ) 
        return a.rank<b.rank
    end )
    return result
end

function UIElemCampaignRewards:generateReward(param)
    local rewardTxt = ""

    if param.item ~= "" then
        rewardTxt = rewardTxt .. PropReader.generatePropTxt(param.item)
    end

    return rewardTxt
end

return UIElemCampaignRewards;