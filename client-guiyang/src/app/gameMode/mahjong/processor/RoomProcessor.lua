--[[
-- 牌局处理器,
-- 生命周期为一局麻将, 真正开局的时候创建, 牌局结算之后销毁, 下次开局重新创建
--]]
local RoomProcessor = class("RoomProcessor")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

function RoomProcessor:ctor(roomUI)
	self._roomUI = roomUI;
	self._nextIdleTime = 0

	gameMode.mahjong.Context.getInstance():getGameService():addEventListener("PROC_STEP", function(event)
		self:_processStep(event.recover, event.stepGroup)
	end, self);
end

function RoomProcessor:dispose()
	gameMode.mahjong.Context.getInstance():getGameService():removeEventListenersByTag(self);
end

function RoomProcessor:getRoomUI()
	return self._roomUI;
end

function RoomProcessor:getNextIdleTime()
	return self._nextIdleTime
end

-- 设置下次可以处理step的时间
function RoomProcessor:addNextIdleTime(elapse)
	local nextTime = kod.util.Time.now() + elapse
	self._nextIdleTime = self._nextIdleTime < nextTime and nextTime or self._nextIdleTime
end

-- 牌局等待开始时调用
function RoomProcessor:onGameWaitingStart()
	local roomService = game.service.RoomService.getInstance();

	-- 设置房间号
	self._roomUI:setRoomId(0)

	-- 隐藏牌局UI, 指示器,当前局数,隐藏当前牌数等
	self._roomUI:showGameUI(false)
	self._roomUI:hideDiscardedCardIndicator()
	-- 隐藏邀请按钮
	self._roomUI:showInviteButton(false)
	-- 隐藏退出/解散按钮
	self._roomUI:showQuitRoomButton(false)
end

-- 牌局开始时调用
function RoomProcessor:onGameStarted()
	local gameService = gameMode.mahjong.Context.getInstance():getGameService();

	-- 显示牌局指示器
	self._roomUI:showGameUI(true)
	self._roomUI:resetDir()
	self._roomUI:hideDiscardedCardIndicator()

	-- 显示当前局数
	self._roomUI:setRoundCount(gameService:getCurrentRoundCount(), gameService:getMaxRoundCount())

	-- 显示当前牌数, TODO : 需要优化协议, 这里看得不到当前剩余牌数

	-- 隐藏邀请按钮
	self._roomUI:showInviteButton(false)
	-- 隐藏退出/解散按钮
	self._roomUI:showQuitRoomButton(false)
	-- 播放极速模式动画
	self._roomUI:playFastModeAim()
	-- 播放托管提示动画
	self._roomUI:playTrustTipAnim()
end

-- 牌局结束
function RoomProcessor:onGameEnded()
end

function RoomProcessor:onPlayerChanged(players)
	local roomService = game.service.RoomService.getInstance();
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	local playerService = game.service.LocalPlayerService.getInstance();

	-- 是否显示极速模式提示
	self._roomUI:showFastMode()
	-- 是否显示托管模式提示
	self._roomUI:showTrustMode()

	-- 如果当前房间还没有开始(第一局没有开始)
	if #players ~= gameService:getMaxPlayerCount() and not gameService:isGameStarted() and not roomService:isHaveBeginFirstGame() then
		-- 显示邀请按钮
		self._roomUI:showInviteButton(true)
		-- 显示退出/解散按钮
		local roleId = playerService:getRoleId() -- 自己Id
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

		self._roomUI:showQuitRoomButton(true, isShowDismiss, isActingCreate, isShowQuit)
	else
	-- 否则
		-- 隐藏邀请按钮
		self._roomUI:showInviteButton(false)
		-- 隐藏退出/解散按钮
		self._roomUI:showQuitRoomButton(false)
		-- 播放极速模式动画
		self._roomUI:playFastModeAim()
		-- 播放托管提示动画
		self._roomUI:playTrustTipAnim()
		-- 关闭邀请界面
		if UIManager:getInstance():getIsShowing("UIClubRoomInviteList") then
			UIManager:getInstance():destroy("UIClubRoomInviteList")
		end
	end
end

-- 处理房间相关操作
function RoomProcessor:_processStep(isRecover, stepGroup)
	if Macro.assetTrue(#stepGroup == 0) then
		return;
	end

	local firstStep = stepGroup[1];

	-- 首先交给RoomProcessor处理
	if firstStep:getPlayType() == PlayType.DISPLAY_LAST_CARD_COUNT then
		self._roomUI:setCardCount(firstStep:getPointInGame())
	elseif firstStep:getPlayType() == PlayType.OPERATE_HU then
		-- TODO : 考虑下这个结构
		self:addNextIdleTime(self._roomUI:getHuHandler():onHu(stepGroup, isRecover, function()
			-- gameMode.mahjong.Context.getInstance():getGameService():_processStep(isRecover)
        end))
        game.service.RoomService.getInstance():dispatchEvent({name = "TING_DISABLE_ALL"})		
	elseif firstStep:getPlayType() == PlayType.DISPLAY_JI_SELF or
		firstStep:getPlayType() == PlayType.DISPLAY_FINISH_ALL or
		firstStep:getPlayType() == PlayType.DISPLAY_FINISH_ALL_REPLAY or
		firstStep:getPlayType() == PlayType.DISPLAY_JI_FANPAI or
		firstStep:getPlayType() == PlayType.DISPLAY_JI_CHUIFENG 
		then

		--在单局结算时，不用再进行倒计时和倒计时结束震屏啦
		self._roomUI:cancelCountDown()
		self._roomUI:cancelTrustCountDown()
		self._roomUI:setString_Time(0)
		
		self._roomUI:getHuHandler():showChicken(stepGroup)
		local processor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByChair(CardDefines.Chair.Down)
		processor:getSeatUI():clearCards()
		processor:onRoundFinished()
    elseif firstStep:getPlayType() == PlayType.DISTORY_FINISH_ROOM then
        --FYD 处理解散房间当局
        local UI_ANIM = require("app.manager.UIAnimManager")
        local anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect_jiesan.csb", function()end))
	end
end

-- 从结算结果中取出首牌以及碰扛信息
function RoomProcessor:getCardList(result)
	local roundReportInfo ={
		anGang = {},
		chi = {},
		gang = {},
		hand = {},
		hus = {},
		peng = {},
		hua = {},
		guiCards = {},
		playerData = {},
		huStatus = {},
		player = nil
	}

	roundReportInfo.player = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(result.roleId)
	local tmpPlayer = roundReportInfo.player

	roundReportInfo.playerData.chairType = tmpPlayer:getRoomSeat():getChairType()
	roundReportInfo.playerData.roleId = tmpPlayer:getRoomSeat():getPlayer().roleId
	roundReportInfo.playerData.position = tmpPlayer:getRoomSeat():getPlayer().position
	roundReportInfo.playerData.isBanker = tmpPlayer:getRoomSeat():getPlayer():isBanker()
	roundReportInfo.playerData.faceUrl = tmpPlayer:getRoomSeat():getPlayer().headIconUrl
	roundReportInfo.playerData.name = tmpPlayer:getRoomSeat():getPlayer().name
	roundReportInfo.playerData.totalPoint = tmpPlayer:getRoomSeat():getPlayer().totalPoint
	roundReportInfo.playerData.seat = tmpPlayer:getRoomSeat():getPlayer().seat
	roundReportInfo.playerData.headFrame = tmpPlayer:getRoomSeat():getPlayer().headFrame

	for i=1,#result.handCards do
		local cardValue = nil
		if type(result.handCards) == "table" then
			cardValue = result.handCards[i]
		else
			cardValue = string.byte(result.handCards, i)
		end
		table.insert(roundReportInfo.hand, cardValue)
	end

	local operateCardsData = result.operateCards
	table.foreach(operateCardsData, function(key, val)
		local cardsArray = val.cards
		if type(cardsArray) == "string" then
			cardsArray = CardDefines.getCards(cardsArray)
		end
		if PlayType.Check(val.playType, PlayType.DISPLAY_MASTER_HONG_ZHONG) then
			-- 鬼牌
			table.foreach(cardsArray, function(k, v)
				table.insert(roundReportInfo.guiCards, v)
			end)
		elseif PlayType.Check(val.playType, PlayType.DISPLAY_SHOW_MASTER_CARD) then
			-- 鬼牌
			table.foreach(cardsArray, function(k, v)
				table.insert(roundReportInfo.guiCards, v)
			end)
		elseif PlayType.Check(val.playType, PlayType.DISPLAY_HUA_PAI) then
			-- 鬼牌
			table.foreach(cardsArray, function(k, v)
				table.insert(roundReportInfo.guiCards, v)
			end)
		elseif PlayType.Check(val.playType, PlayType.OPERATE_GANG_A_CARD) then
			table.insert(roundReportInfo.gang, cardsArray[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_BU_GANG_A_CARD) then
			table.insert(roundReportInfo.gang, cardsArray[1])
		elseif PlayType.Check(val.playType, PlayType.DISPLAY_EX_CARD) then
			table.insert(roundReportInfo.hua, cardsArray[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_AN_GANG) then
			table.insert(roundReportInfo.anGang, cardsArray[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_PENG_A_CARD) then
			table.insert(roundReportInfo.peng, cardsArray[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_CHI_A_CARD) then
			table.insert(roundReportInfo.chi, cardsArray[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_HU) then
			table.insert(roundReportInfo.hus, cardsArray[1])
		end
	end)

	-- 当有人胡时，在桌面上显示是否叫牌或者胡牌类型（点炮、自摸）
	local hu_status = {}
	-- 该玩家有没有叫牌
	local hasJiaoPai = false
	for _, event in ipairs(result.events) do 
		local score = event.score
		if score.type == PlayType.HU_JIAO_PAI then
			hasJiaoPai = true
		end
	end

	for _, event in ipairs(result.events) do -- ResultEventPROTO
		local score = event.score
		local op = event.addOperation
		if score.type == PlayType.HU_ZI_MO or score.type == PlayType.HU_DIAN_PAO then
			if (score.type == PlayType.HU_ZI_MO and op)then
				hu_status = {playType = score.type, op = op and 1 or 0}
			elseif (score.type == PlayType.HU_DIAN_PAO and op) then
				hu_status = {playType = score.type, op = 2}
			end
		end
		-- 闷胡算是叫牌的一种
		if score.type == PlayType.HU_JIAO_PAI or score.type == PlayType.HU_WEI_JIAO_PAI or score.type == PlayType.HU_MEN_HU then
			if op then
				hu_status = {playType = score.type, op = op and 1 or 0}
			end
		end
		-- 如果是点炮的人则显示点炮
		if score.type == PlayType.HU_DIAN_PAO and op == false then
			if hasJiaoPai == true then
				hu_status = {playType = score.type, op = 1}
			else
				hu_status = {playType = score.type, op = 0}
			end
			break
		end
	end
	roundReportInfo.huStatus = hu_status

	return roundReportInfo
end

return RoomProcessor
