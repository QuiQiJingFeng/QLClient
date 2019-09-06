local buttonConst = require("app.gameMode.mahjong.core.Constants").ButtonConst
local csbPath = "ui/csb/Mall/UIMallReadMe.csb"
local UIMallReadMe = class("UIMallReadMe", function() return cc.CSLoader:createNode(csbPath) end)

function UIMallReadMe:ctor(parent)
    self._parent = parent
    parent:addChild(self)
    self:_init()
    self:setEnable(false)
end

function UIMallReadMe:_init()
    self._btnClose = seekNodeByName(self, "Button_x_CouponZD", "ccui.Button")
    self._btnGotPoints = seekNodeByName(self, "Button_4", "ccui.Button")
    self._textContent = seekNodeByName(self, "Text_Content_1", "ccui.Text")

    self:_setDefaultTextContent()
    self:_registerCallback()
end

function UIMallReadMe:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnGotPoints, handler(self, self._onBtnGotPointsClick), ccui.TouchEventType.ended)
    require("app.game.util.UIElementUtils"):createMaskLayer(self)
end

function UIMallReadMe:onShow(args)
    self:setEnable(true)
end

function UIMallReadMe:setEnable(value)
    self:setVisible(value or false)
end

function UIMallReadMe:dispose()
    self:setEnable(false)
    self:removeFromParent()
end

function UIMallReadMe:_onBtnCloseClick(sender)
    self:setEnable(false)
end

function UIMallReadMe:_onBtnGotPointsClick(sender)
    local sender = self._parent.userDataSender
    -- sender:send(sender.ACTION_ENUM.GET_POINTS_CAMPAIGN)
    -- --  比赛没有开启的情况下不能进入比赛
    -- if (bit.band(game.service.LocalPlayerService.getInstance():getBtnValue(), buttonConst.CAMPAIGN_BTN) == 0 and {false} or {true})[1] then
    --     if game.service.CampaignService.getInstance():getId() ~= 0 then
    --         game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
    --         return
    --     end
    -- end

    local goldService = game.service.GoldService.getInstance()
	if not goldService.dataRoomInfo then
		game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
	else
		GameFSM.getInstance():enterState("GameState_Gold")
	end

end


function UIMallReadMe:_setDefaultTextContent()
    local strContent = "在金币场中参加比赛即可获得大量礼券，可在商城兑换话费光速到账。还等什么，快去赢取礼券吧！"
    self._textContent:setString(strContent)
end

function UIMallReadMe:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return UIMallReadMe