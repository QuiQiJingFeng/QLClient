--[[
    @desc: 新版比赛结果页面
    author:{贺逸}
    time:2018-06-19
    return
]]
local csbPath = "ui/csb/Campaign/campaignHall/CampaignResult.csb"
local super = require("app.game.ui.UIBase")
local CampaignAnimPlayer = require("app.game.campaign.utils.CampaignAnimPlayer");
local PropTextConvertor = game.util.PropTextConvertor

local CAMPAIGN_AGAIN = 
{
    TRUE = 1,
    FALSE = 0
}

local CAMPAIGN_RECEIVE = 
{
    RECEIVED = 0,
    NOTRECEIVED = 1
}

local UICampaignResults = class("UICampaignResults", super, function() return kod.LoadCSBNode(csbPath) end)

function UICampaignResults:ctor()
    self._btnLeft = nil
    self._btnRight = nil
    self._btnExit = nil
    self._animNode = nil

    self._needShareToGet = false
end

function UICampaignResults:init()
    self._btnLeft = seekNodeByName(self, "Button_left",  "ccui.Button")
    self._btnRight = seekNodeByName(self, "Button_right",  "ccui.Button")
    self._btnExit = seekNodeByName(self, "Button_exit",  "ccui.Button")
    self._animNode = seekNodeByName(self, "Node_anim", "cc.Node")

    self:_registerCallBack()
end

function UICampaignResults:_registerCallBack()
    bindEventCallBack(self._btnExit, handler(self, self._onClickBackBtn), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnLeft, handler(self, self._onClickAgainBtn), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRight, handler(self, self._onClickShareBtn), ccui.TouchEventType.ended)
end

function UICampaignResults:onShow(...)
    UIManager:getInstance():hide("UICampaignWait")
    UIManager:getInstance():hide("UICampaignPromotion")
    -- 普通分享回调
    game.service.WeChatService.getInstance():addEventListener("EVENT_SEND_RESP", handler(self, self._onShareCallback), self);

    local args = {...}
    local data = args[1]   
    self._data = data
    local isGiveup = data.result.isGiveUp
    self._configId = data.configId
    self.origion = args[2]
    self._needShareToGet = data.result.status == CAMPAIGN_RECEIVE.NOTRECEIVED
    self.campaignId = data.result.id
    self.createTimeStamp = data.result.createTimestamp
    self.status  = data.result.status

    -- 如果网络延时，奖状在打立弹出等待页面之前弹出来了，那么取消打立赛接到gameover解散房间时创建的等待计时器
    game.service.CampaignService.getInstance():setDaliWaitFlag(false)
    -- 隐藏等待中UI
    UIManager:getInstance():hide("UICampaignWait")
    UIManager:getInstance():hide("UICampaignPromotion")
    
    -- 是否再来一局
    if self.origion == "campaign" then
        local againVisible = data.again == CAMPAIGN_AGAIN.TRUE
        if not againVisible then
            local pos = cc.p((self._btnLeft:getPositionX() + self._btnRight:getPositionX()) / 2, self._btnRight:getPositionY())
            self._btnRight:setPosition(pos)
        end
        self._btnLeft:setVisible(againVisible)
    else
        self._btnLeft:setVisible(false)

        local pos = cc.p((self._btnLeft:getPositionX() + self._btnRight:getPositionX()) / 2, self._btnRight:getPositionY())
        self._btnRight:setPosition(pos)
    end 

    local text = self._btnRight:getChildByName("BitmapFontLabel_1_0")
    if self._needShareToGet  then        
        text:setString("分享领取")
    else
        text:setString("炫耀")
    end

    self:_playAnim(data)
end

-- 播放对应的动画
function UICampaignResults:_playAnim(data)
    -- 如果是退赛 则播放退赛的动画
    if (data.result.isGiveUp or #data.result.item == 0) and data.result.rank > 3 then
        local node = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["NOREWARD"],false)
        local panel = node:getChildByName("Panel_5")
        local name = kod.util.String.getMaxLenString(game.service.LocalPlayerService:getInstance():getName(), 8)
        local textCrat = panel:getChildByName("Text_1")
        local panelRank = panel:getChildByName("Panel_3")
        local textRank = panelRank:getChildByName("BitmapFontLabel_1_0")
        textCrat:setVisible(false)
        textCrat:setString("恭喜" .. name .. "在" .. data.result.name .. "中荣获")
        textRank:setString("第  " .. data.result.rank .. "  名")
    elseif data.result.rank >3 then
        local node = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["SOMEREWARD"],false, 1)
        local panel = node:getChildByName("Image_5")
        local rank = panel:getChildByName("BitmapFontLabel_1")
        rank:setString("第" .. data.result.rank .. "名")
        local reward = node:getChildByName("BitmapFontLabel_3")
        reward:setString("奖励" .. PropTextConvertor.genItemsNameWithOperator(data.result.item , '+'))
    elseif data.result.rank == 3 then
        local node = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["3RDREWARD"],false)
        local panel = node:getChildByName("Panel_1"):getChildByName("Panel_2")
        local text = panel:getChildByName("Text_1")

        local rankText = node:getChildByName("Panel_1"):getChildByName("BitmapFontLabel_1")
        rankText:setScaleX(0.1)
        rankText:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.43, 2, 0.2),
            cc.ScaleTo:create(0.06, 1, 1)
        ))
        rankText:setOpacity(0)
        rankText:runAction(cc.Sequence:create(
            cc.FadeTo:create(0.43,20),
            cc.FadeTo:create(0.06,255)
        ))
        rankText:setPositionX(350)
        rankText:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.3,cc.p(45,rankText:getPositionY())),
            cc.MoveTo:create(0.06,cc.p(100,rankText:getPositionY()))
        ))
        
        if #data.result.item ==0 then
            panel:setVisible(false)
        else
            text:setString("获得奖励" .. PropTextConvertor.genItemsNameWithOperator(data.result.item , '+'))
        end
    elseif data.result.rank == 2 then
        local node = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["2NDREWARD"],false)
        local panel = node:getChildByName("Panel_1"):getChildByName("Panel_2")
        local text = panel:getChildByName("Text_1")

        local rankText = node:getChildByName("Panel_1"):getChildByName("BitmapFontLabel_1")
        rankText:setScaleX(0.1)
        rankText:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.43, 2, 0.2),
            cc.ScaleTo:create(0.06, 1, 1)
        ))
        rankText:setOpacity(0)
        rankText:runAction(cc.Sequence:create(
            cc.FadeTo:create(0.43,20),
            cc.FadeTo:create(0.06,255)
        ))
        rankText:setPositionX(350)
        rankText:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.3,cc.p(45,rankText:getPositionY())),
            cc.MoveTo:create(0.06,cc.p(100,rankText:getPositionY()))
        ))

        if #data.result.item ==0 then
            panel:setVisible(false)
        else
            text:setString("获得奖励" .. PropTextConvertor.genItemsNameWithOperator(data.result.item , '+'))
        end
    elseif data.result.rank == 1 then
        local node = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["1STREWARD"],false)
        local panel = node:getChildByName("Panel_1"):getChildByName("Panel_2")
        local text = panel:getChildByName("Text_1")        

        local rankText = node:getChildByName("Panel_1"):getChildByName("BitmapFontLabel_1")
        rankText:setScaleX(0.1)
        rankText:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.43, 2, 0.2),
            cc.ScaleTo:create(0.06, 1, 1)
        ))
        rankText:setOpacity(0)
        rankText:runAction(cc.Sequence:create(
            cc.FadeTo:create(0.43,20),
            cc.FadeTo:create(0.06,255)
        ))
        rankText:setPositionX(350)
        rankText:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.3,cc.p(45,rankText:getPositionY())),
            cc.MoveTo:create(0.06,cc.p(100,rankText:getPositionY()))
        ))

        if #data.result.item ==0 then
            panel:setVisible(false)
        else
            text:setString("获得奖励" .. PropTextConvertor.genItemsNameWithOperator(data.result.item , '+'))
        end
    end
end

-- 中间动画
function UICampaignResults:_addCenterAnim(anim,isLoop,scale)
    self._animNode:removeAllChildren()
    local node = CampaignAnimPlayer:getInstance():play(self._animNode, anim, 1, isLoop)
    return node
end

function UICampaignResults:onHide()
    game.service.WeChatService.getInstance():removeEventListenersByTag(self);
end

-- 返回按钮
function UICampaignResults:_onClickBackBtn()
    if self.origion ~= "history" then
         campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")
         UIManager:getInstance():destroy("UICampaignResults")
         game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
         game.service.CampaignService.getInstance():getArenaService():clearArenaCache()
    else
         UIManager:getInstance():destroy("UICampaignResults")
    end
end

-- 再来一局
function UICampaignResults:_onClickAgainBtn(sender)
    game.service.CampaignService.getInstance():sendCCASignUpREQ(self.campaignId, self._configId, self._data.key)     
    campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")
    if self.campaignId == config.CampaignConfig.ARENA_ID then
        UIManager:getInstance():destroy("UICampaignPromotion")
    end
    game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
    game.service.CampaignService.getInstance():getArenaService():clearArenaCache()
    UIManager:getInstance():destroy("UICampaignResults")
end

-- 分享按钮
function UICampaignResults:_onClickShareBtn()
    UIManager:getInstance():show("UICampaignSharePage",self._data)
    local panel = UIManager:getInstance():getUI("UICampaignSharePage"):getRoot()
    UIManager:getInstance():hide("UICampaignSharePage")
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_DiplomaShare);
    local img = seekNodeByName(panel, "QRCode", "ccui.ImageView")

    local data =
    {
        enter = share.constants.ENTER.CAMPAIGN,
        panel = panel,
        img = img
    }

    if self._needShareToGet then
        share.ShareWTF.getInstance():share(share.constants.ENTER.CAMPAIGN, {data, data, data}, function() 
            self:_onShareCallback()
        end)
    else
        share.ShareWTF.getInstance():share(share.constants.ENTER.CAMPAIGN, {data, data, data})        
    end
end

function UICampaignResults:_onShareCallback()
    -- 如果已领取则不调用领取请求
    if self.status == CAMPAIGN_RECEIVE.RECEIVED then return end
    game.service.CampaignService.getInstance():getCampaignFunctionService():onCCAReceiveRewardREQ(self.campaignId, self.createTimeStamp)     
    if self.origion ~= "campaign" then
        UIManager:getInstance():destroy("UICampaignResults")
        -- 刷新战绩列表和红点
        -- 如果是自建赛页面
        if UIManager:getInstance():getIsShowing("UIClubActivityMain") then
            local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
            local clubId = localStorageClubInfo:getClubId()
            game.service.CampaignService.getInstance():getCampaignFunctionService():onCCACampaignHistoryREQ(clubId)
            game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)  
        else            
            game.service.CampaignService.getInstance():getCampaignFunctionService():onCCACampaignHistoryREQ(0)            
        end   
    end
end

function UICampaignResults:needBlackMask()
    return false
end

function UICampaignResults:closeWhenClickMask()
    return false
end

function UICampaignResults:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignResults