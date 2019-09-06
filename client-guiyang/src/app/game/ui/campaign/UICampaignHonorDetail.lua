local csbPath = "ui/csb/Campaign/UIBattleWinnersDetail.csb"
local super = require("app.game.ui.UIBase")

local UICampaignHonorDetail = class("UICampaignHonorDetail", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignHonorDetail:ctor()
    self._title = nil
	self._campaignDate = nil;
	self._btnClose = nil
    self._1stName = nil
    self._1stReward = nil
    self._2ndName = nil
    self._2ndReward = nil
    self._3rdName = nil
    self._2rdReward = nil
end

function UICampaignHonorDetail:init()
    self._title = seekNodeByName(self, "BitmapFontLabel_9", "ccui.TextBMFont")
    self._campaignDate = seekNodeByName(self, "CampaignDateTxt",  "ccui.Text");
	self._btnClose = seekNodeByName(self, "Button_x_STP",  "ccui.Button");
    self._1stName = seekNodeByName(self, "1stNameText",  "ccui.Text");
    self._1stReward = seekNodeByName(self, "1stRewardTxt",  "ccui.Text");
    self._2ndName = seekNodeByName(self, "2ndNameText",  "ccui.Text");
    self._2ndReward = seekNodeByName(self, "2ndRewardTxt",  "ccui.Text");
    self._3rdName = seekNodeByName(self, "3rdNameText",  "ccui.Text");
    self._3rdReward = seekNodeByName(self, "3rdRewardTxt",  "ccui.Text");

    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
end

function UICampaignHonorDetail:onShow(...)
    local args = {...};
    local data = args[1]
    self._title:setString(data.campaignName)
    self._campaignDate:setString(self:_convertToDate(data.time))
    
    if data.roleHonor[1] ~= nil then
        self._1stName:setString("第一名:" .. kod.util.String.getMaxLenString(data.roleHonor[1].name, 10))
        self._1stReward:setString( self:generateCampaignReward(data.roleHonor[1]))
    end

    if data.roleHonor[2] ~= nil then
        self._2ndName:setString( "第二名:" .. kod.util.String.getMaxLenString(data.roleHonor[2].name, 10))
        self._2ndReward:setString( self:generateCampaignReward(data.roleHonor[2]))
    end

    if data.roleHonor[3] ~= nil then
        self._3rdName:setString( "第三名:" .. kod.util.String.getMaxLenString(data.roleHonor[3].name, 10))
        self._3rdReward:setString( self:generateCampaignReward(data.roleHonor[3]))
    end
end

function UICampaignHonorDetail:_convertToDate(stamp)
    -- body
    return os.date("%Y",stamp/1000).."年" .. os.date("%m",stamp/1000).."月"..os.date("%d",stamp/1000).."日"
end

function UICampaignHonorDetail:generateCampaignReward( data )
    local result = ""
    result = PropReader.generatePropTxtAutoWrap(data.reward)
    return result
end

function UICampaignHonorDetail:_onClose()
    UIManager:getInstance():destroy("UICampaignHonorDetail")
end

function UICampaignHonorDetail:needBlackMask()
	return true;
end

function UICampaignHonorDetail:closeWhenClickMask()
	return true
end

return UICampaignHonorDetail;
