--[[
    麻将馆赛事详情
--]]
local csbPath = "ui/csb/Campaign/selfbuild/UIClubBattleDetail.csb"
local super = require("app.game.ui.UIBase")
local Constants = require("app.gameMode.mahjong.core.Constants");
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")

----------------------------------------------------------------------
--比赛场比赛详情界面
local UICampaignDetail_Club = class("UICampaignDetail_Club", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignDetail_Club:ctor(parent)
    self._parent = parent;

    self.rewardInfo = {}        -- 记录奖品

    self.rewardsList = nil;
    self.detailText = nil;

end

function UICampaignDetail_Club:init()
    -- 只有一个奖品时的UI    
    self.oneRewardPanel = seekNodeByName(self, "Panel_1_reward_Battlehelp", "ccui.Layout")   

    self.scrollViewInfo = seekNodeByName(self, "ScrollView_info", "ccui.ScrollView")

    self.rewardsList = seekNodeByName(self, "ListView_list_Battlehelp", "ccui.ListView")    

    self.rewardCell = seekNodeByName(self, "rewardCell", "ccui.Layout")

    self.ruleInfo = seekNodeByName(self, "Text_z_Battlehelp", "ccui.Text")

    self.noneText = seekNodeByName(self, "noneText", "ccui.Text")
    
    self.btnClose = seekNodeByName(self, "Button_x_Battlehelp", "ccui.Button")

    self._btnDisband = seekNodeByName(self, "Button_jsbs" , "ccui.Button")
    self._btnSignUpRight = seekNodeByName(self, "Button_ljbm" , "ccui.Button")
    self._btnSignUpMiddle = seekNodeByName(self, "Button_ljbm1" , "ccui.Button")
    self._btnCancel = seekNodeByName(self, "Button_qxbm" , "ccui.Button")

    self.arrow = seekNodeByName(self, "arrow", "ccui.Layout")
    
    self.rewardCell:removeFromParent(false)
    self.rewardCell:retain()

    -- 绑定按钮事件
    bindEventCallBack(self.btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDisband, handler(self, self._onbtnDisband), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSignUpRight, handler(self, self._onbtnSignUp), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSignUpMiddle, handler(self, self._onbtnSignUp), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onbtnCancel), ccui.TouchEventType.ended)
end

function UICampaignDetail_Club:_signUp(data)
    if self._showData.id == data.id then
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

function UICampaignDetail_Club:_signUpCancle(data)
    if self._showData.id == data.id then
        self._btnCancel:setVisible(false)
        self._btnSignUpRight:setVisible(true)
        self._btnSignUpRight:setPositionX(self._btnCancel:getPositionX())
    end
end

function UICampaignDetail_Club:onShow(info)
-- 报名取消报名事件监听
    local selfbuildService = game.service.CampaignService.getInstance():getSelfbuildService();
    selfbuildService:addEventListener("EVENT_CAMPAIGNSELFBUILD_SIGNUP",    handler(self, self._signUp), self)
    selfbuildService:addEventListener("EVENT_CAMPAIGNSELFBUILD_CANCLED",    handler(self, self._signUpCancle), self)

    self._showData = info
    -- 设置按钮显示和位置
    self:_showButtonVisibleAndPosition(info)

    -- 设置奖品信息
    self.rewardInfo = self:generateRewardName(info.rewardList)
    
    self.rewardCell:setVisible(false)
    if #self.rewardInfo == 1 then  
        local bg = seekNodeByName(self, "Image_dw_1_a_Battlehelp", "ccui.ImageView")
        local rankTxt = seekNodeByName(self, "1rewardTxt_Battlehelp", "ccui.Text")
        local reward = seekNodeByName(self, "1st_rewardTxt_Battlehelp", "ccui.Text")
        rankTxt:setString("第"..self.rewardInfo[1].value.."名")

        local rewardTxt = ""
        
        if self.rewardInfo.item ~= "" then
            rewardTxt = rewardTxt .. PropReader.generatePropTxt(self.rewardInfo[1].item)
        end

        reward:setString(rewardTxt)
    else        
        for idx,member in ipairs(self.rewardInfo) do
            local item = self.rewardCell:clone()
            item:setVisible(true)
            self.rewardsList:addChild(item)
            local bg = item:getChildByName("Image_1")
            item:getChildByName("rankText"):setString("第"..member.value.."名")

            local rewardTxt = ""

            rewardTxt = rewardTxt .. PropReader.generatePropTxt(member.item)

            item:getChildByName("rewardText"):setString(rewardTxt)        
        end

        local size = self.rewardCell:getContentSize()
        local width = #self.rewardInfo * 137 > 685 and 685 or #self.rewardInfo * 137 
        self.rewardsList:setContentSize(cc.size(width, size.height))
        self.rewardsList:setScrollBarEnabled(false)
    end

    self.noneText:setVisible(#self.rewardInfo == 0)

    self.oneRewardPanel:setVisible(#self.rewardInfo == 1)    
    self.arrow:setVisible(#self.rewardInfo > 5)
    self.rewardsList:setVisible(#self.rewardInfo ~= 1)   
    local scrollViewSize = self.scrollViewInfo:getContentSize()
	self.ruleInfo:setTextAreaSize(cc.size(scrollViewSize.width, 0))
	
	local text = string.gsub(info.instructions ,"\\n","\n")
	self.ruleInfo:setString(text)
	local s = self.ruleInfo:getVirtualRendererSize()
	
	self.ruleInfo:setContentSize(cc.size(s.width, s.height))
	self.ruleInfo:setPositionY(scrollViewSize.height > s.height and scrollViewSize.height or s.height)
	self.scrollViewInfo:setInnerContainerSize(cc.size(scrollViewSize.width, s.height))
end


--  生成奖品统计list
function UICampaignDetail_Club:generateRewardName(list)
    local map = {}
    local result = {}
    -- 生成每种奖品的map 键为 "奖励房卡&奖励礼券",把所有相同奖励的都放在一起
    table.foreach(list, function(key, val)
        if map[PropReader.generatePropTxt(val.item)] == nil then
            map[PropReader.generatePropTxt(val.item)] = {}
        end
        table.insert(map[PropReader.generatePropTxt(val.item)], { rank = val.rank,item = val.item})
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
            table.insert( result, {rank = low, item = PropReader.generatePropTxt(val[1].item) ,value = low .. "-" .. high})
        else
            table.insert( result, {rank = low, item = PropReader.generatePropTxt(val[1].item) ,value = low})
        end
    end)
    table.sort( result, function ( a,b ) 
        return a.rank<b.rank
    end )
    return result
end

function UICampaignDetail_Club:_onbtnDisband()
    local str = "确定解散该比赛"
    game.ui.UIMessageBoxMgr.getInstance():show(str , {"确定","取消"}, function()
        local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
        local clubId = localStorageClubInfo:getClubId()
        game.service.CampaignService:getInstance():getSelfbuildService():onCCACampaignCancelREQ(self._showData.id,clubId)
    end,nil,nil,nil,0)
end

function UICampaignDetail_Club:_onbtnSignUp()
    game.service.CampaignService.getInstance():sendCCASignUpREQ(self._showData.id, self._showData.configId, 1)
end

function UICampaignDetail_Club:_onbtnCancel()
    game.service.CampaignService.getInstance():sendCCASignUpCancelREQ(self._showData.id) 
end

function UICampaignDetail_Club:_showButtonVisibleAndPosition( data )
    -- 只有已创建的页面，点击详情才会显示按钮
    self._btnDisband:setVisible(false)
    self._btnSignUpRight:setVisible(false)
    self._btnSignUpMiddle:setVisible(false)
    self._btnCancel:setVisible(false)

    local state = GameFSM.getInstance():getCurrentState().class.__cname
    local isCreateGameUI = UIManager:getInstance():getIsShowing("UICampaignCreate_Club")  -- 创建赛事页面点击的详情不显示button  
    if state ~= nil and (not isCreateGameUI) then
        -- 只有报名状态和比赛中状态才显示
        if self._showData.status == config.CampaignConfig.CampaignStatus.SIGN_UP or self._showData.status == config.CampaignConfig.CampaignStatus.ONGOING then
            local gameCreatedData = game.service.CampaignService:getInstance():getSelfbuildService():getGameCreatedData()    
            local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
            local clubId = localStorageClubInfo:getClubId()
            local club = game.service.club.ClubService.getInstance():getClub(clubId)
            local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
            local isManager = club:isManager(roleId)
            local x = gameCreatedData.campaignId
            if table.indexof(gameCreatedData.campaignId,self._showData.id) then
                self._btnCancel:setVisible(true)
                if not isManager then
                    self._btnCancel:setPositionX(self._btnSignUpMiddle:getPositionX())
                end
            else
                self._btnSignUpMiddle:setVisible( not isManager)
                self._btnSignUpRight:setVisible(isManager)
            end
            self._btnDisband:setVisible(isManager)
            local scrollSize = self.scrollViewInfo:getContentSize()
            self.scrollViewInfo:setContentSize(scrollSize)
        end
        if self._showData.status == config.CampaignConfig.CampaignStatus.ONGOING then
            self._btnDisband:setVisible(false)
            self._btnSignUpRight:setVisible(false)
            self._btnSignUpMiddle:setVisible(false)
            self._btnCancel:setVisible(false)
        end
    else
        local scrollSize = self.scrollViewInfo:getContentSize()
        local buttonHeight = self._btnDisband:getContentSize().height
        self.scrollViewInfo:setAnchorPoint(cc.p(0.5,0.65))
        self.scrollViewInfo:setContentSize(cc.size(scrollSize.width,scrollSize.height + buttonHeight))
    end
    
end 

--生成文字并加入容器,文本属性已经设定好 */
function UICampaignDetail_Club:createLabel(text, color, fontSize)
	local Label = ccui.Text:create();
	Label:setString(text);
	Label:ignoreContentAdaptWithSize(false);
	Label:setTextAreaSize(cc.size(630,0))
	Label:setTextColor(color);
	Label:setFontSize(fontSize);
	Label:setAnchorPoint(cc.p(0,1));
end

function UICampaignDetail_Club:onHide()
    game.service.CampaignService.getInstance():removeEventListenersByTag(self)
    game.service.CampaignService.getInstance():getSelfbuildService():removeEventListenersByTag(self)
    self.rewardsList:removeAllChildren(true)
end

function UICampaignDetail_Club:dispose()
    if self.rewardCell ~= nil then
        self.rewardCell:release()
        self.rewardCell = nil                                                                
    end
end

function UICampaignDetail_Club:_onClose()
    UIManager:getInstance():destroy("UICampaignDetail_Club")
end

function UICampaignDetail_Club:needBlackMask()
	return true;
end

function UICampaignDetail_Club:closeWhenClickMask()
	return false
end

return UICampaignDetail_Club;
