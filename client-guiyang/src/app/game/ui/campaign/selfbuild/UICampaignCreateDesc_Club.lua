--[[
    麻将馆赛事自建赛说明
--]]
local csbPath = "ui/csb/Campaign/selfbuild/UIClubBattleCreateDesc.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UICampaignCreateDesc_Club = class("UICampaignCreateDesc_Club", super, function() return kod.LoadCSBNode(csbPath) end)

function UICampaignCreateDesc_Club:ctor()
end

function UICampaignCreateDesc_Club:init( )
    self._btnclose = seekNodeByName(self, "Button_49" , "ccui.Button")
    self._content = seekNodeByName(self, "Text_content", "ccui.Text")
    self:_registerCallBack()
end

function UICampaignCreateDesc_Club:_registerCallBack()
    bindEventCallBack(self._btnclose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
end

function UICampaignCreateDesc_Club:onShow( data )
    -- local string = "丈夫本无泪，不洒离别间，一剑平生恨，气短英雄胆；山盟犹仍在，欢情春梦间，蛰龙已惊眠，一啸动千山。"
    local string = config.STRING.UICAMPAIGNCREATEDESC_CLUB_STRING_100
    self._content:setString(string)
end

function UICampaignCreateDesc_Club:_onBtnCloseClick()
    UIManager:getInstance():destroy("UICampaignCreateDesc_Club")
end

function UICampaignCreateDesc_Club:hide()
    self:setVisible(false)
end

function UICampaignCreateDesc_Club:needBlackMask()
	return true;
end

function UICampaignCreateDesc_Club:closeWhenClickMask()
	return false
end

function UICampaignCreateDesc_Club:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignCreateDesc_Club