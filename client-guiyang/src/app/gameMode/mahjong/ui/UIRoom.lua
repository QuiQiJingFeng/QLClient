local UIElemBattery = require("app.game.ui.element.UIElemBattery")
local UIElemTime = require("app.game.ui.element.UIElemTime")
local UIElemNetwork = require("app.game.ui.element.UIElemNetwork")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Hus = require("app.gameMode.mahjong.ui.UIRoom_Hu")
local UI_ANIM = require("app.manager.UIAnimManager")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local room = require("app.game.ui.RoomSettingHelper")
local Constants = require("app.gameMode.mahjong.core.Constants")

local PLAYER_COUNT_DOWN_CSB = "ui/csb/PlayerSceneCountDowner.csb"
local PLAYER_COUNT_DOWN_CSB_3D = "ui/csb/PlayerSceneCountDowner_3D.csb"
local PLAYER_COUNT_DOWN_CSB_3D_ICLASSIC = "ui/csb/PlayerSceneCountDowner_3D_classic.csb"

local UIRoom = class("UIRoom")

function UIRoom:ctor(uiRoot)
    self.uiRoot = uiRoot
    self._timeTask = nil;
    self._isHaveBeginFirstGame = false

    self._countDownLayout = self:_createCountDownLayoutAndAddInContainer(seekNodeByName(uiRoot, "Panel_direction_Scene", "ccui.Layout"))
    self:_findCountDownLayoutWidgets(self._countDownLayout)
    self._lableRoomNumber = seekNodeByName(uiRoot, "Text_roomnumber_Scene", "ccui.Text");
    self._labelCampaignRank = seekNodeByName(uiRoot, "rankLabel", "ccui.TextBMFont");

    self._btnInviteRoom = seekNodeByName(uiRoot, "Button_wxyq_direction_Scene", "ccui.Button");
    self._btnMoreFriend = seekNodeByName(uiRoot, "btnMoreFriend", "ccui.Button");
    self._btnQuitRoom = seekNodeByName(uiRoot, "Button_fhdt_Scene", "ccui.Button");
    self._btnQuitRoom_Acting = seekNodeByName(uiRoot, "Button_fhdt_Scene_0", "ccui.Button");
    self._btnDestoryRoom = seekNodeByName(uiRoot, "Button_jsfj_Scene", "ccui.Button");
    self._panelAdvanceRoom = seekNodeByName(uiRoot, "Panel_qipao", "ccui.Layout")
    self._btnAdvanceRoom = seekNodeByName(uiRoot, "Button_ljkj1", "ccui.Button");
    self._advanceRoomText = seekNodeByName(uiRoot, "BitmapFontLabel_edg", "ccui.TextBMFont")
    self._advanceChickenText = seekNodeByName(uiRoot, "BitmapFontLabel_8_0", "ccui.TextBMFont")
    self._lableCardCount = seekNodeByName(uiRoot, "Text_1_direction_Scene", "ccui.Text");
    self._lableCardBg = seekNodeByName(uiRoot, "mj_bg_cards", "cc.Sprite");
    self._lableRoundCount = seekNodeByName(uiRoot, "Text_2_direction_Scene", "ccui.Text");
    self._labelCountDown = seekNodeByName(uiRoot, "BitmapFontLabel_sz_direction_Scene", "ccui.TextBMFont")
    self._huMask = seekNodeByName(uiRoot, "hu_mask", "ccui.Layout")
    self._dirDown = seekNodeByName(uiRoot, "z_nan_direction_Scene", "cc.Sprite")
    self._dirRight = seekNodeByName(uiRoot, "z_dong_direction_Scene", "cc.Sprite")
    self._dirTop = seekNodeByName(uiRoot, "z_bei_direction_Scene", "cc.Sprite")
    self._dirLeft = seekNodeByName(uiRoot, "z_xi_direction_Scene", "cc.Sprite")
    self._discardedCardIndicator = ccui.ImageView:create("mahjong_tile/tishi.png")
    self._discardedCardIndicator:setAnchorPoint(cc.p(0.5, 0.5))
    self._lastDiscard = nil
    self._listRules = seekNodeByName(uiRoot, "listRules", "ccui.Text")
    uiRoot:addChild(self._discardedCardIndicator)
    self._destopSkin = seekNodeByName(uiRoot, "z_logo_z_Scene", "cc.Sprite")
    self._destopSkinBg = seekNodeByName(uiRoot, "Img_logo_Scene", "cc.Sprite")
    self._destopSkinBig = seekNodeByName(uiRoot, "Img_tible_Scene", "ccui.ImageView")
    self._btnCopyRoom = seekNodeByName(uiRoot, "Button_wxyq_copyroom_Scene", "ccui.Button");
    self._btnClubInvite = seekNodeByName(uiRoot, "Button_clubInvite", "ccui.Button")
    self._btnFriendInvite = seekNodeByName(uiRoot, "Button_friendInvite", "ccui.Button")
    self._btnDingDingInvite = seekNodeByName(uiRoot, "btnDingDingInvite", "ccui.Button")

    self._imgbg_bottom = seekNodeByName(uiRoot, "Img_bottom_direction_Scene", "cc.Sprite")
    self._imgbg_right = seekNodeByName(uiRoot, "Img_right_direction_Scene", "cc.Sprite")
    self._imgbg_top = seekNodeByName(uiRoot, "Img_top_direction_Scene", "cc.Sprite")
    self._imgbg_left = seekNodeByName(uiRoot, "Img_left_direction_Scene", "cc.Sprite")
    self._imgbg = seekNodeByName(uiRoot, "Img_direction_Scene", "cc.Sprite")
    self._imgbg1 = seekNodeByName(uiRoot, "BG", "ccui.ImageView")
    -- 极速模式提示
    self._fastModeLayout = seekNodeByName(uiRoot, "Panel_extremeSpeed", "ccui.Layout")
    self._fastModeX, self._fastModeY = self._fastModeLayout:getPosition()
    self._fastModeLayout:setVisible(false)
    self._fastModeLayout:setLocalZOrder(10000)

    -- 离线提示
    self._panelOffline = seekNodeByName(uiRoot, "Panel_Offline", "ccui.Layout")
    self._offlineX, self._offlineY = self._panelOffline:getPosition()
    self._panelOffline:setVisible(false)
    self._panelOffline:setLocalZOrder(10000)

    -- 锦鲤提示
    self._panelKoi = seekNodeByName(uiRoot, "Panel_Koi", "ccui.Layout")
    self._koiX, self._koiY = self._panelKoi:getPosition()
    self._panelKoi:setVisible(false)
    self._panelKoi:setLocalZOrder(10000)

    -- 托管提示
    self._panelTrustTip = seekNodeByName(uiRoot, "Panel_TrustTip", "ccui.Layout")
    self._trustTipX, self._trustTipY = self._panelTrustTip:getPosition() 
    self._panelTrustTip:setLocalZOrder(10000)
    self._panelTrustTip:setVisible(false)

    -- 初始化UI组件
    self._uiBattery = UIElemBattery.new(uiRoot)
    self._uiTime = UIElemTime.new(uiRoot)
    self._uiNetwork = UIElemNetwork.new(uiRoot)
    self._huHandler = Hus.UIRoom_SingleHu.new(uiRoot, self._huMask)

    self._clubRoomId = nil -- 亲友圈房间id

    self._inviteBtns = {
        self._btnInviteRoom,
        self._btnMoreFriend,
        self._btnDingDingInvite,
        self._btnClubInvite,
        self._btnFriendInvite,
    }

    bindEventCallBack(self._btnInviteRoom, handler(self, self._onClickInviteButton), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnMoreFriend, handler(self, self._onClickInviteButton), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnQuitRoom, handler(self, self._onClickQuitRoomButton), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnQuitRoom_Acting, handler(self, self._onClickQuitRoomButton_Acting), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnDestoryRoom, handler(self, self._onClickDestoryRoomButton), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnCopyRoom, handler(self, self._onClickCopyButton), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnAdvanceRoom, handler(self, self._onClickAdvanceRoomButton), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnClubInvite, handler(self, self._onClickClubInvite), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFriendInvite, handler(self, self._onClickFriendInvite), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDingDingInvite, handler(self, self._onClickDingDingInvite), ccui.TouchEventType.ended)

    --根据地区配置设置背景图片(贵阳是鸡,潮汕是狗)
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local bgImgList = MultiArea.getPlayerSceneBgImg(areaId);
    local isClassic = game.service.GlobalSetting.getInstance().isClassic and not config.getIs3D()

    if not config.getIs3D() and isClassic then
        self._imgbg_bottom:setPositionY(self._imgbg_bottom:getPositionY() - 8)
        self._imgbg_right:setPositionX(self._imgbg_right:getPositionX() + 8)
        self._imgbg_top:setPositionY(self._imgbg_top:getPositionY() + 8)
        self._imgbg_left:setPositionX(self._imgbg_left:getPositionX() - 8)
    end

    if config.getIs3D() then
        self._destopSkinBg:setTexture(isClassic and bgImgList.bgImgClassice_3d or bgImgList.bgImg_3d)

    else
        self._destopSkinBg:setTexture(isClassic and bgImgList.bgImgClassice or bgImgList.bgImg)
    end

    self._imgbg1:setVisible(not isClassic)

    if bgImgList.textImg == "" then
        self._destopSkin:setVisible(false);
    else
        self._destopSkin:setTexture(bgImgList.textImg)
    end

    -- self._destopSkin:setTexture(Constants.SpecialEvents.getDestopSkin())
    self._roomSettings = nil;

    --TODO
    --展示的鬼牌先存在这里,如果不好以后考虑换地方
    self.guiCards = {}

    -- 加载默认桌布
    self:onChangeDestop(game.service.LocalPlayerSettingService:getInstance():getTableBackgound())

    local campaignService = game.service.CampaignService.getInstance();
    campaignService:addEventListener("EVENT_CAMPAIGN_RANK_CHANGED",	handler(self, self.onCampaignRankChange), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_CHANGEUI",	handler(self, self.onCampaignRankChange), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_RANK_HIDE",	handler(self, self.onCampaignHideRank), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_RANK_DISPLAY",	handler(self, self.onCampaignDisplayRank), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_CHANGE_COUNTDOWN",	handler(self, self.onChangeCountDown), self)
    game.service.ActivityService:getInstance():addEventListener("EVENT_ACTIVITY_KOI", handler(self, self._playKoiAnim), self)
    -- 监听一下断线重连
    game.service.LoginService:getInstance():addEventListener("USER_DATA_RETRIVED", function()
		self:showFastMode(true)
	end, self)

    game.service.LoginService:getInstance():addEventListener("BC_VOTE_START_BATTLEINFO_SYN", function ()
        self._timerScheduler3 = scheduleOnce(function()
            self:showInviteButton(false)
            self._btnAdvanceRoom:setVisible(false)
            self:hideAdvanceBtn()
            self._timerScheduler3 = nil
        end, 0.2)
    end, self)
end

-- 初始化UI
-- @param uiRoot, 坐在的UI模块
function UIRoom:initialize()
    self:clearData();
    self:hideDiscardedCardIndicator()
end

function UIRoom:_createCountDownLayoutAndAddInContainer(layoutContainer)
    local layout = nil
    local is3dMode = config.getIs3D()
    local isClassic = game.service.GlobalSetting.getInstance().isClassic
    if is3dMode then
        -- if isClassic then
        --     layout = kod.LoadCSBNode(PLAYER_COUNT_DOWN_CSB_3D_ICLASSIC)
        -- else
            layout = kod.LoadCSBNode(PLAYER_COUNT_DOWN_CSB_3D)
        -- end
    else
        layout = kod.LoadCSBNode(PLAYER_COUNT_DOWN_CSB)
    end
    -- 避免这个layout压住牌
    layoutContainer:addChild(layout, 1)
    local size = layoutContainer:getContentSize()
    layout:setPosition(size.width * 0.5, size.height * 0.5)
    return layout
end

function UIRoom:_findCountDownLayoutWidgets(layout)
    -- 要求2d和3d的命名相同
    self._textCounter = ccui.Helper:seekNodeByName(layout, "UNI_BMFont_Counter")
    self._textRoundCount = ccui.Helper:seekNodeByName(layout, "UNI_Text_Round_Count")
    self._textRemainCardCount = ccui.Helper:seekNodeByName(layout, "UNI_Text_Remain_Card_Count")
    self._textGoldRoomGrade = ccui.Helper:seekNodeByName(layout, "UNI_Text_Gold_Room_Grade")
    self._textGoldBaseScore = ccui.Helper:seekNodeByName(layout, "UNI_Text_Gold_Base_Score")
    self._textTrustTip = ccui.Helper:seekNodeByName(layout, "Text_TrustDownTip")
    self._textTrustTip:getParent():setVisible(false)
end

--[[0
    刷新控件的显示与隐藏，通用的控件赋值不在这里
]]
function UIRoom:_refreshCountDownLayoutWidget()
    local is3dMode = config.getIs3D()
    local isInCampaignBattle = campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign()
    local isInGoldBattle = game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold
    if isInCampaignBattle then
        -- 在比赛场中
        self._textGoldRoomGrade:setVisible(false)
        self._textGoldBaseScore:setVisible(false)
        self._lableRoomNumber:setVisible(false)
        self._listRules:setVisible(false)
        
        self._labelCampaignRank:setVisible(true)
    elseif isInGoldBattle then
        -- 在金币场中
        self._textRoundCount:setVisible(false)
        local goldService = game.service.GoldService.getInstance()
        local roomInfo = goldService:getRoomInfo(goldService:getCurrentRoomGrade())
        if roomInfo then
            self._textGoldBaseScore:setString("底分:" .. roomInfo.bottomScore)
            self._textGoldRoomGrade:setString(goldService:getRoomName(roomInfo.grade))
            self._textGoldBaseScore:setVisible(true)
            self._textGoldRoomGrade:setVisible(true)
        else
            self._textGoldRoomGrade:setVisible(false)
            self._textGoldBaseScore:setVisible(false)
        end
        self._lableRoomNumber:setVisible(false)
        self._labelCampaignRank:setVisible(false)
        self._listRules:setVisible(false)
    else
        -- 在普通的房间内（大厅创建的房间或者俱乐部）
        self._textRoundCount:setVisible(true)
        self._lableRoomNumber:setVisible(true)
        self._listRules:setVisible(true)
        
        self._textGoldRoomGrade:setVisible(false)
        self._textGoldBaseScore:setVisible(false)
        self._labelCampaignRank:setVisible(false)
    end
end

function UIRoom:dispose()
    self:_unschedule()
    self._uiBattery:dispose();
    self._uiTime:dispose()
    self._uiNetwork:dispose();
    self:clearData();
    self:clearGuiPai();
    game.service.CampaignService.getInstance():removeEventListenersByTag(self);
    game.service.RoomService.getInstance():removeEventListenersByTag(self)
    game.service.LoginService:getInstance():removeEventListenersByTag(self)
    game.service.ActivityService:getInstance():removeEventListenersByTag(self)
    
    UIManager:getInstance():destroy("UISetting")
    if self._discardedCardIndicator then
        self._discardedCardIndicator:removeFromParent()
        self._discardedCardIndicator = nil
    end
    self._countDownLayout:removeFromParent(true)
    
    -- 检查是不是还有没有解除引用的card
    -- CardFactory:getInstance():releaseAllCards()
end

function UIRoom:_unschedule()
    if self._timerScheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
        self._timerScheduler = nil
    end

    if self._trustTimeScheduler then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._trustTimeScheduler)
        self._trustTimeScheduler = nil
    end 

    if self._timerScheduler2 ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler2)
        self._timerScheduler2 = nil
    end

    if self._timerScheduler3 ~= nil then
        unscheduleOnce(self._timerScheduler3)
        self._timerScheduler3 = nil
    end

    if self._timerScheduler4 ~= nil then
        unscheduleOnce(self._timerScheduler4)
        self._timerScheduler4 = nil
    end

    if self._timerScheduler5 ~= nil then
        unscheduleOnce(self._timerScheduler5)
        self._timerScheduler5 = nil
    end

    if self._timerScheduler6 ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler6)
        self._timerScheduler6 = nil
    end
end

function UIRoom:onChangeDestop(id)
    -- 经典模式
    if game.service.GlobalSetting.getInstance().isClassic and not config.getIs3D() then
        id = "classic"
    end
    
    local skin = config.UIDestops[string.format("%s_%s", config.getIs3D() and "3D" or "2D", id)]
    
    if skin then
        self._destopSkinBig:loadTexture(skin)
        self._destopSkinBig:setContentSize({["width"] = display.width, ["height"] = display.height})
    end
end

function UIRoom:clearData()
    self:_unschedule()
    self:setRoomId();
    self:showInviteButton(false)
    self:showQuitRoomButton(true)
    self:setRoundCount()
    self:setCardCount()
    self:showGameUI(false)
    if self._huHandler then
        self._huHandler:clear()
    end

    self:_initCountdown()
    self:_refreshCountDownLayoutWidget()
end

-- 设置倒计时时间
function UIRoom:_initCountdown()
    self.campaignCountDown = 12
    if game.service.RoomService:getInstance():isFastMode() then
        self.campaignCountDown = 10
    end

    -- 托管倒计时
    self._trustCountDown = 0 
    self._remainCountDown = nil
end

function UIRoom:getHuHandler()
    return self._huHandler
end

-- 设置房间号
function UIRoom:setRoomId(roomId)
    local text = ""
    
    if roomId ~= nil then
        self._clubRoomId = roomId
        text = string.format("房间号:%06d", roomId);
        self._lableRoomNumber:setString(text)
    end
end

function UIRoom:onCampaignRankChange()
    if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() then
        
        local gameService = gameMode.mahjong.Context.getInstance():getGameService()
        self:setRoundCount(gameService:getCurrentRoundCount(), gameService:getMaxRoundCount())
        
        if game.service.CampaignService.getInstance():getCampaignList():getCurrentCampaignId() == config.CampaignConfig.ARENA_ID then
            self._textRoundCount:setVisible(false)
        end
        
        local text = ""
        local campaignService = game.service.CampaignService.getInstance()
        
        -- 如果是arena决赛 需要客户端自己算排名
        local isArenaFinal = campaignService:getArenaService():getIsFinal()
        if isArenaFinal then
            local playerMap = game.service.RoomService:getInstance():getPlayerMap()
            local myRank = 1
            local myPoint = campaignService:getCampaignData():getTotalPoint()
            table.foreach(playerMap, function(k, v)
                if v.totalPoint > myPoint then
                    myRank = myRank + 1
                end
            end)
            text = campaignService:getCampaignData():getCampaignName() .. " 排名:" .. myRank .. "/" .. campaignService:getCampaignData():getPlayerCount();
        else
            local rank = campaignService:getCampaignData():getRank()
            -- 如果为最后一名 且有人分数比自己低就排名-2
            if campaignService:getCampaignData():getRank() == campaignService:getCampaignData():getPlayerCount() then
                local hasSomeoneHigher = false
                local playerMap = game.service.RoomService:getInstance():getPlayerMap()
                local myPoint = campaignService:getCampaignData():getTotalPoint()
                table.foreach(playerMap, function(k, v)
                    if v.totalPoint < myPoint then
                        hasSomeoneHigher = true
                    end
                end)
                if hasSomeoneHigher then
                    rank = (rank -2) > 0 and (rank -2) or 1
                end
            end
            text = campaignService:getCampaignData():getCampaignName() .. " 排名:" .. rank .. "/" .. campaignService:getCampaignData():getPlayerCount();
        end
        self._labelCampaignRank:setString(text)
    end
end
--金币场UI修改
function UIRoom:_changeGoldUI()
    local goldService = game.service.GoldService.getInstance()
    local goldRoomInfo = goldService.dataRoomInfo.goldRooms[goldService:getCurrentRoomGrade()]
    
    self._listRules:setVisible(false)
    self._lableRoomNumber:setVisible(false)
    --如果取不到房间数据就不处理了
    if not goldRoomInfo then
        return
    end
    
    self._lableCardCount:setVisible(false)
    if self._lableCardBg ~= nil then
        --self._lableCardBg:setVisible(false)
    end
    self._lableRoundCount:setVisible(false)
    
    self._lableCardCountGold:setVisible(true)
    self._labelRoomGrade:setVisible(true)
    self._labelRoomBottomScore:setVisible(true)
    
    self._labelRoomBottomScore:setString("底分:" .. goldRoomInfo.bottomScore)
    
    self._labelRoomGrade:setString(goldService:getRoomName(goldRoomInfo.grade))
    
end

function UIRoom:onCampaignHideRank()
    self._labelCampaignRank:setVisible(false)
end

function UIRoom:onCampaignDisplayRank()
    self._labelCampaignRank:setVisible(true)
end

-- 设置当前/总共局数
function UIRoom:setRoundCount(currentCount, maxCount)
    local text = ""
    if currentCount ~= nil and maxCount ~= nil then
        text = string.format("%d/%d局", currentCount, maxCount)
    end
    self._textRoundCount:setString(text)
end

-- 设置剩余牌数量
function UIRoom:setCardCount(count)
    local text = ""
    if count ~= nil then
        text = string.format("剩余%d张", count)
    end
    
    self._textRemainCardCount:setString(text)
end

-- 显示屏幕中部的游戏信息界面
-- 包括:倒计时, 东南西北指示, 剩余牌数, 局数文本
function UIRoom:showGameUI(tf)
    -- self._layoutDirection:setVisible(tf)
    self._countDownLayout:setVisible(tf or false)
end

-- --根据是否开始更多分享,以及不同房间来控制按钮显示格局及样式
function UIRoom:showInviteButton(tf)
    --提审相关（微信分享按钮隐藏） 如果已经开始第一局也不显示了
    if GameMain.getInstance():isReviewVersion() then
        tf = false
    end
    -- 显示的按钮数,默认有好友邀请
    local showBtnCount = 1
    -- 如果绑定了钉钉增加钉钉分享按钮
    if game.service.LocalPlayerService.getInstance():getIsBindDingTalk() then
        showBtnCount = showBtnCount + 1
        self._btnDingDingInvite:setVisible(tf)
    else
        self._btnDingDingInvite:setVisible(false)
    end
    
    local roomService = game.service.RoomService.getInstance()
    -- 俱乐部房间才能显示俱乐部邀请按钮,只有一个按钮时做一下居中显示
    if roomService:getRoomClubId() ~= 0 then
        self._btnClubInvite:setVisible(tf)
        showBtnCount = showBtnCount + 1
    else
        self._btnClubInvite:setVisible(false)
    end
    self._btnFriendInvite:setVisible(false)
    
    local enableMoreShare = game.service.GlobalSetting.getInstance().enableMoreShare
    self._btnInviteRoom:setVisible(tf and(not enableMoreShare))
    self._btnMoreFriend:setVisible(tf and enableMoreShare)
    self._btnCopyRoom:setVisible(false)

    if tf then
        self:changeBtnPos(showBtnCount)
    end
end

-- 修正显示的按钮位置
function UIRoom:changeBtnPos(showBtnCount)
    local index = 1
    local btnPos = {}
    if showBtnCount == 1 then
        btnPos = {0.5}
    elseif showBtnCount == 2 then
        btnPos = {0.3, 0.7}
    else
        btnPos = {0.15, 0.5, 0.85}
    end
    table.walk(self._inviteBtns, function(btn, key)
        if btn:isVisible() then
            btn:setPositionPercent(cc.p(btnPos[index], 0.5))
            index = index + 1
        end
    end)
end

-- 显示退出/解散按钮
function UIRoom:showQuitRoomButton(tf, isHost, isActingCreate, isShowQuit)

    if tf == true then
        -- 如果已经开始第一局也不显示了
        if isActingCreate then
            self._btnQuitRoom:setVisible(not isShowQuit)
            self._btnDestoryRoom:setVisible(isShowQuit)
        else
            self._btnQuitRoom:setVisible(isHost == false)
            self._btnDestoryRoom:setVisible(isHost)
        end
        self:refreshAdvanceBtn()
        
        local ss = isActingCreate and isShowQuit
        self._btnQuitRoom_Acting:setVisible(isActingCreate and isShowQuit)
    else
        self._btnQuitRoom:setVisible(false)
        self._btnDestoryRoom:setVisible(false)
        self._panelAdvanceRoom:setVisible(false)
        self._btnAdvanceRoom:setVisible(false)
        self._btnQuitRoom_Acting:setVisible(false)
    end
end

function UIRoom:refreshAdvanceBtn()
    local player = game.service.RoomService:getInstance():getPlayerMap() or {}
    local playerNum = 0
    for i,val in pairs(player) do
        playerNum = playerNum + 1
    end
    local rule = game.service.RoomService:getInstance():getRuleTextIfAdvance() 
    local maxPlayerCount = game.service.RoomService:getInstance():getMaxPlayerCount()
    local btnDisplay = game.service.RoomService:getInstance():getCanEarlyBattle() and playerNum > 1 and game.service.RoomService:getInstance():getAdvanceStartSwitch() and playerNum < maxPlayerCount
    local roomLeagueId = game.service.RoomService:getInstance():getRoomLeagueId()
    --8.27 产品：赵强联盟牌桌不显示立即开局
    if roomLeagueId ~= 0 then 
        self._panelAdvanceRoom:setVisible(false)
    else
        self._panelAdvanceRoom:setVisible(btnDisplay)
        self._btnAdvanceRoom:setVisible(btnDisplay)
        self._advanceRoomText:setString("立即开局(" .. rule .. ")")
        self._advanceChickenText:setString(playerNum .. "个人也能开") 

    end 
end

function UIRoom:hideAdvanceBtn()
    self._panelAdvanceRoom:setVisible(false)
    self._btnAdvanceRoom:setVisible(false)
    local seatUI = self.uiRoot:getSeatUI(CardDefines.Chair.Down)
    if seatUI ~= nil then
        local roomseat =  seatUI:getRoomSeat()
        local isReady = false
        local context = gameMode.mahjong.Context.getInstance()
        if roomseat ~= nil and context ~= nil then
            isReady = roomseat:getPlayer():isReady() and context:getGameService():isGameStarted() == false
        end
        seatUI:setPlayerReady(isReady)
    end
end

-- 提前开局按钮上的文字刷新
function UIRoom:refreshStartText()
    local rule = game.service.RoomService:getInstance():getRuleTextIfAdvance() 
    self._advanceRoomText:setString("立即开局(" .. rule .. ")")
end

-------------------
-- 计时相关
-- 开始计时
-- @param: chair 当前要出牌的玩家
function UIRoom:doCountDown(chair)
    --TODO:倒计时金币场这里完全也用比赛场那样子的,如果不一样以后改
    local flag = campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() or
    game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold or
    game.service.RoomService:getInstance():isFastMode() 
    self._countDownTimer = flag and self.campaignCountDown or 12
    if (game.service.LocalPlayerService:getInstance():getHistoryRecordService():isFastMode() and UIManager:getInstance():getIsShowing("UIPlayback")) then
        self._countDownTimer = 10
    end

    if self._remainCountDown and self._remainCountDown >= 0 then 
        self._countDownTimer = self._remainCountDown
    end

    self:setString_Time(self._countDownTimer)
    self:cancelCountDown();
    self._timerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
    function()
        self:_timerCallback(chair)
    end, 1, false)
end

-- 设置倒计时时间
function UIRoom:setString_Time(time)
    self._textCounter:setString(tostring(time))
    -- 因为字体的原因调整下x pos，两位数往左，一位数往右，基准值是0
    if time > 9 then
        self._textCounter:setPositionX(- 2)
    else
        self._textCounter:setPositionX(1)
    end
end

-- 取消倒计时
function UIRoom:cancelCountDown()
    if self._timerScheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
        self._timerScheduler = nil
    end
end

-- @param: chair 当前要出牌的玩家，如果要出牌的玩家是自己（DOWN，如果是回放的时候，或者观战的时候，DOWN是不同于Localplayer）
function UIRoom:_timerCallback(chair)
    if self._countDownTimer > 0 then
        self._countDownTimer = self._countDownTimer - 1
    end
    
    self:setString_Time(self._countDownTimer)
    
    -- 产品要求倒计时剩余3秒时震动一次
    if self._countDownTimer == 3 then
        --手机震动，只有倒计时的玩家是DOWN的座位的时候，才进行震动
        if chair == CardDefines.Chair.Down then
            game.plugin.Runtime.shake()
        end
        -- 播放倒计时音效
        -- manager.AudioManager.getInstance():playEffect("sound/SFX/Countdown/countdown_1.mp3")
    end
    
    if self._countDownTimer == 0 then
        if self._trustCountDown > 0 then 
            self:_startTrustCountDown(chair, true)
            self._remainCountDown = nil  
        end 
        self:cancelCountDown()
        game.service.DataEyeService.getInstance():onEvent("PlayCard_Timeout")
    end
end

-------------------------------- 托管倒计时相关 --------------------------------
-- 获取托管限定秒数
function UIRoom:_getTrustLimitSec()
    local trustType = game.service.RoomService:getInstance():getTrustType()
    if not trustType then 
        return 
    end 

    local limitTab = { 
        [RoomSetting.GamePlay.COMMON_TRUSTEESHIP_60] = 60, 
        [RoomSetting.GamePlay.COMMON_TRUSTEESHIP_180] = 180, 
        [RoomSetting.GamePlay.COMMON_TRUSTEESHIP_300] = 300,
    }
    
    return limitTab[trustType]
end 

--[[
@function: 托管开始计时,设置托管最新倒计时时间
@pram: 服务器返回的秒数
    若 sec 大于限定秒数，则当前倒计时 = sec - 限定； 托管倒计时 = 限定
    若 sec 小于等于限定秒数, 则当前倒计时为0， 托管倒计时 = sec 
]]
function UIRoom:onChangeCountDown(event)
    local sec = event.sec
    if self.campaignCountDown ~= sec then
        local limitSec = self:_getTrustLimitSec()
        if not limitSec then 
            return 
        end 

        if sec > limitSec then 
            self._remainCountDown = sec - limitSec
            self._trustCountDown = limitSec
        else 
            self._remainCountDown = 0
            self._trustCountDown = sec 
        end 
    end 
end

-- 托管倒计时相关
function UIRoom:_startTrustCountDown(chair)
    -- 倒计时相关
    self:cancelTrustCountDown()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    local function _update()
        self._trustCountDown = self._trustCountDown - 1
        self._textTrustTip:setString(string.format("操作玩家%d秒后进入托管模式", self._trustCountDown))
        --[[
        if chair == CardDefines.Chair.Down then 
            self._textTrustTip:setString(string.format("%d秒后进入托管模式", self._trustCountDown))
        else 
            self._textTrustTip:setString(string.format("出牌玩家将在%d秒后进入托管模式", self._trustCountDown))
        end 
        ]]
        self._textTrustTip:getParent():setVisible(true)

        if self._trustCountDown == 0 then 
            self:cancelTrustCountDown()
        end 
    end 
    self._trustTimeScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_update, 1, false)
end 

-- 取消托管倒计时
function UIRoom:cancelTrustCountDown()
    if self._trustTimeScheduler ~= nil then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._trustTimeScheduler)
        self._trustTimeScheduler = nil
    end 
    self._textTrustTip:getParent():setVisible(false)
end 

-- 播放托管提示动画
function UIRoom:playTrustTipAnim()
    local sec = self:_getTrustLimitSec() 
    if not sec then 
        return 
    end 

    if self._panelTrustTip:isVisible() then 
        if self._timerScheduler6 ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler6)
            self._timerScheduler6 = nil
        end

        local function _update() 
            local act1 = cc.MoveTo:create(0.5, cc.p(self._trustTipX, self._trustTipY + 100))
            local act2 = cc.CallFunc:create(function()
                self._panelTrustTip:setVisible(false)
            end)
            self._panelTrustTip:runAction(cc.Sequence:create(act1, act2))
        end 
        self._timerScheduler6 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_update, 5, false)
    end 
end 

-- 显示托管模式tip
function UIRoom:showTrustMode()
    -- 判定是否开局
    if not self._isHaveBeginFirstGame then 
        return 
    end 

    -- 判定能否获取托管限定秒数
    local sec = self:_getTrustLimitSec() 
    if not sec then 
        return 
    end 

    if not self._panelTrustTip:isVisible() then 
        local textLabel = self._panelTrustTip:getChildByName("Text_state")
        textLabel:ignoreContentAdaptWithSize(false)
        textLabel:setContentSize(cc.size(650, 80))

        local str = string.format("%d秒托管：超过%d秒未操作将进入托管状态，托管后本局自动摸打，不做其它操作(如碰杠听胡等)，本局结束后房间自动解散",sec, sec)
        textLabel:setString(str)

        self._panelTrustTip:setPosition(cc.p(self._trustTipX, self._trustTipY))
        self._panelTrustTip:setVisible(true)
    end 
end 

-------------------------------- 托管倒计时相关 --------------------------------

function UIRoom:resetDir()
    -- 是否为经典模式
    local isClassic = game.service.GlobalSetting.getInstance().isClassic and not config.getIs3D()
    
    local skins = {
        [1] = {skin = "gaming/z_dong.png", bgSkin = "gaming/Img_fx2_bottom.png"},
        [2] = {skin = "gaming/z_nan.png", bgSkin = "gaming/Img_fx2_right.png"},
        [3] = {skin = "gaming/z_xi.png", bgSkin = "gaming/Img_fx2_top.png"},
        [4] = {skin = "gaming/z_bei.png", bgSkin = "gaming/Img_fx2_left.png"},
        [5] = {skin = "", bgSkin = "gaming/Img_fx.png"},
    }
    
    if isClassic then
        skins = {
            [1] = {skin = "gaming/z_dong.png", bgSkin = "gaming/Img_fx1_bottom.png"},
            [2] = {skin = "gaming/z_nan.png", bgSkin = "gaming/Img_fx1_bottom.png"},
            [3] = {skin = "gaming/z_xi.png", bgSkin = "gaming/Img_fx1_bottom.png"},
            [4] = {skin = "gaming/z_bei.png", bgSkin = "gaming/Img_fx1_bottom.png"},
            [5] = {skin = "", bgSkin = "gaming/Img_fx_1.png"},
        }
    end
    
    local index = {
        [1] = {1, 2, 3, 4},
        [2] = {2, 3, 4, 1},
        [3] = {3, 4, 1, 2},
        [4] = {4, 1, 2, 3},
    }
    
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    local processor = gameService:getPlayerProcessorByChair(CardDefines.Chair.Down)
    local roomSeat = processor:getRoomSeat()
    local player = roomSeat:getPlayer()
    local position = player.position
    local cfg = index[position]
    self._dirDown:setTexture(skins[cfg[1]].skin)
    self._dirRight:setTexture(skins[cfg[2]].skin)
    self._dirTop:setTexture(skins[cfg[3]].skin)
    self._dirLeft:setTexture(skins[cfg[4]].skin)
    
    if not config.getIs3D() then
        self._imgbg_bottom:setTexture(skins[cfg[1]].bgSkin)
        self._imgbg_right:setTexture(skins[cfg[2]].bgSkin)
        self._imgbg_top:setTexture(skins[cfg[3]].bgSkin)
        self._imgbg_left:setTexture(skins[cfg[4]].bgSkin)
        local offset = 0
        self._imgbg:setTexture(skins[5].bgSkin)
        self._imgbg:setRotation((cfg[1] - 1) * 90 + offset)
    end
end

function UIRoom:onWaitingOperation(targetSeat)
end

-- 显示卡牌指示器
function UIRoom:markDiscardedCardIndicator(targetCard)
    if targetCard == nil then
        self._discardedCardIndicator:setVisible(true)
    else
        self._lastDiscard = targetCard
    end
    if self._lastDiscard == nil then
        return
    end
    self._discardedCardIndicator:stopAllActions()
    self._discardedCardIndicator:setVisible(true)
    local x, y = self._lastDiscard:getPosition()
    self._discardedCardIndicator:setPosition(cc.p(x, y + 26))
    local zorder = self._lastDiscard:getLocalZOrder()
    self._discardedCardIndicator:setLocalZOrder(zorder)
    
    local movedown = cc.MoveTo:create(0.8, cc.p(x, y + 60))
    local moveup = cc.MoveTo:create(0.8, cc.p(x, y + 26))
    local seq = cc.Sequence:create(movedown, moveup)
    local rep = cc.RepeatForever:create(seq)
    self._discardedCardIndicator:runAction(rep)
end

-- 隐藏牌指示器
function UIRoom:hideDiscardedCardIndicator()
    self._discardedCardIndicator:setVisible(false)
    self._discardedCardIndicator:stopAllActions()
end

--------------------------------
-- 界面按钮
function UIRoom:_onClickMoreInfoButton()
end

-- 目前先用下载链接
function UIRoom:_onClickInviteButton()
    --talkdata打点
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Room_Invite_Click)
    -- 将分享内容，整理到一张UI上面，再将此UI渲染到一个纹理
    local tip = config.GlobalConfig.getShareInfo() [1]
    if game.service.RoomService:getInstance():getRoomClubId() ~= 0 then
        local clubId = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
        local club = game.service.club.ClubService.getInstance():getClub(clubId)
        -- 玩家在亲友圈房间内被群主踢掉就会报错
        if club ~= nil then
            tip = club.info.clubName
        end
    end
    local title = "房号:[" .. game.service.RoomService:getInstance():getRoomId() .. "]"
    local content = kod.util.String.getMaxLenString(self:_getRoomRulesStr(), 76) .. "..."
    
    local data =	{
        enter = share.constants.ENTER.ROOM_INFO,
        tip = tip,
        title = title,
        content = content
    }
    local msg = title .. ", " .. content .. "开搓! 现在就等你哦!"
    local url_data = {
        enter = share.constants.ENTER.ROOM_INFO,
        shareInfo = tip,
        shareContent = msg
    }
    share.ShareWTF.getInstance():share(share.constants.ENTER.ROOM_INFO, {data, data, data})
    
end

function UIRoom:_getRoomRulesStr()
    local ret = ""
    local res = room.RoomSettingHelper.manageRuleLabels(self._roomSettings)
    for i = 1, #res do
        ret = ret .. res[i] .. ","
    end
    
    return ret
end

function UIRoom:_onClickQuitRoomButton()
    game.service.RoomService.getInstance():quitRoom()
end

function UIRoom:_onClickQuitRoomButton_Acting()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Leave_Room_Click)
    
    game.ui.UIMessageBoxMgr.getInstance():show("返回大厅将离开座位，但房间依旧保留，是否继续？", {"确定", "取消"}, function()
        game.service.RoomService.getInstance():quitRoom(false)
    end)
    
end

function UIRoom:_onClickDestoryRoomButton()
    -- android提审（应用宝）
    if device.platform == "android" and GameMain.getInstance():isReviewVersion() then
        game.ui.UIMessageBoxMgr.getInstance():show("是否确定解散该房间？", {"确定", "取消"}, function()
            game.service.RoomService.getInstance():quitRoom()
        end)
    else
        game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UIROOM_STRING_100, {"确定", "取消"}, function()
            game.service.RoomService.getInstance():quitRoom()
        end)
    end
end

function UIRoom:_onClickAdvanceRoomButton()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Button_Early_Start)
    game.service.RoomService:getInstance():sendCBStartBattleInAdvanceREQ(self._clubRoomId)
end

function UIRoom:playAnim(playType)
    local config = {
        [PlayType.DISPLAY_JI_SHOUQUAN] = "ui/csb/Effect_sqj.csb",
        [PlayType.DISPLAY_JI_CHONGFENG] = "ui/csb/Effect_chongfengji.csb",
        [PlayType.DISPLAY_JI_ZEREN] = "ui/csb/Effect_zerenji.csb",
        [PlayType.DISPLAY_JI_WUGU_CHONGFENG] = "ui/csb/Effect_cfwgj.csb",
        [PlayType.DISPLAY_JI_WUGU_ZEREN] = "ui/csb/Effect_zrwgj.csb",
        [PlayType.DISPLAY_TING] = "ui/csb/Effect_tianting.csb",
        [PlayType.OPERATE_MEN] = "ui/csb/Effect_mp.csb",
    }
    local anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(config[playType], function()
    end))
    
    return anim:getAnimTime(anim._action)
end

function UIRoom:showRoomRules(settings, ratio)
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local scoreRatio = ratio or game.service.RoomService.getInstance():getScoreRatio()
    local isFast = game.service.RoomService:getInstance():isFastMode()
    local trustType = game.service.RoomService:getInstance():getTrustType()
    self._roomSettings = settings;
    local res = room.RoomSettingHelper.manageRuleLabels(settings)
    
    if MultiArea.getIsShowRuleBox(areaId) == true then
        --如果显示规则盒子了，就不需要这个规则提示了
        self._listRules:setString("")
    else
        for i = 1, #res do
            self._listRules:setString(res[i])
        end

        if scoreRatio ~= nil and scoreRatio > 0 then
            local str = self._listRules:getString()
            self._listRules:setString(string.format("%s,赛事分系数:%s", str, scoreRatio))
        end
    end
end

-- 复制房间号
function UIRoom:_onClickCopyButton()
    local rules = self:_getRoomRulesStr()
    -- 默认分享给好友
    local url = config.GlobalConfig.getShareUrl()
    local msg = config.STRING.UIROOM_STRING_101 .. game.service.RoomService:getInstance():getRoomId() .. "], " .. rules .. "下载地址:" .. url .. "（复制此条消息打开游戏，可直接进入房间，安卓暂时无法使用此功能）"
    game.plugin.Runtime.setClipboard(msg)
    game.service.WeChatService:getInstance():openWXApp()
    game.service.TDGameAnalyticsService.getInstance():onEvent("CLICKED_COPY_ROOMID")
end

--清除场面上的鬼牌提示
function UIRoom:clearGuiPai()
    if #self.guiCards > 0 then
        for _, card in ipairs(self.guiCards) do
            CardFactory:getInstance():releaseCard(card)
        end
        self.guiCards = {}
    end
    
end

-- 俱乐部邀请
function UIRoom:_onClickClubInvite()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Room_Online_Invite)
    local roomService = game.service.RoomService.getInstance()
    UIManager:getInstance():show("UIClubRoomInviteList", roomService:getRoomClubId(), roomService:getRoomId())
end

function UIRoom:_onClickFriendInvite()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Room_Friend)
    local roomService = game.service.RoomService.getInstance()
    game.service.friend.FriendService.getInstance():sendCGQueryRoomInvitedFriendInfosREQ(roomService:getRoomId())
end

-- 钉钉邀请
function UIRoom:_onClickDingDingInvite(...)
    -- 将分享内容，整理到一张UI上面，再将此UI渲染到一个纹理
    local tip = config.GlobalConfig.getShareInfo() [1]
    if game.service.RoomService:getInstance():getRoomClubId() ~= 0 then
        local clubId = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
        local club = game.service.club.ClubService.getInstance():getClub(clubId)
        -- 玩家在亲友圈房间内被群主踢掉就会报错
        if club ~= nil then
            tip = club.info.clubName
        end
    end
    local title = "房号:[" .. game.service.RoomService:getInstance():getRoomId() .. "]"
    local content = kod.util.String.getMaxLenString(self:_getRoomRulesStr(), 76) .. "..."
    
    local data =	{
        enter = share.constants.ENTER.ROOM_INFO,
        tip = tip,
        title = title,
        content = content
    }
    local msg = title .. ", " .. content .. "开搓! 现在就等你哦!"
    local url_data = {
        enter = share.constants.ENTER.ROOM_INFO,
        shareInfo = tip,
        shareContent = msg
    }
    share.ShareWTF.getInstance():shareDing(share.constants.ENTER.ROOM_INFO, {data, data, data})
end

-- 极速模式提示是否显示
function UIRoom:showFastMode(isRetrived)
    -- 是否开局了
    self._isHaveBeginFirstGame = not game.service.RoomService:getInstance():isHaveBeginFirstGame()
    --[[
        断线重连的情况下
            断线开局 为 false
            断线没开局 按照 是否开局判断
            没断线开局 按照 是否开局判断
    ]]
    if isRetrived and isHaveBeginFirstGame then
        self._isHaveBeginFirstGame = false
    end

    self._fastModeLayout:setVisible(self._isHaveBeginFirstGame and game.service.RoomService:getInstance():isFastMode() and not self._panelOffline:isVisible())
    self._fastModeLayout:setPosition(self._fastModeX, self._fastModeY)
end

-- 极速模式动画
function UIRoom:playFastModeAim(tf)
    if tf then
        local x, y = self._fastModeLayout:getPosition()
        local move = cc.MoveTo:create(0.5, cc.p(self._fastModeX, self._fastModeY + 100))
        self._fastModeLayout:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
            self._fastModeLayout:setVisible(false)
            self._panelOffline:setVisible(tf)
            self._panelOffline:setPosition(self._offlineX, self._offlineY)
        end)))
        return
    end
    if self._fastModeLayout:isVisible() then
        if self._timerScheduler2 ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler2)
            self._timerScheduler2 = nil
        end
        self._timerScheduler2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            local x, y = self._fastModeLayout:getPosition()
            local move = cc.MoveTo:create(0.5, cc.p(self._fastModeX, self._fastModeY + 100))
            self._fastModeLayout:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
                self._fastModeLayout:setVisible(false)
            end)))
        end, 5, false)
    end
end

function UIRoom:playOfflineAim(tf)
    if tf then
        self:playFastModeAim(tf)
        self._timerScheduler4 = scheduleOnce(function()
            if not game.service.RoomService:getInstance():isHaveBeginFirstGame() then
                local roomService = game.service.RoomService:getInstance()
                local roleId = game.service.LocalPlayerService.getInstance():getRoleId() -- 自己Id
                local creatorId = roomService:getCreatorId() -- 创建者Id
                local hostId = roomService:getHostPlayer():getId() -- 房主Id
                local clubId = roomService:getRoomClubId() -- 俱乐部Id
                local isShowDismiss = hostId == roleId
                -- 代开房创建者是经理或者管理员
                local clubData = game.service.club.ClubService.getInstance():getClub(clubId)
                local isActingCreate = false
                local isShowQuit = false
                if clubData then
                    isActingCreate = clubData:isPermissions(creatorId)
                    isShowQuit = clubData:isPermissions(roleId) and creatorId == roleId
                end
                self:showQuitRoomButton(true, isShowDismiss, isActingCreate, isShowQuit)
            end
            self._timerScheduler4 = nil
        end, 0.1)
    else
        if self._panelOffline:isVisible() then
            local move = cc.MoveTo:create(0.5, cc.p(self._offlineX, self._offlineY + 100))
            self._panelOffline:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
                self._panelOffline:setVisible(false)
                local a =self._isHaveBeginFirstGame and game.service.RoomService:getInstance():isFastMode()
                self._fastModeLayout:setVisible(self._isHaveBeginFirstGame and game.service.RoomService:getInstance():isFastMode())
                self._fastModeLayout:setPosition(self._fastModeX, self._fastModeY)
            end)))
        end
    end
end

function UIRoom:_playKoiAnim()
    self._panelKoi:setVisible(true)
    self._panelKoi:setPosition(self._koiX, self._koiY)
    self._timerScheduler5 = scheduleOnce(function()
        local move = cc.MoveTo:create(0.5, cc.p(self._koiX, self._koiX + 100))
        self._panelKoi:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
            self._panelKoi:setVisible(false)
        end)))
        self._timerScheduler5 = nil
    end, 5)
end

return UIRoom