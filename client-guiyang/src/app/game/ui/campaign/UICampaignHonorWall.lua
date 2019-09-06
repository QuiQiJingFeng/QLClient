local csbPath = "ui/csb/Campaign/UIBattleWinners.csb"
local super = require("app.game.ui.UIBase")

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UICampaignHonorWall = class("UICampaignHonorWall", super, function () return kod.LoadCSBNode(csbPath) end)

-- 单条奖励显示item
-------------------------------------------------------------------------------------
local UIHonorWallItem = class("UIHonorWallItem")

function UIHonorWallItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIHonorWallItem)
    self:_initialize()
    -- self:retain()
    return self
end

function UIHonorWallItem:_initialize()
    self.infoTxt = seekNodeByName(self, "Text_2_BattleWinners", "ccui.Text")
    self.winner = seekNodeByName(self, "Text_1_BattleWinners", "ccui.Text")
    self.btnDetail = seekNodeByName(self, "Button_1", "ccui.Button")

    bindEventCallBack(self.btnDetail,        handler(self, self.onBtnDetail),    ccui.TouchEventType.ended);
end

function UIHonorWallItem:getData()
    return self._data
end

function UIHonorWallItem:setData( applicationInfo )
    self._data = applicationInfo

    self.infoTxt:setString(self:generateCampaignInfo( applicationInfo ))
    self.winner:setString( kod.util.String.getMaxLenString(self:generate1stName(applicationInfo), 10) )
end

function UIHonorWallItem:generateCampaignInfo( data )
    local text = ""
    text = text .. self:_convertToDate(data.time) .. " " .. data.campaignName
    return text
end

-- 生成冠军名称
function UIHonorWallItem:generate1stName( param )
    local data = param.roleHonor
    local result = ""
    table.foreach(data, function( k,v )
        if v.rank == 1 then
            result = v.name
        end
    end    
    )
    return result
end

function UIHonorWallItem:onBtnDetail()
    UIManager:getInstance():show("UICampaignHonorDetail", self._data);
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_HonorWallDetail);
end

function UIHonorWallItem:_convertToDate(stamp)
    -- body
    return tonumber(os.date("%m",stamp/1000)).."月"..os.date("%d",stamp/1000).."日"
end
-------------------------------------------------------------------------------------

function UICampaignHonorWall:ctor()
    self.btnClose = nil
    self.btnReward = nil

    self._reusedHonorList = nil;
    self._reusedHonorList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_1_BattleWinners", "ccui.ListView"), UIHonorWallItem)
    self._btnClose = seekNodeByName(self, "Button_Close",  "ccui.Button");
    self._noneText = seekNodeByName(self, "none_Text",  "ccui.Button");
    
    self._reusedHonorList:setScrollBarEnabled(false)
end

function UICampaignHonorWall:init()
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
end

function UICampaignHonorWall:onShow( ... )
    local args = {...}
    self._reusedHonorList:deleteAllItems()
    local datas  = args[1]
    self._noneText:setVisible(#datas == 0)

    table.sort(datas, function (a, b) return a.time > b.time end )

    for idx,member in ipairs(datas) do
        self._reusedHonorList:pushBackItem(member)
    end
end

function UICampaignHonorWall:_onClose()
    UIManager:getInstance():destroy("UICampaignHonorWall")
end

function UICampaignHonorWall:needBlackMask()
	return true;
end

function UICampaignHonorWall:closeWhenClickMask()
	return false
end

return UICampaignHonorWall