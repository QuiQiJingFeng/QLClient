local RoomServiceHelper = require("app.gameMode.RoomServiceHelper")
local UIGameScene_PanelWating = class("UIGameScene_PanelWating")

function UIGameScene_PanelWating:ctor(gameScene)
	self._btnInvite = seekNodeByName(gameScene, "Button_Wechat_Invite", "ccui.Button")
	self._btnDismissRoom = seekNodeByName(gameScene, "Button_Dismiss_Room", "ccui.Button")
	self._btnExitToLobby = seekNodeByName(gameScene, "Button_Exit_To_Lobby", "ccui.Button")
	self._btnExitToLobby_Acting = seekNodeByName(gameScene, "Button_Exit_To_Lobby_0", "ccui.Button")
	self._btnClubInvite = seekNodeByName(gameScene, "Button_clubInvite", "ccui.Button")
	self._btnFriendInvite = seekNodeByName(gameScene, "Button_friendInvite", "ccui.Button")
	self._btnFriendInvite:setVisible(false)
	
	bindEventCallBack(self._btnExitToLobby, RoomServiceHelper.exit2Lobby, ccui.TouchEventType.ended)
	bindEventCallBack(self._btnExitToLobby_Acting, RoomServiceHelper.exit2Lobby_Acting, ccui.TouchEventType.ended)
	bindEventCallBack(self._btnDismissRoom, RoomServiceHelper.dismissRoom, ccui.TouchEventType.ended)
	bindEventCallBack(self._btnInvite, RoomServiceHelper.wechatInvite, ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClubInvite, handler(self, self._onClickClubInvite), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnFriendInvite, handler(self, self._onClickFriendInvite), ccui.TouchEventType.ended)
	self:init()
end

function UIGameScene_PanelWating:init()
	self._btnInvite:setVisible(false)
	self._btnDismissRoom:setVisible(false)
	self._btnExitToLobby:setVisible(false)
	self._btnExitToLobby_Acting:setVisible(false)
    self._btnClubInvite:setVisible(false)
	self._btnFriendInvite:setVisible(false)
end

function UIGameScene_PanelWating:onRoundCountChanged(nowRoundCount)
	local stateName = GameFSM:getInstance():getCurrentState().class.__cname
	local isReplay = string.match(string.lower(stateName), "replay") == 'replay'
	if isReplay then
		self:setEnable(false)
		return
	end
	
	local gameService = gameMode.mahjong.Context:getInstance():getGameService()
	local roomService = game.service.RoomService:getInstance()
	
	if nowRoundCount == 0
	and not gameService:isGameStarted()
	and roomService ~= nil
	and roomService:isHaveBeginFirstGame() == false then
		
		local localId = game.service.LocalPlayerService:getInstance():getRoleId()
		local processor = gameService:getPlayerProcessorByPlayerId(localId)
		local isHost = processor._playerInfo:isHost()
		local isReview = GameMain.getInstance():isReviewVersion()
		local isClubRoom = roomService:getRoomClubId() ~= 0
		local creatorId = roomService:getCreatorId() -- 创建者Id
		local clubId = roomService:getRoomClubId() -- 俱乐部Id
		local clubData = game.service.club.ClubService.getInstance():getClub(clubId)
		
		-- 创建者id与经理id相同时，说明是代开房
		local isActingCreate = false
		local isShowQuit = false
		if clubData then
			isActingCreate = clubData:isPermissions(localId) and localId == creatorId
			isShowQuit = clubData:isPermissions(creatorId)
		end
		if isShowQuit then
			-- 代开房只能经理解散房间
			self._btnDismissRoom:setVisible(isActingCreate)
			self._btnExitToLobby:setVisible(not isActingCreate)
		else
			self._btnDismissRoom:setVisible(isHost)
			self._btnExitToLobby:setVisible(not isHost)
		end
		
		self._btnInvite:setVisible(not isReview)
		self._btnClubInvite:setVisible(not isReview and isClubRoom)
		self._btnExitToLobby_Acting:setVisible(isShowQuit and isActingCreate)
		-- self._btnFriendInvite:setVisible(not isReview and not isClubRoom)
	else
		self._btnInvite:setVisible(false)

		self._btnDismissRoom:setVisible(false)
		self._btnExitToLobby:setVisible(false)
		self._btnExitToLobby_Acting:setVisible(false)
		self._btnClubInvite:setVisible(false)
		-- self._btnFriendInvite:setVisible(false)
	end

	if self._btnClubInvite:isVisible() then
		self._btnInvite:setPositionPercent(cc.p(0.35, 0.4))
		self._btnClubInvite:setPositionPercent(cc.p(0.65, 0.4))
	else
		self._btnInvite:setPositionPercent(cc.p(0.5, 0.4))
	end
end

function UIGameScene_PanelWating:onGameStarted()
	self._btnInvite:setVisible(false)
	self._btnDismissRoom:setVisible(false)
	self._btnExitToLobby:setVisible(false)
	self._btnClubInvite:setVisible(false)
	-- self._btnFriendInvite:setVisible(false)
end

function UIGameScene_PanelWating:setEnable(value)
	value = value or false
	self._btnInvite:setVisible(value)
	self._btnDismissRoom:setVisible(value)
    self._btnExitToLobby:setVisible(value)
    local clubId = game.service.RoomService:getInstance():getRoomClubId()
	self._btnClubInvite:setVisible(value and  clubId ~= 0)
	-- self._btnFriendInvite:setVisible(value and clubId == 0)
end

function UIGameScene_PanelWating:dispose()
end

-- 俱乐部邀请
function UIGameScene_PanelWating:_onClickClubInvite()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Room_Online_Invite)
	local roomService = game.service.RoomService.getInstance()
	UIManager:getInstance():show("UIClubRoomInviteList", roomService:getRoomClubId(), roomService:getRoomId())
end

function UIGameScene_PanelWating:_onClickFriendInvite()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Room_Friend)
    local roomService = game.service.RoomService.getInstance()
    game.service.friend.FriendService.getInstance():sendCGQueryRoomInvitedFriendInfosREQ(roomService:getRoomId())
end

return UIGameScene_PanelWating 