local csbPath = "ui/csb/UIEarlyStartVote.csb"
local super = require("app.game.ui.UIBase")
local room = require( "app.game.ui.RoomSettingHelper" )

local PlayerIconComponent = class("PlayerIconComponent")
function PlayerIconComponent:ctor( self, uiroot)
    self._playerIcon = nil
    self._playerName = nil
    self._textVoting = nil
    self._textAgree = nil

    self._playerIcon = seekNodeByName(uiroot, "Image_PlayerIcon", "ccui.ImageView")
    self._playerName = seekNodeByName(uiroot, "TextPlayerName", "ccui.Text")
    self._textVoting = seekNodeByName(uiroot, "Text_voting", "ccui.Text")
    self._textAgree = seekNodeByName(uiroot, "Text_agree", "ccui.Text")
    self._textDisagree = seekNodeByName(uiroot, "")
end

function PlayerIconComponent:setData(playerIcon,playerName,headFrame)
    game.util.PlayerHeadIconUtil.setIcon(self._playerIcon, playerIcon);
    self._textAgree:setVisible(false)
    self._textVoting:setVisible(true)
    self._playerName:setString(kod.util.String.getMaxLenString(playerName, 8))
end

function PlayerIconComponent:agree()
    self._textAgree:setVisible(true)
    self._textVoting:setVisible(false)
end

local UIEarlyStartVote = class("UIEarlyStartVote",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

function UIEarlyStartVote:ctor()
   self._applyText = nil
   self._textCountdown = nil
   self._btnDisagree = nil
   self._btnAgree = nil

   -- 头像列表
   self._playerHeadList = nil

   self._timerScheduler = nil
end

function UIEarlyStartVote:init()
    self._applyText = seekNodeByName(self, "Text_ApplyText", "ccui.Text")
    self._countdownText = seekNodeByName(self, "Text_60s", "ccui.Text")
    self._btnDisagree = seekNodeByName(self, "Button_jj", "ccui.Button")
    self._btnAgree = seekNodeByName(self, "Button_yt", "ccui.Button")

    self._playerHeadList = seekNodeByName(self, "ListView_PlayerHead", "ccui.ListView")

    self._playerHeadModel = seekNodeByName(self, "Panel_wj1","ccui.Layout")

    self._playerHeadModel:removeFromParent(false)
    self._playerHeadModel:setVisible(false)
    self._playerHeadModel:retain()

    bindEventCallBack(self._btnAgree, handler(self, self._onAgreeDismissRoomButton),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDisagree,  handler(self, self._onRefuseDismissRoomButton), ccui.TouchEventType.ended)
end

function UIEarlyStartVote:onShow(...)
    local args = { ... }

    self:refreshPlayerInfo(args[1],args[2])
    self._onOkCallBack = args[3]
    self._onCancelCallBack = args[4]
    self._agreePlayers = #args[2].agreePlayers > 0 and args[2].agreePlayers or {}
    self:_shake()
end

-- 隐藏窗口回调
function UIEarlyStartVote:onHide()
    if self._timerScheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
        self._timerScheduler = nil
    end
end

-- 刷新投票人物信息
function UIEarlyStartVote:refreshPlayerInfo(playerMap,voteInfo)
    local applicant = voteInfo.applicant
    local agreePlayers = voteInfo.agreePlayers
    local disagreePlayers = voteInfo.disagreePlayers
    local remainTime = voteInfo.remainTime
    local playerNum = 0

    self._playerHeadList:removeAllChildren(true)
    self._playerHeadList:setItemsMargin(18)
    local agreeMap = {}
    local disagreeMap = {}
    -- 如果有就标记为true。。不想每个人查找的时候还遍历一下,如果自己投过了就隐藏按钮
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
    for k,v in pairs(agreePlayers) do 
        if v == roleId then
            self._btnAgree:setVisible(false)
            self._btnDisagree:setVisible(false)
        end
        agreeMap[v] = true
    end
    
    for k,v in pairs(disagreePlayers) do
        disagreeMap[v] = true
    end

    -- playermap排序
    local applicantIndex= 0
    for i,v in pairs(playerMap) do
        if v.roleId == applicant then
            applicantIndex = i
        end
    end
    local player = table.remove(playerMap,applicantIndex)

    table.sort(playerMap,function (a,b)
        return a.seat < b.seat
    end)

    local result = {}
    table.insert(result, player)
    for i,v in pairs(playerMap) do
        table.insert(result,v)
    end
    playerMap = result

    for i,v in pairs(playerMap) do
        local item = self._playerHeadModel:clone()
        local cell = PlayerIconComponent:new(item)
        cell:setData(v.headImageUrl, v.nickname, v.headFrame)
        item:setVisible(true)
        self._playerHeadList:addChild(item)

        if agreeMap[v.roleId] ~= nil then
            cell:agree()
        end
        playerNum = playerNum + 1
    end

    local player = game.service.RoomService.getInstance():getPlayerById(applicant)
    self._applyText:setString(string.format( "【%s】申请以%s玩法立即开局，等待其他玩家确认", kod.util.String.getMaxLenString(player.nickname, 8), room.RoomSettingHelper.getChineseString(voteInfo.ruleOfAdvance)))

    local width = 135
    local height = self._playerHeadList:getContentSize().height
    if width ~= nil then
        self._playerHeadList:setContentSize( width * playerNum, height)
    end
    self._playerHeadList:setScrollBarEnabled(false)

    self:_startCountDown(voteInfo.remainTime)
end

-- 开始倒计时
function UIEarlyStartVote:_startCountDown(remainTime)
    self._countDownTimer = math.floor( remainTime/1000 )
	self._countdownText:setString(self._countDownTimer .. "秒")

	if self._timerScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
		self._timerScheduler = nil
	end

	self._timerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._timerCallback), 1, false)
end

-- countdown callback
function UIEarlyStartVote:_timerCallback()
    if self._countDownTimer > 0 then
        self._countDownTimer = self._countDownTimer - 1
    end

	self._countdownText:setString(self._countDownTimer .. "秒")

    -- 只对未同意的玩家进行震动提示（倒计时剩十秒）
    if self._countDownTimer == 10 then
        self:_shake()
    end

	if self._countDownTimer == 0 and self._timerScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
		self._timerScheduler = nil
	end
end

-- 同意
function UIEarlyStartVote:_onAgreeDismissRoomButton()
    if nil ~= self._onOkCallBack and "function" == type(self._onOkCallBack) then
		if self:_onOkCallBack() == false then
			return
		end
	end
end

-- 不同意
function UIEarlyStartVote:_onRefuseDismissRoomButton()
    if nil ~= self._onCancelCallBack and "function" == type(self._onCancelCallBack) then
		if self:_onCancelCallBack() == false then
			return
		end
	end
end

-- 手机震动
function UIEarlyStartVote:_shake()
    local agree = false
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
    for _, playerId in ipairs(self._agreePlayers) do
        if playerId == roleId then
            agree = true
        end
    end
    if agree == false then
        game.plugin.Runtime.shake()
    end
end

function UIEarlyStartVote:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

function UIEarlyStartVote:needBlackMask()
	return true;
end

function UIEarlyStartVote:closeWhenClickMask()
	return false
end

return UIEarlyStartVote