local RoomSettingInfo = require("app.game.RoomSettingInfo")
local csbPath = "ui/csb/Club/UIClubRoomInfo.csb"
local super = require("app.game.ui.UIBase")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local Constants = require("app.gameMode.mahjong.core.Constants")
local RoomSettingHelper = require("app.game.ui.RoomSettingHelper").RoomSettingHelper
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")

local UIBigLeagueRoomInfo = class("UIBigLeagueRoomInfo", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    亲友圈房间信息
        加入房间、解散房间、观战
]]


function UIBigLeagueRoomInfo:ctor()
	self._btnWatching               = nil   -- 观战
    self._btnDisband                = nil   -- 解散
    self._btnJoin                   = nil   -- 加入
    self._btnJoin_M                 = nil   -- 加入(群主)
    self._listPlayer                = nil   -- 头像
    self._textArea                  = nil   -- 地区
    self._scrollView                = nil   -- 玩法的scrollview
    self._textGamePlay              = nil   -- 玩法
    self._textRoomNumber            = nil   -- 房间号
    self._textVoice                 = nil   -- 语音
    self._textTime                  = nil   -- 时间
    self._imgVoice_OFF              = nil   -- 实时语音关
    self._imgVoice_ON               = nil   -- 实时语音开
    self._btnOk                     = nil   -- 确定
    self._btnActingCreate_InviteFriend = nil -- 邀请
end

function UIBigLeagueRoomInfo:init()
    self._btnWatching               = seekNodeByName(self, "Btn_d_pjxx"		            , "ccui.Button")
    self._btnDisband                = seekNodeByName(self, "Btn_b_pjxx"		            , "ccui.Button")
    self._btnJoin                   = seekNodeByName(self, "Btn_c_pjxx"		            , "ccui.Button")
    self._btnJoin_M                 = seekNodeByName(self, "Btn_a_pjxx"		            , "ccui.Button")
    self._listPlayer                = seekNodeByName(self, "ListView_list_pjxx"		    , "ccui.ListView")
    self._textArea                  = seekNodeByName(self, "Text_z_pjxx"		        , "ccui.Text")
    self._textGamePlay              = seekNodeByName(self, "Text_lin1_word_pjxx"		, "ccui.Text")
    self._textRoomNumber            = seekNodeByName(self, "Text_fh_pjxx"		        , "ccui.Text")
    self._textVoice                 = seekNodeByName(self, "Text_sond_z"		        , "ccui.Text")
    self._scrollView                = seekNodeByName(self, "ScrollView_word_pjxx"		, "ccui.ScrollView")
    self._textTime                  = seekNodeByName(self, "Text_fh_pjxx_0"             , "ccui.Text")
    self._imgVoice_OFF              = seekNodeByName(self, "Image_sond_off"             , "ccui.ImageView")
    self._imgVoice_ON               = seekNodeByName(self, "Image_sond_on"              , "ccui.ImageView")
    self._btnOk                     = seekNodeByName(self, "Btn_c_pjqd"                 , "ccui.Button")
    self._btnActingCreate_InviteFriend = seekNodeByName(self, "Btn_ActingCreate_InvivteFriend", "ccui.Button")
    self._btnClubInvite             = seekNodeByName(self, "Btn_ActingCreate_InvivteFriend_0", "ccui.Button")

    -- 不显示滚动条, 无法在编辑器设置
	self._listPlayer:setScrollBarEnabled(false)
	self._listPlayer:setTouchEnabled(true)
	self._panelHead = ccui.Helper:seekNodeByName(self._listPlayer, "Panel_1_list_pjxx")
	self._panelHead:removeFromParent(false)
	self:addChild(self._panelHead)
	self._panelHead:setVisible(false)

    self:_registerCallBack()
end

-- 点击事件注册
function UIBigLeagueRoomInfo:_registerCallBack()
    bindEventCallBack(self._btnWatching, 	handler(self, self._onClickWatching), 	    ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDisband, 	handler(self, self._onClickDisband), 	    ccui.TouchEventType.ended)
    bindEventCallBack(self._btnJoin, 	    handler(self, self._onClickJoin), 	        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnJoin_M, 	    handler(self, self._onClickJoin), 	        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk,          handler(self, self._onBtnOk), 	            ccui.TouchEventType.ended)
    bindEventCallBack(self._btnActingCreate_InviteFriend, handler(self, self._onActingCreateInviteFriend), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClubInvite, handler(self, self._onClickClubInvite), ccui.TouchEventType.ended)
end

-- 观战
function UIBigLeagueRoomInfo:_onClickWatching()
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
        return
    end
    
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_SuperLeague_RoomInfo_Watch)
    game.service.RoomCreatorService.getInstance():queryBattleIdReq(self._data.roomId, game.globalConst.JOIN_ROOM_STYLE.Watch, true);
end

-- 解散房间 盟主解散
function UIBigLeagueRoomInfo:_onClickDisband()
    local leagueId = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getLeagueId()
    local clubId = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getClubId()
    --盟主点击解散房间打点统计.
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_SuperLeague_Dis_Room)
    game.ui.UIMessageBoxMgr.getInstance():show("您确定要强制解散该房间吗？" , {"确定","取消"}, function()
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLDestroyRoomREQ(self._data.roomId, clubId ,leagueId);
        --数据统计
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_SuperLeague_Dis_Room_Ok);
        UIManager:getInstance():hide("UIBigLeagueRoomInfo")
    end);
end

-- 加入房间
function UIBigLeagueRoomInfo:_onClickJoin()
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
        return
    end

    local roundCount, gamePlays = game.service.club.ClubService.getInstance():getClubRoomService():getRoomRule()
    if #gamePlays == 0 or self._data.gameplay.gameplays[1] == gamePlays[1] then
        game.service.RoomCreatorService.getInstance():queryBattleIdReq(self._data.roomId, game.globalConst.JOIN_ROOM_STYLE.ClickTable)
        return
    end

    local str = string.format("检测到您上次完成的牌局玩法是%s，当前牌桌玩法是%s，是否继续进入房间？", RoomSettingInfo.new(gamePlays, roundCount):getZHArray()[1], RoomSettingInfo.new(self._data.gameplay.gameplays, self._data.gameplay.roundType):getZHArray()[1])
    UIManager:getInstance():show("UIClubRuleTips", str, 5, function ()
        game.service.RoomCreatorService.getInstance():queryBattleIdReq(self._data.roomId, game.globalConst.JOIN_ROOM_STYLE.ClickTable)
    end)
end

function UIBigLeagueRoomInfo:_onBtnOk()
    UIManager:getInstance():hide("UIBigLeagueRoomInfo")
end

-- 代开房间，邀请好友
function UIBigLeagueRoomInfo:_onActingCreateInviteFriend()
    --talkdata打点
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Room_Info_Invite_Click)
    -- local uishare = require("app.game.ui.UIShareRoomInfo").new()
	local tip = config.GlobalConfig.getShareInfo()[1]
    local title = "房号:[" .. self._data.roomId .. "]"
    local gameTypes = RoomSettingHelper.convert2ClientGameOptions(false, self._data.gameplay.roundType, self._data.gameplay.gameplays)
    local roomSettingInfo = RoomSettingInfo.new(self._data.gameplay.gameplays, self._data.gameplay.roundType)
    local newZHTable = roomSettingInfo:getZHArray()
	local content = table.concat(newZHTable, "、")

    local data =
	{
        enter = share.constants.ENTER.CLUB_ROOM_INFO,
		tip = tip,
		title = title,
		content = content
    }
	local msg = title .. ", " .. content .. "开搓! 现在就等你哦!"
    local url_data = {
        enter = share.constants.ENTER.CLUB_ROOM_INFO,
        shareContent = msg
    }
    share.ShareWTF.getInstance():share(share.constants.ENTER.CLUB_ROOM_INFO, {data, data, data})
end

function UIBigLeagueRoomInfo:onShow(roomInfo)
    self._data = roomInfo

    local roleId    = game.service.LocalPlayerService.getInstance():getRoleId();

    -- 房间是否满人
    local isFullRoom = self._data.playerMax == #self._data.players
    --盟主标志 可以解散房间
    local IsSuperLeague = game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague()

    -- 邀请按钮对亲友圈有管理权限的进行开放并且房间人数没有满
    -- local showActingCreateInvite = club:isPermissions(roleId) and not isFullRoom

    self._btnWatching:setVisible(false)
    self._btnDisband:setVisible(IsSuperLeague)
    self._btnJoin:setVisible(true)
    self._btnJoin_M:setVisible(false)
    self._btnActingCreate_InviteFriend:setVisible(false)
    self._btnClubInvite:setVisible(false)
   

    -- 当人满的时候
    if isFullRoom then
        self._btnJoin:setVisible(false)
        self._btnJoin_M:setVisible(false)
        self._btnOk:setVisible(not IsSuperLeague)
        self._btnWatching:setVisible(IsSuperLeague)
    else
        self._btnWatching:setVisible(false)
        self._btnOk:setVisible(false)
    end

    self._btnDisband:setPositionPercent(cc.p(0.5,self._btnDisband:getPositionPercent().y))
    --調整 解散房間 按鈕的位置
    if isFullRoom then 
        self._btnDisband:setPositionPercent(cc.p(0.75,self._btnDisband:getPositionPercent().y))
    end

    if game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague() then
        self._btnJoin:setVisible(false)
    end

    -- 头像
    self._listPlayer:removeAllChildren()
    for i = 1, self._data.playerMax do
        local node = self._panelHead:clone()
		self._listPlayer:addChild(node)
		node:setVisible(true)
        local imgHead = ccui.Helper:seekNodeByName(node, "Image_face_list_pjxx")        -- 头像
        local imgManager = ccui.Helper:seekNodeByName(node, "Image_icon_list_pjxx")     -- 群主标识
        local textName = ccui.Helper:seekNodeByName(node, "Text_3")                     -- 玩家昵称
        local imgMask =  ccui.Helper:seekNodeByName(node, "Image_black_list_pixx")      -- 蒙灰
        local textStatus =  ccui.Helper:seekNodeByName(node, "Text_djr_list_pixx")      -- 玩家状态
        imgManager:setVisible(false)
        textName:setVisible(false)
        if i <= #self._data.players then
            textName:setVisible(true)
            local player = self._data.players[i]
            game.util.PlayerHeadIconUtil.setIcon(imgHead, player.head)
            -- imgManager:setVisible(club:isManager(player.roleId))
            textName:setString(game.service.club.ClubService.getInstance():getInterceptString(player.name, 8))
            if bit.band(player.status, Constants.PlayerStatus.WAITING) == 0 then
                imgMask:setVisible(false)
                textStatus:setVisible(false)
            else
                textStatus:setString("等待中")
            end
        end
    end

    -- 删除实时语音玩法显示
    local voiceOpenType = RoomSetting.GamePlay.COMMON_VOICE_OPEN
    for i, rule in ipairs(self._data.gameplay.gameplays) do
        if rule == voiceOpenType then
            table.remove(self._data.gameplay.gameplays, i)
            break
        end
    end

    -- 房间号
    self._textRoomNumber:setString(string.format("房号:%s", tostring(self._data.roomId)))

    -- 时间
    self._textTime:setString(os.date("%Y-%m-%d %H:%M", self._data.createTimestamp/1000))

    -- 玩法
    local gameTypes = RoomSettingHelper.convert2ClientGameOptions(false, self._data.gameplay.roundType, self._data.gameplay.gameplays)
    -- 地区
    local area = game.service.club.ClubService.getInstance():_getGameTypeName(gameTypes[1])
    -- 玩法
    local roomSettingInfo = RoomSettingInfo.new(self._data.gameplay.gameplays, self._data.gameplay.roundType)
    local newZHTable = roomSettingInfo:getZHArray()
    local zhContent = ''
    -- 不显示玩法、局数、人数、
    local startIndex = roomSettingInfo:getClubRoomInfoShowStartIndex()
    if #newZHTable >= startIndex then
        zhContent = table.concat( newZHTable, "、", startIndex, #newZHTable)
    end
    Logger.debug("UIBigLeagueRoomInfo:settings=>"..json.encode(self._data.gameplay.gameplays))
    local index = table.indexof(self._data.gameplay.gameplays,Constants.PlayType.GPS_CHECK_OPEN)
    if index then
        zhContent = zhContent .. "、".. "GPS安全检测"
    end
    
    --大赢家抽奖分数有多个区间
    local str1 = string.format("玩法:%s\n赛事分系数:%s\n赛事分不低于:%s\n",
    zhContent,
    self._data.gameplay.scoreCoefficient,
    self._data.gameplay.joinThreshold
    )
    
    local str2 = ''
    local lotteryProperty = self._data.gameplay.lotteryProperty
    for _,v in ipairs(lotteryProperty) do
        str2 = str2 .. "大赢家抽奖分数区间:" .. v.startScore .."-" .. v.endScore .. '  ' ..'抽奖消耗赛事分：' .. v.lotteryCost .."\n" 
    end 
    local str =  str1 .. str2
    if self._data.hasStartBattle and self._data.playerMax ~= #self._data.players then
        self._textArea:setString(string.format("%s(第%d/%s局)", area, self._data.finishRoundCount, roomSettingInfo:getRoundCountNumber()))
    else
        self._textArea:setString(string.format("%s(%s局)", area, roomSettingInfo:getRoundCountNumber()))
    end
    
    local voiceSupported = roomSettingInfo:isRealTimeVoiceSupported()
    local voiceOpen = roomSettingInfo:isRealTimeVoiceOpen()
    -- 实时语音
    local voice = (voiceSupported and voiceOpen) and "实时语音:开" or "实时语音:关"
    self._textVoice:setString(voice)
    self._imgVoice_OFF:setVisible(voiceSupported and not voiceOpen)
    self._imgVoice_ON:setVisible(voiceSupported and voiceOpen)
    self._textVoice:setVisible(voiceSupported)
    
    self._textGamePlay:setString(str)
    local contentSize = self._scrollView:getContentSize()
	self._textGamePlay:setTextAreaSize(cc.size(contentSize.width, 0))
	local _size = self._textGamePlay:getVirtualRendererSize()
	self._textGamePlay:setContentSize(cc.size(contentSize.width, _size.height))
	self._scrollView:setInnerContainerSize(cc.size(contentSize.width, _size.height))
	
	if self._scrollView:getContentSize().height < _size.height then
		self._textGamePlay:setPositionY(_size.height)
	else
		self._textGamePlay:setPositionY(contentSize.height)
	end
end

-- 俱乐部邀请
function UIBigLeagueRoomInfo:_onClickClubInvite()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_RoomInfo_Online_Invite)
	UIManager:getInstance():show("UIClubRoomInviteList", self._data.clubId, self._data.roomId)
end

function UIBigLeagueRoomInfo:needBlackMask()
	return true
end

function UIBigLeagueRoomInfo:closeWhenClickMask()
	return true
end

function UIBigLeagueRoomInfo:onHide()
     
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIBigLeagueRoomInfo:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIBigLeagueRoomInfo