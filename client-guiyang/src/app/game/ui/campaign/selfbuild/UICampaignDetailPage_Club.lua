--[[
比赛详情子界面
--]]
local csbPath = "ui/csb/Campaign/selfbuild/UIClubBattlehelp.csb"
local super = require("app.game.ui.UIBase")


local UIElemCampaignRewards = require("app.game.ui.campaign.elem.UIElemCampaignRewards")
local UIElemCampaignRule = require("app.game.ui.campaign.elem.UIElemCampaignRule")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local Constants = require("app.gameMode.mahjong.core.Constants")
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")
----------------------------------------------------------------------
--比赛场比赛详情界面
local UICampaignDetailPage_Club = class("UICampaignDetailPage_Club", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignDetailPage_Club:ctor(parent)
    self._parent = parent;

    -- 比赛奖励pannel
    self._campaignRewardPannel = nil
    -- 比赛规则pannel
    self._campaignRulePannel = nil

    self._anchorNode = nil

    -- checkbox
    self._campaignRewardCheckbox = nil
    self._campaignRuleCheckbox = nil

    self._checkboxGroup = {}

    self.datas = {}
end

function UICampaignDetailPage_Club:init()
    -- 只有一个奖品时的UI       
    self._btnClose = seekNodeByName(self, "btnClose_Battlehelp", "ccui.Button")
    self._campaignRewardCheckbox =  seekNodeByName(self, "CheckBox1_Battlehelp", "ccui.CheckBox")
    self._campaignRuleCheckbox =  seekNodeByName(self, "CheckBox2_Battlehelp", "ccui.CheckBox")
    self._anchorNode = seekNodeByName(self, "Node_1", "cc.Node")

    self._btnDisband = seekNodeByName(self, "Button_jsbs" , "ccui.Button")
    self._btnSignUpRight = seekNodeByName(self, "Button_ljbm" , "ccui.Button")
    self._btnSignUpMiddle = seekNodeByName(self, "Button_ljbm1" , "ccui.Button")
    self._btnCancel = seekNodeByName(self, "Button_qxbm" , "ccui.Button")

    -- 绑定按钮事件
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDisband, handler(self, self._onbtnDisband), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSignUpRight, handler(self, self._onbtnSignUp), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSignUpMiddle, handler(self, self._onbtnSignUp), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onbtnCancel), ccui.TouchEventType.ended)

    -- checkbox事件
    self._checkboxGroup = CheckBoxGroup.new({
        self._campaignRewardCheckbox,
        self._campaignRuleCheckbox
    }, handler(self, self._onCheckBoxGroupClick))
end

function UICampaignDetailPage_Club:onShow(info)
    self.datas = info

    local campaignService = game.service.CampaignService.getInstance();
    campaignService:addEventListener("EVENT_CAMPAIGNSELFBUILD_SIGNUP",    handler(self, self._onSignUp), self)
    campaignService:addEventListener("EVENT_CAMPAIGNSELFBUILD_CANCLED",    handler(self, self._onSignUpCancle), self)
    -- 设置按钮显示和位置
    self:_showButtonVisibleAndPosition(info)

    self:onRewardCheckbox(self.datas)
end

function UICampaignDetailPage_Club:_onCheckBoxGroupClick(group, index)
    if group[index] == self._campaignRewardCheckbox then
        self:onRewardCheckbox(self.datas)
    elseif group[index] == self._campaignRuleCheckbox then
        self:onRuleCheckbox(self.datas)
    end
end

function UICampaignDetailPage_Club:onRewardCheckbox(data)
    self._campaignRuleCheckbox:setSelected(false)
    self._campaignRewardCheckbox:setSelected(true)

    if self._campaignRewardPannel == nil then
        self._campaignRewardPannel = UIElemCampaignRewards.new(self)
        self._anchorNode:addChild(self._campaignRewardPannel)
    end

    self:hideAllPages()
    if data.rewardList ~= nil then
        self._campaignRewardPannel:show(data.rewardList)
    end
end

function UICampaignDetailPage_Club:onRuleCheckbox(data)
    self._campaignRewardCheckbox:setSelected(false)
    self._campaignRuleCheckbox:setSelected(true)

    if self._campaignRulePannel == nil then
        self._campaignRulePannel = UIElemCampaignRule.new(self)
        self._anchorNode:addChild(self._campaignRulePannel)
    end

    self:hideAllPages()
    if data ~= nil then
        self._campaignRulePannel:show(data)
    end
end

function UICampaignDetailPage_Club:_onbtnDisband()
    local str = "确定解散该比赛"
    game.ui.UIMessageBoxMgr.getInstance():show(str , {"确定","取消"}, function()
        local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
        local clubId = localStorageClubInfo:getClubId()
        game.service.CampaignService:getInstance():getSelfbuildService():onCCACampaignCancelREQ(self.datas.id,clubId)
    end,nil,nil,nil,0)
end

function UICampaignDetailPage_Club:_onbtnSignUp()
    game.service.CampaignService.getInstance():sendCCASignUpREQ(self.datas.id, self.datas.configId, 1)
end

function UICampaignDetailPage_Club:_onbtnCancel()
    game.service.CampaignService.getInstance():sendCCASignUpCancelREQ(self.datas.id) 
end

function UICampaignDetailPage_Club:_showButtonVisibleAndPosition( data )
    -- 只有已创建的页面，点击详情才会显示按钮
    self._btnDisband:setVisible(false)
    self._btnSignUpRight:setVisible(false)
    self._btnSignUpMiddle:setVisible(false)
    self._btnCancel:setVisible(false)

    local state = GameFSM.getInstance():getCurrentState().class.__cname
    local isCreateGameUI = UIManager:getInstance():getIsShowing("UICampaignCreate_Club")  -- 创建赛事页面点击的详情不显示button  
    if state ~= nil and (not isCreateGameUI) then
        -- 只有报名状态和比赛中状态才显示
            local gameCreatedData = game.service.CampaignService:getInstance():getSelfbuildService():getGameCreatedData()    
            local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
            local clubId = localStorageClubInfo:getClubId()
            local club = game.service.club.ClubService.getInstance():getClub(clubId)
            local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
            local isManager = club:isManager(roleId)
            local x = gameCreatedData.campaignId
            if table.indexof(gameCreatedData.campaignId,self.datas.id) then
                self._btnCancel:setVisible(true)
                if not isManager then
                    self._btnCancel:setPositionX(self._btnSignUpMiddle:getPositionX())
                end
            else
                self._btnSignUpMiddle:setVisible( not isManager)
                self._btnSignUpRight:setVisible(isManager)
            end
            self._btnDisband:setVisible(isManager)
        if self.datas.status ~= config.CampaignConfig.CampaignStatus.SIGN_UP and self.datas.status ~= config.CampaignConfig.CampaignStatus.BEFORE then
            self._btnDisband:setVisible(false)
            self._btnSignUpRight:setVisible(false)
            self._btnSignUpMiddle:setVisible(false)
            self._btnCancel:setVisible(false)
        end
    end    
end 

function UICampaignDetailPage_Club:_onSignUp(data)
    if self.datas.id == data.id then
        if self._btnSignUpRight:isVisible() then
            self._btnSignUpRight:setVisible(false)
            self._btnCancel:setPositionX(self._btnSignUpRight:getPositionX())            
        else
            self._btnSignUpMiddle:setVisible(false)
            self._btnCancel:setPositionX(self._btnSignUpMiddle:getPositionX())
        end
        self._btnCancel:setVisible(true)
    end
end

function UICampaignDetailPage_Club:_onSignUpCancle(data)
    if self.datas.id== data.id then
        self._btnCancel:setVisible(false)
        self._btnSignUpRight:setVisible(true)
        self._btnSignUpRight:setPositionX(self._btnCancel:getPositionX())
    end
end

function UICampaignDetailPage_Club:hideAllPages()
    if self._campaignRulePannel ~= nil then 
        self._campaignRulePannel:hide() 
    end
    if self._campaignRewardPannel ~= nil then 
        self._campaignRewardPannel:hide()
    end
end

function UICampaignDetailPage_Club:onHide()
    game.service.CampaignService.getInstance():removeEventListenersByTag(self)
end

function UICampaignDetailPage_Club:dispose()
end

function UICampaignDetailPage_Club:_onClose()
    UIManager:getInstance():destroy("UICampaignDetailPage_Club")
end

function UICampaignDetailPage_Club:needBlackMask()
	return true;
end

function UICampaignDetailPage_Club:closeWhenClickMask()
	return false
end

function UICampaignDetailPage_Club:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end


return UICampaignDetailPage_Club;