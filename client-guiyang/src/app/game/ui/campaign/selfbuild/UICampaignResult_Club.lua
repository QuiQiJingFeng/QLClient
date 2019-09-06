local csbPath = "ui/csb/Campaign/selfbuild/UIClubBattleResult.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UICampaignResult_Club = class("UICampaignResult_Club", super, function() return kod.LoadCSBNode(csbPath) end)

local UICellModel = class( "UICellModel" ) 

function UICellModel:ctor( uiroot , data )
    self._name = seekNodeByName(uiroot, "Text_id1", "ccui.Text")
    self._rank = seekNodeByName(uiroot, "Text_nc1", "ccui.Text")
    self._reward = seekNodeByName(uiroot, "Text_mc1", "ccui.Text")
    self:insertData(data)
end

function UICellModel:insertData(data)
    local rewardTxt = ""
    
    self._name:setString(data.name)
    self._rank:setString(data.rewardList[1].rank)
    self._reward:setString(self:generateReward(data.rewardList[1]))
end

function UICellModel:generateReward(param)
    local rewardTxt = ""

    if param.item ~= "" then
        rewardTxt = rewardTxt .. PropReader.generatePropTxt(param.item)
    end

    return rewardTxt
end

function UICampaignResult_Club:ctor()
    self._rankData = {}   -- 比赛结果相关数据
end

function UICampaignResult_Club:init( )
    self._btnclose = seekNodeByName(self, "Button_close" , "ccui.Button")
    self._panelModel = seekNodeByName(self, "Panel_1_bsjg_Result" , "ccui.Layout")
    self._textTip = seekNodeByName(self, "Image_No1", "ccui.Text")
    -- self._imgbgTip = seekNodeByName(self, "Image_No1" , "ccui.ImageView")
    self._listView = seekNodeByName(self, "ListView_Result", "ccui.ListView")
    self._listView:removeAllItems()
    -- self._listView:setScrollBarOpacity(0)
    self._panelModel:retain()
    self._panelModel:removeFromParent()
    self:_registerCallBack()
end

function UICampaignResult_Club:_registerCallBack()
    bindEventCallBack(self._btnclose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
end

function UICampaignResult_Club:onShow( data )
    self._rankData = data
    self._listView:removeAllItems()
    if #data == 0 then
        self._textTip:setString("因报名人数不足，赛事取消")
        self._textTip:getParent():setVisible(true)
    else
        self:insertData(data)
        self._textTip:getParent():setVisible(false)
    end
end

function UICampaignResult_Club:insertData( data )

    table.sort(data, function(a, b) 
        return a.rewardList[1].rank < b.rewardList[1].rank
    end)

    self._listView:removeAllItems()
    for i=1,#data do
        local item = self._panelModel:clone()
        local cell = UICellModel.new(item , data[i])
        self._listView:addChild(item)
    end    
end

function UICampaignResult_Club:_onBtnCloseClick()
    UIManager:getInstance():hide("UICampaignResult_Club")
end

function UICampaignResult_Club:hide()
    self:setVisible(false)
end

function UICampaignResult_Club:dispose()
    self._panelModel:release()
    self._panelModel = nil
end

function UICampaignResult_Club:needBlackMask()
	return true;
end

function UICampaignResult_Club:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UICampaignResult_Club:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignResult_Club
