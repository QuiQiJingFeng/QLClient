local csbPath = "ui/csb/UIGpsaqjc.csb" --ui文件
local super = require("app.game.ui.UIBase")

local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

-- 一些单独处理的控件，还是在主控件上，只是单纯的把控件代码拿出来
----------------------------------------------------------------------------------------------
-- 相同IP提示
local IPSameTisNew = class("IPSameTis", function(node) return node end)

function IPSameTisNew:ctor()
    -- 此节点只是用来克隆，实际显示的时候，是新创建的它的子控件
    self._txtIP = seekNodeByName(self, "Text_SameIP_Tips", "ccui.Text")
    -- 滚动条目的父节点
    self._layoutScrool = seekNodeByName(self, "Panel_scroll", "ccui.Layout")
    -- 创建两条，用来显示内容
    self._textNodeSeq = {}
    -- 理论来说最多两条就够了
    self._textNodeSeq[1] = self:_create()
    self._textNodeSeq[2] = self:_create()

    -- 用来显示的文字
    self._textSeq = {}

    -- 不做内容的显示
    self._txtIP:setString("测试")
    self._txtIP:setVisible(false)

    self._timeDelay = 0
end

-- 创建显示的节点
function IPSameTisNew:_create()
    local txt = self._txtIP:clone()
    self._layoutScrool:addChild(txt)
    txt:setAnchorPoint(cc.p(0.5,0.5))
    txt:setVisible(false)
    return txt
end

-- 默认显示的行间距
local LINE_HEIGHT = 5
-- 移动的时间间隔
local LINE_CHANGE_TIME = 0.02
-- 当有一条居中的时候，停顿的时间，应大于上面的时间
local LINE_WAIT_TIME = 0.5
--[[
    添加一条，在显示的时候，就已经进行了第一次的设置坐标
    收到的时候，直接就显示了，不再显示的去调用show
    @param tips 要显示的内容
]]
function IPSameTisNew:add(tips)
    self:setVisible(true)
    table.insert(self._textSeq, tips)
    local index = #self._textSeq
    if self._textNodeSeq[index] == nil then
        -- 如果要显示的条目不够，那么创建
        self._textNodeSeq[index] = self:_create()
    end
    -- 设置默认坐标
    local width = self._layoutScrool:getContentSize().width/2
    local height = self._txtIP:getContentSize().height
    local heightBegan = self._layoutScrool:getContentSize().height/2
    self._textNodeSeq[index]:setPosition(cc.p(width, (index-1) * (height+LINE_HEIGHT) + heightBegan))
    self._textNodeSeq[index]:setVisible(true)
    self._textNodeSeq[index]:setString(tips)
    if #self._textSeq > 1 then
        -- 如果数量多于一个，那么开启滚动显示
        game.service.TDGameAnalyticsService.getInstance():onEvent("UI_GPS_NEW_IP_CONFLICT")
        self:scheduleUpdateWithPriorityLua(function(dt)
            self:_update(dt)
        end, 0)
    end
end

-- 帧更新处理，用来做向上滚动
function IPSameTisNew:_update(dt)
    self._timeDelay = self._timeDelay + dt

    -- 如果需要等待且等待时间小于最低等待时间或者小于逐帧更新的间隔时间不处理
    if (self._bNeedWait and self._timeDelay < LINE_WAIT_TIME) or (self._timeDelay < LINE_CHANGE_TIME) then
        return
    end
    self._bNeedWait = false

    local height = self._txtIP:getContentSize().height
    local maxHeight = self._layoutScrool:getContentSize().height/2 + height + LINE_HEIGHT
    local maxNum = #self._textNodeSeq
    -- 整体向上移动
    local perMove = 1
    local y = 0
    -- 向上移动
    for i,v in ipairs(self._textNodeSeq) do
        y = v:getPositionY()
        y = y + perMove
        -- 如果有一行到达正中间了
        if y >= maxHeight then
            self._bNeedWait = true
            y = y - (height+LINE_HEIGHT) * maxNum
        end
        v:setPositionY(y)
    end
    self._timeDelay = 0
end

-- 隐藏
function IPSameTisNew:hide()
    self:setVisible(false)
end

-- 重置
function IPSameTisNew:reset()
    for i,v in ipairs(self._textNodeSeq) do
        v:setVisible(false)
    end
    self._textSeq = {}
    self._bNeedWait = false
    -- 取消帧更新
    self:unscheduleUpdate()
end

----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- 单击问号后的提示
local HelpTips = class("HelpTips", function(node) return node end)

function HelpTips:ctor()
end

function HelpTips:show()
    self:setVisible(true)
    -- 提高一下层级，压住下面的ip相同提示
    self:setLocalZOrder(10)
end

function HelpTips:hide()
    self:setVisible(false)
end

----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- 玩家的线条，头像相关提示
local PlayerInfo = class("PlayerInfo")

--[[
    每个人都有自己的头像，以及3条相连的线，当然相应的线也会同时出现在两个playerinfo中，会重复设置
    这里是一堆其它UI的合集，本身并不是一个UI
    @param head 用户头像信息的节点
    @param lines 当前线条，共有三个，key是对应的seat
]]
function PlayerInfo:ctor(head, lines)
    self._headIcon = head
    self._ipImage = seekNodeByName(head, "Image_user_Base", "ccui.ImageView")
    self._ip = seekNodeByName(head, "Text_ip", "ccui.Text")

    self._lines = lines
end

function PlayerInfo:setPlayerInfo(headIcon, ip)
	if nil ~= headIcon then
		game.util.PlayerHeadIconUtil.setIcon(self._headIcon, headIcon)
    end
    
    self._ip:setString(ip)
end

local LineLevel = {
    UNKNOWN = -1,
    MIN = 500,
    MID = 1000
}

--[[
    @param seat 对应的座位
    @param dis 对应的距离
]]
function PlayerInfo:updateGpsInfo(seat, dis)
    Logger.debug("updateGpsInfo seat, dis: "..seat..","..dis)
    local texture = nil
    local tips = ""
    local scale = 1
    local color = nil
    if dis == LineLevel.UNKNOWN then
        -- 未取到，或者不存在
        tips = "未知"
        texture = "img/img_jlt3.png"
        color = cc.c3b(0x99,0x99,0x99)
    else
        if dis < LineLevel.MIN then
            -- 红色
            texture = "img/img_jlt1.png"
            scale = 1.2
            color = cc.c3b(0xc6, 0x47, 0x24)
            game.service.TDGameAnalyticsService.getInstance():onEvent("UI_GPS_NEW_DISTANCE_LOW")
        elseif dis < LineLevel.MID then
            -- 黄色
            texture = "img/img_jlt2.png"
            color = cc.c3b(0xf7, 0xc3, 0x25)
        else
            -- 绿色
            texture = "img/img_jlt4.png"
            color = cc.c3b(0x16, 0x84, 0x64)
        end
        tips = string.format("距离%dm", dis)
    end
    Macro.assertTrue(type(self._lines[seat]) ~= "table", "ERROR, PlayerInfo [lineinfo,self._lines] not match  !")
    self._lines[seat].line:loadTexture(texture)
    self._lines[seat].line:setScale(scale)
    self._lines[seat].tips:setString(tips)
    self._lines[seat].tips:setTextColor(color)
end

function PlayerInfo:showIP()
    self._ipImage:setVisible(true)
end

function PlayerInfo:reset()
    self._ip:setString("")
    self._ipImage:setVisible(false)
    for k,v in pairs( self._lines ) do
        v.line:loadTexture("img/img_jlt3.png")
        v.line:setScale(1)
        v.tips:setString("未知")
        v.tips:setTextColor(cc.c3b(0x99,0x99,0x99))
    end
end

----------------------------------------------------------------------------------------------

-- 主界面
----------------------------------------------------------------------------------------------
local UIGpsNew = class("UIGpsNew",super,function () return kod.LoadCSBNode(csbPath) end )

--构造函数
function UIGpsNew:ctor()
end

--析构函数
function UIGpsNew:destroy()
end

--初始化函数
function UIGpsNew:init()
    self._btnClose = seekNodeByName(self, "Button_x_Gps", "ccui.Button")
    self._btnEnsure = seekNodeByName(self, "Button_btn1_Gps", "ccui.Button")
    self._btnDismiss = seekNodeByName(self, "Button_btn2_Gps", "ccui.Button")

    self._btnHelp = seekNodeByName(self, "Button_Gps_help", "ccui.Button")

    bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEnsure, handler(self, self._close), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDismiss, handler(self, self._onBtnDismiss), ccui.TouchEventType.ended)
	self._btnHelp:addTouchEventListener(handler(self, self._onBtnTipsClick))

    local lineDownToTop = seekNodeByName(self, "Image_line4_G", "ccui.ImageView")
    local tipsDownToTop = seekNodeByName(self, "Text_4", "ccui.Text")

    local lineDownToRight = seekNodeByName(self, "Image_line6_Y", "ccui.ImageView")
    local tipsDownToRight = seekNodeByName(self, "Text_6", "ccui.Text")

    local lineDownToLeft = seekNodeByName(self, "Image_line5_Y", "ccui.ImageView")
    local tipsDownToLeft = seekNodeByName(self, "Text_5", "ccui.Text")

    local lineRigthToLeft = seekNodeByName(self, "Image_line3_G", "ccui.ImageView")
    local tipsRightToLeft = seekNodeByName(self, "Text_3", "ccui.Text")

    local lineRigthToTop = seekNodeByName(self, "Image_line1_R", "ccui.ImageView")
    local tipsRightToTop = seekNodeByName(self, "Text_1", "ccui.Text")

    local lineLeftToTop = seekNodeByName(self, "Image_line2_Y", "ccui.ImageView")
    local tipsLeftToTop = seekNodeByName(self, "Text_2", "ccui.Text")
    self._playerInfos = {}
    self._playerInfos[CardDefines.Chair.Down] = PlayerInfo.new(seekNodeByName(self, "Image_user4", "ccui.ImageView"), {
        [CardDefines.Chair.Right] = { line=lineDownToRight, tips=tipsDownToRight },
        [CardDefines.Chair.Top] = { line=lineDownToTop, tips=tipsDownToTop },
        [CardDefines.Chair.Left] = { line=lineDownToLeft, tips=tipsDownToLeft },
    })
    self._playerInfos[CardDefines.Chair.Right] = PlayerInfo.new(seekNodeByName(self, "Image_user3", "ccui.ImageView"), {
        [CardDefines.Chair.Down] = { line=lineDownToRight, tips=tipsDownToRight },
        [CardDefines.Chair.Top] = { line=lineRigthToTop, tips=tipsRightToTop },
        [CardDefines.Chair.Left] = { line=lineRigthToLeft, tips=tipsRightToLeft },
    })
    self._playerInfos[CardDefines.Chair.Top] = PlayerInfo.new(seekNodeByName(self, "Image_user2", "ccui.ImageView"), {
        [CardDefines.Chair.Down] = { line=lineDownToTop, tips=tipsDownToTop },
        [CardDefines.Chair.Right] = { line=lineRigthToTop, tips=tipsRightToTop },
        [CardDefines.Chair.Left] = { line=lineLeftToTop, tips=tipsLeftToTop },
    })
    self._playerInfos[CardDefines.Chair.Left] = PlayerInfo.new(seekNodeByName(self, "Image_user1", "ccui.ImageView"), {
        [CardDefines.Chair.Down] = { line=lineDownToLeft, tips=tipsDownToLeft },
        [CardDefines.Chair.Right] = { line=lineRigthToLeft, tips=tipsRightToLeft },
        [CardDefines.Chair.Top] = { line=lineLeftToTop, tips=tipsLeftToTop },
    })

    for k,v in pairs(self._playerInfos) do
        v:reset()
    end

    self._helpTips = HelpTips.new(seekNodeByName(self, "Image_help_bd", "ccui.ImageView"))
    self._helpTips:hide()

    self._ipTips = IPSameTisNew.new(seekNodeByName(self, "Image_jst_Gps", "ccui.ImageView"))
    self._ipTips:hide()

    self._txtHelpContent = seekNodeByName(self._helpTips, "Text_help", "ccui.Text")
    self._txtHelpContent:setString(config.STRING.UIGPS_HELP_TEXT_STRING_100)    
end

--显示函数
function UIGpsNew:onShow(...)
    Logger.debug("UIGpsNew:onShow()")
	--界面显示逻辑
    local args = {...}

	local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
	if securityChecker == nil then
		return
    end
    local isWatcher = game.service.LocalPlayerService.getInstance():isWatcher() or false;
    self._btnDismiss:setVisible(not isWatcher)
    self._btnEnsure:setPositionPercent(cc.p(0.2,self._btnEnsure:getPositionPercent().y))
    if isWatcher then 
        self._btnEnsure:setPositionPercent(cc.p(0.5,self._btnEnsure:getPositionPercent().y))
    end
    
    securityChecker:addEventListener("EVENT_SRCURITY_INFO_CHANGED", handler(self, self._onSecurityInfoChanged), self)
    -- 先手动更新一次
    self:_onSecurityInfoChanged()
end

--隐藏函数
function UIGpsNew:onHide()
    Logger.debug("UIGpsNew:onHide()")
    --界面隐藏逻辑
	if game.service.RoomService.getInstance() then
		local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
		if securityChecker ~= nil then
			securityChecker:removeEventListenersByTag(self)
		end	
	end
    self:_clear()
end

--返回界面层级
function UIGpsNew:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIGpsNew:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal
end

--是否需要遮罩
function UIGpsNew:needBlackMask()
	return true
end

--关闭时操作
function UIGpsNew:closeWhenClickMask()
	return false
end

-- 标记为Persistent的UI不会destroy
function UIGpsNew:isPersistent()
	return false
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIGpsNew:isFullScreen()
	return false
end

--自己的逻辑
--TODO:
function UIGpsNew:_close()
    UIManager:getInstance():destroy("UIGpsNew")
end

-- 解散房间
function UIGpsNew:_onBtnDismiss()
	game.service.TDGameAnalyticsService.getInstance():onEvent("UI_GPS_NEW_DISMISS_ROOM")
	local gameService = gameMode.mahjong.Context.getInstance():getGameService();
	local isInBattle =  gameService._isGameStarted
	local isHadBeginFirstGame = game.service.RoomService.getInstance():isHaveBeginFirstGame()
	if (isInBattle or isHadBeginFirstGame) == false then
		game.service.RoomService.getInstance():quitRoom()
	else
		game.service.RoomService.getInstance():startVoteDestroy()
	end
    self:_close()
end

-- ？的点击回调
function UIGpsNew:_onBtnTipsClick(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self._helpTips:show()
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self._helpTips:hide()
	end
end

-- 开始更新数据
function UIGpsNew:_update()
	local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
	if securityChecker == nil then
		return
	end
    self:_updateGps()
    self:_updateIp()
end

-- 清除显示过的状态，恢复到初始
function UIGpsNew:_clear()
    Logger.debug("UIGpsNew:_clear()")
    for k,v in pairs(self._playerInfos) do
        v:reset()
    end
    self._ipTips:reset()
end

-- 是否GPS信息有更新的回调，另第一次显示也会调用
function UIGpsNew:_onSecurityInfoChanged()
    Logger.debug("UIGpsNew:_onSecurityInfoChanged()")
    -- 先清除一下状态，回复到开始的情况，开始新一轮的赋值
    self:_clear()
    self:_update()
end

-- 更新GPS信息
function UIGpsNew:_updateGps()
    Logger.debug("UIGpsNew:_updateGps()")
	local roomService = game.service.RoomService.getInstance();
	local securityChecker = roomService:getSecurityChecker();
	local gameService = nil
	if gameMode.mahjong.Context.getInstance() then
		gameService = gameMode.mahjong.Context.getInstance():getGameService()
	end
    if not gameService then
        return
    end
    
    local player = nil
    local playerTarget = nil
    local seat = nil
    local seatTarget = nil
    -- 将相关的距离信息更新
	for idx,info in ipairs(securityChecker:getSecurityInfo().gpsDistanceInfos) do
        -- local playerName = kod.util.String.getMaxLenString(self:_getLimitName(roomService:getPlayerById(info.roleId).name), 8)
        player = gameService:getPlayerProcessorByPlayerId(info.roleId)
        playerTarget = gameService:getPlayerProcessorByPlayerId(info.conflictRoleId)
        seat = player:getRoomSeat():getChairType()
        seatTarget = playerTarget:getRoomSeat():getChairType()

        -- 直接将相关信息更新到UI上面去，这里的ip可能并不会显示，显示与否取决于下面是否有IP冲突信息
        self._playerInfos[seat]:updateGpsInfo(seatTarget, info.distance)
    end

    -- 将头像跟ip更新
    local headIconUrl = nil
    local ip = nil
    for idx,info in ipairs(securityChecker:getSecurityInfo().playerInfos) do
        -- 头像链接
        headIconUrl = roomService:getPlayerById(info.roleId).headIconUrl
        -- ip
        ip = roomService:getPlayerById(info.roleId).ip
        player = gameService:getPlayerProcessorByPlayerId(info.roleId)
        seat = player:getRoomSeat():getChairType()
        -- 更新
        self._playerInfos[seat]:setPlayerInfo(headIconUrl, ip)
    end
end

-- 更新ip冲突相关
function UIGpsNew:_updateIp()
    Logger.debug("UIGpsNew:_updateIp()")
    -- 当前的显示规则跟以前的不一样，直接重写一下吧
	local roomService = game.service.RoomService.getInstance()
	local securityChecker = roomService:getSecurityChecker();
	local gameService = nil
	if gameMode.mahjong.Context.getInstance() then
		gameService = gameMode.mahjong.Context.getInstance():getGameService()
	end
    if not gameService then
        return
    end

    -- 相同ip的表
    local ipConflictPlayer = {}
    local playerInfos = securityChecker:getSecurityInfo().playerInfos or {}
    local name = nil
    local player = nil
    local seat = nil
	for i=1,#playerInfos do
		local player1 = playerInfos[i]

		-- 检测冲突
		for j=i+1,#playerInfos do
            local player2 = playerInfos[j]
            
            -- 如果有相同的IP
            if player1.ip == player2.ip then
                -- 将IP显示出来, player1
                player = gameService:getPlayerProcessorByPlayerId(player1.roleId)
                seat = player:getRoomSeat():getChairType()
                self._playerInfos[seat]:showIP()
                -- 将IP显示出来, player2
                player = gameService:getPlayerProcessorByPlayerId(player2.roleId)
                seat = player:getRoomSeat():getChairType()
                self._playerInfos[seat]:showIP()

                -- 将相同IP的名字保存下来
                name = kod.util.String.getMaxLenString(roomService:getPlayerById(player1.roleId).name, 8)
                ipConflictPlayer[player1.ip] = ipConflictPlayer[player1.ip] or {}
				if table.indexof(ipConflictPlayer[player1.ip], name) == false then
					table.insert(ipConflictPlayer[player1.ip], name)
				end
                name = kod.util.String.getMaxLenString(roomService:getPlayerById(player2.roleId).name, 8)
				if table.indexof(ipConflictPlayer[player1.ip], name) == false then
					table.insert(ipConflictPlayer[player1.ip], name)
				end
			end
		end
	end

    -- ipConflictPlayer["1.1.1.1"] = {"AABBCCDD", "BBCCDDEE"}
    -- ipConflictPlayer["1.1.1.2"] = {"AABBCCDD", "BBCCDDEE"}
    -- 每一个key是一个冲突组，最多2组
    local tips
	for k,v in pairs(ipConflictPlayer) do
        tips = string.format("%s 正在相同IP下进行游戏", table.concat(v, ","))
        self._ipTips:add(tips)
    end
end

return UIGpsNew