local TimeService = require("app.game.service.TimeService")

local REWARD_STATUS={
    UNOPEN = 1,
    GET = 2,
    INVALID = 3,
    NOENOUGH = 4,
}

------------------------------------------------------------------
-- 抢红包控件
local Panel_grab = class("Panel_grab")

function Panel_grab.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, Panel_grab)
	self:_initialize()
    return self
end

-- 初始化
function Panel_grab:_initialize()
    self._txtEndTips = seekNodeByName(self, "Text_time_1_hb_Clubcj", "ccui.Text")
    -- self._txtTitle = seekNodeByName(self, "Text_zbt_1_hb_Clubcj", "ccui.Text")
    self._txtSubTitle = seekNodeByName(self, "Text", "ccui.Text")
    self._btnGrab = seekNodeByName(self, "Button_qhb_1_hb_Clubcj", "ccui.Button")
    self._imgGet = seekNodeByName(self, "Image_ylq", "ccui.ImageView")

    bindEventCallBack(self._btnGrab, handler(self, self._onClickedGrab), ccui.TouchEventType.ended)
    bindEventCallBack(self, handler(self, self._onClickedGrab), ccui.TouchEventType.ended)
end

function Panel_grab:load(clubId, redPacket)
    self._clubId = clubId
    self._redPackedId = redPacket.id
    -- 记录当前的状态，用来判断是否新开启的红包
    self._status = redPacket.status

    local curTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    local info = {}
    if redPacket.expiryDate/1000-curTime/1000 > 0 then
        info.endTips = string.format("请在明天%s前领取", os.date("%H:%M", redPacket.expiryDate/1000))
        self._btnGrab:setVisible(true)
    else
        info.endTips = "已过期"
        self._btnGrab:setVisible(false)
    end
    info.title = string.format("%s", redPacket.title1)
    info.subTitle = string.format("%s", redPacket.title2)

    self._txtEndTips:setString(info.endTips)
    -- self._txtTitle:setString(info.title)
    self._txtSubTitle:setString(info.subTitle)

    if redPacket.status == REWARD_STATUS.UNOPEN then
        self._btnGrab:setVisible(true)
        self._imgGet:setVisible(false)
    elseif redPacket.status == REWARD_STATUS.GET then
        self._btnGrab:setVisible(false)
        self._imgGet:setVisible(true)
    else
        self._btnGrab:setVisible(false)
        self._imgGet:setVisible(false)
    end
end

function Panel_grab:_onClickedGrab()
    if self._status == REWARD_STATUS.GET then
        -- 统计红包的点击次数已领取
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Red_Open);
    else
        -- 统计红包的点击次数未领取
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Red);
    end

    game.service.club.ClubService.getInstance():getClubActivityService():sendCCLGainClubRedPacketREQ(self._clubId, self._redPackedId, self._status)
end

------------------------------------------------------------------
-- 红包列表控件
local Rewards = class("Rewards")

function Rewards:ctor()
end

-- 初始化
function Rewards.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, Rewards)
	self:_initialize()
    return self
end

-- 初始化
function Rewards:_initialize()
    self._listview = seekNodeByName(self, "ListView_hb_Clubcj", "ccui.ListView")
    self._panelGrab = seekNodeByName(self._listview, "Panel_1_hb_Clubcj", "ccui.Layout")
    self._panelGet = seekNodeByName(self._listview, "Panel_2_hb_Clubcj", "ccui.Layout")
    self._numOfRedPacket = seekNodeByName(self, "Text_12", "ccui.Text")
    self._btnReceive = seekNodeByName(self, "Button_1", "ccui.Button")
    self._imgTips = seekNodeByName(self, "Image_tiao", "ccui.ImageView")

    if not self._panelGrab then
        self._panelGrab = seekNodeByName(self:getParent(), "Panel_grab", "ccui.Layout")
    else
        self._panelGrab:removeFromParent()
        self:getParent():addChild(self._panelGrab)
        self._panelGrab:setVisible(false)
    end

    if not self._panelGet then
        self._panelGet = seekNodeByName(self:getParent(), "Panel_get", "ccui.Layout")
    else
        self._panelGet:removeFromParent()
        self:getParent():addChild(self._panelGet)
        self._panelGet:setVisible(false)
    end

    bindEventCallBack(self._btnReceive, function()
        game.ui.UIMessageBoxMgr.getInstance():show("请到公众号myqhd2017领取", {"复制", "取消"}, function()
            if game.plugin.Runtime.setClipboard("myqhd2017") == true then
                game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
            end
        end)
    end, ccui.TouchEventType.ended)

    self._btnReceive:setVisible(false)
    
    self._listview:removeAllItems()
end

function Rewards:load(clubId, redPacketList, todayTotalMoney)
    self._clubId = clubId
    self._listview:removeAllItems()
    table.sort(redPacketList, function(a,b)
        if a.status == b.status then
            return a.id < b.id
        end
        return a.status < b.status
    end)
    for i=1,#redPacketList do
        local redPacket = redPacketList[i]
        local item = Panel_grab.extend(self._panelGrab:clone(), self._clubId, redPacket)
        item:setVisible(true)
        item:load(self._clubId, redPacket)
        self._listview:addChild(item)
    end
    self._listview:requestDoLayout()
    self._listview:doLayout()

    self._imgTips:setVisible(#redPacketList == 0)

    local club = game.service.club.ClubService:getInstance():getClub(self._clubId)
    local numOfRedPacket = club and club:numOfRedPacket() or 0
    local redPacketNum = string.format("已抢红包数额:%0.2f元", todayTotalMoney / 100)
    self._numOfRedPacket:setString(redPacketNum)
end

------------------------------------------------------------------
-- 抢手机界面控件
local GrabPhone = class("GrabPhone")

function GrabPhone:ctor()
end

-- 初始化
function GrabPhone.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, GrabPhone)
	self:_initialize()
    return self
end

function GrabPhone:_initialize()
    self._txtActivityTime = seekNodeByName(self, "Text_9_0", "ccui.Text")
    self._txtActivityRewardTimes = seekNodeByName(self, "Text_12", "ccui.Text")
    self._txtNoRewardTips = seekNodeByName(self, "Text_18", "ccui.Text")
    self._btnGet = seekNodeByName(self, "Button_4", "ccui.Button")
    self._btnGrab = seekNodeByName(self, "Button_cj", "ccui.Button")

    self._canGrab = false

    bindEventCallBack(self._btnGet, handler(self, self._onClickedGet), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnGrab, handler(self, self._onClickedGrab), ccui.TouchEventType.ended)
end

function GrabPhone:load(clubId, lotteryInfo)
    self._clubId = clubId
    local info = {}
    info.title = string.format("%s", PropReader.getNameById(lotteryInfo.itemId))
    local club = game.service.club.ClubService:getInstance():getClub(self._clubId)
    info.activityTime = string.format("抽奖时间:每日 %s - %s", os.date("%H:%M",lotteryInfo.startTime/1000), os.date("%H:%M",lotteryInfo.endTime/1000))
    info.rewardTimes = string.format("当前持有奖券:%s", lotteryInfo.lotteryCount)
    info.showtips = lotteryInfo.awardCount <= 0

    self._canGrab = lotteryInfo.awardCount > 0 and lotteryInfo.lotteryCount > 0
    self._btnGrab:setTouchEnabled(self._canGrab)
    self._btnGrab:setEnabled(self._canGrab)

    self._txtActivityTime:setString(info.activityTime)
    self._txtActivityRewardTimes:setString(info.rewardTimes)
    self._txtNoRewardTips:setVisible(info.showtips)
end

function GrabPhone:_onClickedGet()
    -- 统计领取奖励按钮点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Receive_Award);

    game.service.GiftService:getInstance():queryGoods()
end

function GrabPhone:_onClickedGrab()
    -- 统计抽奖按钮的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Lottery);

    game.service.club.ClubService.getInstance():getClubActivityService():sendCCLDrawLotteryREQ(self._clubId)
end

------------------------------------------------------------------
local SHOW_TYPE = {
    REWARD = 1,
    GRAB = 2,
}

------------------------------------------------------------------
local csbPath = "ui/csb/Club/UIClubRedBox.csb"
local super = require("app.game.ui.UIBase")
local UIClubRedBox = class("UIClubRedBox", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubRedBox:ctor()
    self._currType = nil
end

--析构函数
function UIClubRedBox:destroy()
	--释放内存
end

--初始化函数
function UIClubRedBox:init()
    --这里可以写成员的定义等
    self._checkGrabReward = seekNodeByName(self, "CheckBox_1_Clubcj", "ccui.CheckBox")
    self._checkGrabPhone = seekNodeByName(self, "CheckBox_1_Clubcj_0", "ccui.CheckBox")
    self._btnClosed = seekNodeByName(self, "Button_Close_Clubcj", "ccui.Button")

    self._listReward = Rewards.extend(seekNodeByName(self, "Panel_hb_Clubcj", "ccui.Layout"))
    self._grabPhone = GrabPhone.extend(seekNodeByName(self, "Panel_sj_Clubcj", "ccui.Layout"))

    bindEventCallBack(self._checkGrabReward, handler(self, self._onClickedReward), ccui.TouchEventType.ended)
    bindEventCallBack(self._checkGrabPhone, handler(self, self._onClickedPhone), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClosed, handler(self, self._onClickedClose), ccui.TouchEventType.ended)

    self._checkGrabPhone:setVisible(false)
    self._grabPhone:setVisible(false)
end

--显示函数
function UIClubRedBox:onShow(clubId)
    --界面显示逻辑
    self._clubId = clubId
    Macro.assertTrue(self._clubId == nil)
    local clubActivityService = game.service.club.ClubService.getInstance():getClubActivityService()
    clubActivityService:addEventListener("EVENT_CLUB_REDPACKET_GET", handler(self, self._onRewardArrive), self)
    clubActivityService:addEventListener("EVENT_CLUB_GRABINFO", handler(self, self._onGrabInfoArrive), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_DATA_RETRIVED", function(event)
        -- 检查下活动是否还在开启
        self:_checkActivity()
        self:_sendRequest(event.clubId)
    end, self)
    game.service.LoginService:getInstance():addEventListener("USER_DATA_RETRIVED",  handler(self, self._onRegisterAgain), self)

    -- self:_change(self._currType or SHOW_TYPE.REWARD)
    self:_change(SHOW_TYPE.REWARD)
end

--隐藏函数
function UIClubRedBox:onHide()
	--界面隐藏逻辑
    game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
    
    game.service.LoginService:getInstance():removeEventListenersByTag(self)
end

--返回界面层级
function UIClubRedBox:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRedBox:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

--是否需要遮罩
function UIClubRedBox:needBlackMask()
	return true
end

--关闭时操作
function UIClubRedBox:closeWhenClickMask()
	return false
end

-- 标记为Persistent的UI不会destroy
function UIClubRedBox:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIClubRedBox:isFullScreen()
	return false;
end

--自己的逻辑
--TODO:
function UIClubRedBox:_onClickedReward()
    -- 统计红包页签的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Red_Mark);

    self:_change(SHOW_TYPE.REWARD)
end

function UIClubRedBox:_onClickedPhone()
    -- 统计抽奖页签的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Lottery_Mark);
    
    self:_change(SHOW_TYPE.GRAB)
end

function UIClubRedBox:_change(currType)
    self._currType = currType
    -- 检查下活动是否还在开启
    self:_checkActivity()
    if self._currType == SHOW_TYPE.REWARD then
        self._checkGrabReward:setSelected(true)
        self._checkGrabPhone:setSelected(false)
        self._listReward:setVisible(true)
        self._grabPhone:setVisible(false)
        self:_hasClubData()
    elseif self._currType == SHOW_TYPE.GRAB then
        self._checkGrabReward:setSelected(false)
        self._checkGrabPhone:setSelected(true)
        self._listReward:setVisible(false)
        self._grabPhone:setVisible(true)
        self:_hasClubData()
    end
end

-- 检查下活动是否还在开启
function UIClubRedBox:_checkActivity()
    -- local clubService = game.service.club.ClubService.getInstance()
    -- local club = clubService:getClub(self._clubId)
    -- local show = clubService:isMeManager(self._clubId) and club.data and club.data.hasLotteryActivity
    -- if show then
    --     self._checkGrabPhone:setVisible(true)
    -- else
        self._checkGrabPhone:setVisible(false)
    -- end

    if not show and self._currType == SHOW_TYPE.GRAB then
        self._currType = SHOW_TYPE.REWARD
    end
end

function UIClubRedBox:_onClickedClose()
    UIManager:getInstance():hide("UIClubRedBox")
end

function UIClubRedBox:_onRewardArrive(event)
    self._listReward:load(self._clubId, event.redPacketList, event.todayTotalMoney)
end

function UIClubRedBox:_onGrabInfoArrive(event)
    self._grabPhone:load(self._clubId, event.lotteryInfo)
end

-- 判断club.data是否为空，为空时先请求一下亲友圈数据，在回调里去请求数据
function UIClubRedBox:_hasClubData()
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    if club == nil then
        return
    end
    if club.data == nil then
        clubService:tryQueryDirtyClubData(self._clubId)
        return
    end

    self:_sendRequest(self._clubId)
end

function UIClubRedBox:_sendRequest(clubId)
    if clubId ~= self._clubId then
        return
    end
    if self._currType == SHOW_TYPE.REWARD then
        game.service.club.ClubService.getInstance():getClubActivityService():sendCCLQueryRedPacketListREQ(self._clubId)
    elseif self._currType == SHOW_TYPE.GRAB then
        game.service.club.ClubService.getInstance():getClubActivityService():sendCCLQueryClubLotteryInfoREQ(self._clubId)
    end
end

function UIClubRedBox:_onRegisterAgain()
    self:_sendRequest(self._clubId)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRedBox:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubRedBox