-- 自建赛历史记录界面
local csbPath = "ui/csb/Campaign/selfbuild/UIClubBattleHistory.csb"
local super = require("app.game.ui.UIBase")
local UIElemCampaignHistoryPage = require("app.game.ui.campaign.campaignHall.elem.UIElemCampaignHistoryPage")

local UICampaignHistory_Club = class("UICampaignHistory_Club", super, function() return kod.LoadCSBNode(csbPath) end)

function UICampaignHistory_Club:ctor()
    self._nodeSubUIAnchor = nil         -- 子页面锚点
    self._elemCampaignHistory = nil
end

function UICampaignHistory_Club:init()    
    self._backBtn =  seekNodeByName(self, "Button_2_MaJiangSaiShi", "ccui.Button")   
    self._nodeSubUIAnchor = seekNodeByName(self, "Node_1", "cc.Node")           -- 分享按钮


    bindEventCallBack(self._backBtn, handler(self, self.onBtnBack), ccui.TouchEventType.ended)
end

function UICampaignHistory_Club:onShow(data)
    self._elemCampaignHistory = UIElemCampaignHistoryPage.new(self)
    self._nodeSubUIAnchor:addChild(self._elemCampaignHistory)

    self._elemCampaignHistory:show(data)
end

function UICampaignHistory_Club:onHide()
    game.service.CampaignService.getInstance():removeEventListenersByTag(self);
    self._nodeSubUIAnchor:removeAllChildren(true)
end

function UICampaignHistory_Club:onBtnBack()
    UIManager:getInstance():destroy("UICampaignHistory_Club") 
end

function UICampaignHistory_Club:onClose()
    
end

function UICampaignHistory_Club:needBlackMask()
	return false;
end

function UICampaignHistory_Club:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UICampaignHistory_Club:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignHistory_Club
