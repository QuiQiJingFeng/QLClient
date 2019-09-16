--[[
-- 布局类
--]]
local SubCardLayout = class("SubCardLayout")

function SubCardLayout:ctor()
	self.lineSize = 0;				-- 每一行能够放几张牌
	self.anchor = cc.p(0, 0); 		-- 放置牌的起点;
	self.advance = cc.p(0, 0); 		-- 牌间距
	self.lineadvance = cc.p(0, 0);	-- 行间距
	self.zOrder = 0;				-- zOrder起点
	self.zOrderadvance = 0; 		-- zOrder牌间距
	self.zOrderLineAcvance = 0; 	-- zOrder行间距	
end

local CardLayout = class("CardLayout")
function CardLayout:ctor()
	-- 手牌区	
	self.anchor = cc.p(0, 0);				-- 手牌锚点,手牌的最后一张,摸到的牌之前的那张, 	
	self.bgAdvance = cc.p(0, 0);			-- 手牌的间隔 	
	self.bgAcvanceLie = cc.p(0, 0); 		-- 平放手牌的间隔 	
	self.drawCardSpace = cc.p(0, 0); 		-- 手牌与刚摸的那张牌之间的间隔
	self.cardGroupSpace = cc.p(0, 0); 			-- 吃碰杠手牌,之间的空隙 	
	self.gangOffset = cc.p(0, 0);			-- 杠牌上面牌的偏移量 	
	self.gangOffsetLie = cc.p(0, 0); 		-- 吃碰杠等横倒的牌与手牌的偏移量 		
	self.gangOffsetLie_mingDa = cc.p(0, 0); -- 明打时候吃碰杠等横倒的牌与手牌的偏移量 		
	self.gangZOrderOffset = 0;				-- 杠牌上面牌的zorder偏移量 	
	self.zOrder = 0;						-- zOrder开始值 
	self.zOrderHu = 0;						-- 胡牌高亮显示时的zOrder开始至 	
	self.zOrderAcvance = 0;					-- 每张牌之间的zOrder间隔 

	self.discardedAniStart = cc.p(0, 0);	-- 打牌,吃碰杠等动画的起点 	
	self.discardedAniStartZOrder = 0;		-- 打牌动画的起点zorder 

	self.cardadvance = 0;					-- 一张竖牌占用的宽度	
	self.cardScale = 0;						-- 当前竖牌的缩放值	
	self.cardLieadvance = 0;				-- 横放竖牌的基础宽度	
	self.cardGroupScale = 0;				-- 吃碰/扛/牌的缩放值

	self._cardOffset = nil					-- 当前局牌从那里开始排起

	self.discardedLayout = SubCardLayout.new();	-- 出牌区
	self.huaLayout = SubCardLayout.new();		-- 花牌区
	self.huLayout = SubCardLayout.new();		-- 胡牌区

	self.opBtnAnchor = cc.p(0, 0);				-- 操作按钮起始位置
	self.opBtnAdvance = cc.p(0, 0);				-- 操作按钮操作按钮之间间隔
	self.opBtnRotation = 0						-- 操作按钮的旋转
	self.opBtnScale = 1;						-- 操作按钮的缩放

	self.huStatusPosition = cc.p(0,0)		    -- 胡那张图片所在的位置

	self.handCardColor = cc.c3b(255,255,255)	-- 首牌的顶点颜色
	self.discardColor = cc.c3b(255,255,255)		-- 打出牌的顶点颜色
	self.samecardColor = cc.c3b(166,218,237)			
end

-- 所有竖手牌的距离已经是固定的了，这里要是用来求 吃/碰/扛
-- 再描述一下，锚点在中心，一张计算距离，还要知道上一张牌的宽度
-- @param firstCard: boolean 	是不是第一张牌，如果是第一张牌，只需要知道当前卡的一半
-- @param isTrans: boolean 		是不是横向牌
-- @param lastIsTrans: boolean	前一张是不是横向牌
-- @return cc.p
function CardLayout:getAdvance(firstCard)
	if firstCard then
		return cc.pMul(self.bgAcvanceLie, 0.5);
	else
		return clone(self.bgAcvanceLie);
	end
end

-- @param hasHu: boolean
function CardLayout:getZOrder(hasHu)
	if hasHu == true then
		return self.zOrderHu;
	else
		return self.zOrder;
	end
end

--[[
-- 每个玩家作为的基类
--]]
local UIRoomSeat = class("UIRoomSeat")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local UIElemChat = require("app.gameMode.mahjong.ui.UIElemChat")

local UI_ANIM = require("app.manager.UIAnimManager")

function UIRoomSeat:ctor(parentUI, chairType)
	self._parentUI = parentUI;
	self._cardNode = seekNodeByName(parentUI, "Panel_Scene", "ccui.Layout")
	self._chairType = chairType;
	self._cardLayout = CardLayout.new()
	self._roomSeat = nil;

	self._cardOffset = 0;
	
	self._root = nil
	-- 绑定UI控件
	self._imgHightLight = nil
	self._animFrame = nil
	self._headFrame = nil
	-- 特殊控件
	self._effetHightLight = nil
	self._imgPlayerIcon = nil
	self._lablePlayerName = nil
	self._lableTotalScore = nil
	self._imgBankerIcon = nil
	self._imgOffLineIcon = nil
	self._imgOffLineTips = nil
	self._imgCustomIcon = nil
	self._imgCustomIcon2 = nil
	self._imgMessageBorder = nil
	self._lableMessage = nil
	self._imgMessageIcon = nil
	self._imgTalk = nil
	self._imgReady = nil
	self._effectNode = nil
	self._playerProcessor = nil
	self._bmBankCount = nil
	self._bgBankCount = nil
	self._imgTrustIcon = nil
	self._maxCardNumber = -1

	-- 状态图标
	self._statusImgWidget = {}
	self._statusPlayType = {}

	self._indicatorCenterImage = nil
	
	-- 操作按钮支持
	self._waitingOpBtns = {}
	self._operationBtns = {}
	
	--聊天框
	self._elemChat = UIElemChat.new();

	-- 回放的时候操作按钮的提示
	self._animTips = nil

	-- 胡牌后的状态显示
	self._huStatus = nil

	--当前是否可以胡牌
	self._isCanHu = nil

	-- 放大牌回调
	self._mustRunCallback = nil

	-- 用来展示的特效牌
	self._showCards = {}

	self:initialize()
end

function UIRoomSeat:initialize()
--	bindEventCallBack(self._imgPlayerIcon, handler(self, self._onClickPlayerIcon), ccui.TouchEventType.ended);
game.service.LocalPlayerSettingService.getInstance():addEventListener( "EVENT_CLOSE_CARD_SCALE", function (event)
		if self._mustRunCallback ~= nil then
			self._mustRunCallback(event)
		end
	end, self);

end

function UIRoomSeat:dispose()
	self._elemChat:destroy()
	if self._huStatus then 
		self._huStatus:removeFromParent()
		self._huStatus = nil
	end
	if next(self._operationBtns) then
		for k,val in pairs(self._operationBtns) do
			val:removeFromParent()
		end
		self._operationBtns = {}
	end

	self:clearShowCards()

	game.service.LocalPlayerSettingService.getInstance():removeEventListenersByTag(self)
end

function UIRoomSeat:updateDiscardedLayout()
end

function UIRoomSeat:clearShowCards()
	if next(self._showCards) then
		for k,val in pairs(self._showCards) do
			CardFactory:getInstance():releaseCard(val)			
			val:removeFromParent()
		end
		self._showCards = {}
		self._mustRunCallback = nil
	end
end

function UIRoomSeat:setPlayerProcessor(processor)
	Macro.assertFalse(self._playerProcessor == nil or processor == nil)
	self._playerProcessor = processor
end

function UIRoomSeat:getChairType()
	return self._chairType;
end

function UIRoomSeat:getCardLayout()
	return self._cardLayout;
end

function UIRoomSeat:getCardParentNode()
	return self._cardNode
end

function UIRoomSeat:getPlayerProcessor()
	return self._playerProcessor
end

function UIRoomSeat:setRoomSeat(roomSeat)
	self._roomSeat = roomSeat;
end

function UIRoomSeat:getRoomSeat()
	return self._roomSeat;
end

function UIRoomSeat:getEffectNode()
	return self._effectNode
end

-- @param isTarget: bool
-- @return CardDefines.Chair
function UIRoomSeat:relativeChair(isTarget)
	if isTarget then
		if self._chairType == CardDefines.Chair.Left then
			return CardDefines.Chair.Down
		else
			return self._chairType + 1;
		end
	else
		return self._chairType;
	end
end

-- 重置所有显示为空位子
function UIRoomSeat:clearSeat()	
	self._root:setVisible(false)
	self._elemChat:hideAll();
	self:clearGameUI()
	self._imgHightLight:setVisible(false);
	self._imgPlayerIcon:setVisible(false); -- TODO : 重置为默认Icon
	self:setPlayerName("")
	self:setTotalScore(nil)
	self:setBanker(false)
	self:setStatusImage(false)
	self:setStatusImage2(false)
	self:setPlayerOnline(false)
	self._imgMessageBorder:setVisible(false)
	self._lableMessage:setVisible(false)
	self._imgMessageIcon:setVisible(false)
	self._imgTalk:setVisible(false)
	self._imgReady:setVisible(false)
	self._hasHuWhenBattleFinished = false
	self._bgBankCount:setVisible(false)

	self:setTrusteeshipIcon(false)
	if self._animTips then
		self._animTips:hide()
		self._animTips = nil
	end
	if self._animFrame then
		self._animFrame:hide()
		self._animFrame = nil
	end
	if self._huStatus ~= nil then
		self._huStatus:setVisible(false)
	end
end

-- 清除牌局数据, 牌局结束时调用
function UIRoomSeat:clearGameUI()
end

-- 点击玩家头像的回调
function UIRoomSeat:_onClickPlayerIcon()
	-- TODO : 显示玩家信息
end

-- 手牌缩放
function UIRoomSeat:CARD_SCALE()
	return self._cardLayout.cardScale
end

-- 吃碰杠缩放
function UIRoomSeat:GROUP_SCALE()
	return self._cardLayout.groupScale
end

-- 弃牌缩放
function UIRoomSeat:DISCARD_SCALE()
	return self._cardLayout.discardedLayout.scale
end

-- 平放手牌缩放
function UIRoomSeat:GROUP2_SCALE()
	return (self._cardLayout.bgAdvance.x ~= 0 and self._cardLayout.bgAdvance.x or self._cardLayout.bgAdvance.y) / (self._cardLayout.bgAcvanceLie.x ~= 0 and self._cardLayout.bgAcvanceLie.x or self._cardLayout.bgAcvanceLie.y) * self:GROUP_SCALE()
end

-- 设置玩家基本数据
function UIRoomSeat:setPlayerData(player)
	if player == nil then
		self._root:setVisible(false)
		self._imgPlayerIcon:setVisible(false); -- TODO : 重置为默认Icon
		return
	else
		self._root:setVisible(true)
		self._root:setLocalZOrder(1000)
		self._imgPlayerIcon:setVisible(true); -- TODO : 重置为默认Icon
		self._root:setTouchEnabled(true)
		--提审相关（IP信息隐藏）
		if not GameMain.getInstance():isReviewVersion() then
			bindEventCallBack(self._root, handler(self, self._onClickPlayerHead), ccui.TouchEventType.ended);
		end
	end
	
	self:setPlayerName(player.name)
	self:setPlayerIcon(player.headIconUrl)
	self:setPlayerFrame(player.headFrame)
	self:setTotalScore(player.totalPoint)
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	self:setPlayerReady(player:isReady() and not gameService:isGameStarted() and not campaign.CampaignFSM.getInstance():getCurrentState():getIsInBattle() and not player:isWaiTing() and game.service.RoomService.getInstance():getRoomType()~=game.globalConst.roomType.gold)
	self:setBanker(player:isBanker())

	self:setPlayerOnline(true)
	if not player:isOnline() then
		self:setPlayerOnline(player:isOnline(), "离线")
	end
	if player:isWaiTing() then
		self:setPlayerOnline(not player:isWaiTing(), "等待中") 
	end

	-- 更新玩家对话框类型
	local effects = player:getSpecialEffect()
	self:_updateDialogFrame(effects)
end

function UIRoomSeat:_updateDialogFrame(effects)
	
end

-- 设置头像框
function UIRoomSeat:setPlayerFrame(id)
	if id ~= nil then
		game.util.PlayerHeadIconUtil.setIconFrame(self._imgPlayerIcon,PropReader.getIconById(id),0.56)
	end
end

-- 设置玩家名字
function UIRoomSeat:setPlayerName(name)
	self._lablePlayerName:setString(kod.util.String.getMaxLenString(name, 8))
end

function UIRoomSeat:setPlayerIcon(iconPath)
	game.util.PlayerHeadIconUtil.setIcon(self._imgPlayerIcon, iconPath)
end

function UIRoomSeat:_onClickPlayerHead()
	if game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
		UIManager:getInstance():show("UIGoldPlayerInfo", self:getRoomSeat():getPlayer())
		return
	end

	-- 防止该玩家不在房间内
	if self:getRoomSeat():getPlayer() == nil then
		return
	end
	
	local _name 	= self:getRoomSeat():getPlayer().name
	local _id 		= self:getRoomSeat():getPlayer().roleId
	local _ip 		= self:getRoomSeat():getPlayer().ip
	local _url 		= self:getRoomSeat():getPlayer().headIconUrl
	local _identify = self:getRoomSeat():getPlayer().isIdeneity
	local _headFrame = self:getRoomSeat():getPlayer().headFrame
	-- 不是观战 比赛场 回放（有点强制） 看自己信息的情况下显示魔法表情界面
	if not game.service.LocalPlayerService:getInstance():isWatcher() and
		not campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() and
		not UIManager:getInstance():getIsShowing("UIPlayback") and
		_id ~= game.service.LocalPlayerService:getInstance():getRoleId() then

		game.service.ChatService:getInstance():sendCGQueryEmojiREQ(self:getRoomSeat():getPlayer())
		return
	end

	UIManager:getInstance():show("UIPlayerinfo2",_name,_id,_ip,_url,_identify,_headFrame);
end

-- 设置玩家当前总分数
function UIRoomSeat:setTotalScore(totalPoint)
    -- 如果是在金币场内的话，本地玩家使用自己的金币数量，因为 totalPoint 服务器不好改
    local isWatcher = game.service.LocalPlayerService.getInstance():isWatcher()
    local isDownPlayer = self:getChairType() == CardDefines.Chair.Down
    if not isWatcher and isDownPlayer then
        local isGoldRoom = game.service.LocalPlayerService.getInstance():getCurrentRoomType() == game.globalConst.roomType.gold
        if isGoldRoom then
            totalPoint = game.service.LocalPlayerService.getInstance():getGoldAmount()
        end
    end
	local text = ""
	if totalPoint ~= nil then
		text = kod.util.String.formatMoney(totalPoint, 2)
	end
	self._lableTotalScore:setString(text)
end

-- 设置当前是否为庄家
-- param tf: boolean
function UIRoomSeat:setBanker(tf)
	self._imgBankerIcon:setVisible(tf)
end

-- 设置当前托管状态
function UIRoomSeat:setTrusteeshipIcon(tf)
	self._imgTrustIcon:setVisible(tf)
end

-- 设置状态图标
function UIRoomSeat:setStatusImage(tf, playType)
	-- TODO：动态调整的代码，先不要了，注释先保留
	-- if #self._statusImgWidget == 0 then
	-- 	self._statusImgWidget[1] = self._imgCustomIcon
	-- end
	-- if playType == nil then
	-- 	-- 清空全部
	-- 	for i = 1, #self._statusImgWidget do
	-- 		self._statusImgWidget[i]:setVisible(false)
	-- 	end

	-- 	self._statusPlayType = {}
	-- 	return
	-- end

	-- local skins = {
	-- 	[PlayType.DISPLAY_JI_CHONGFENG] = "mahjong_tile/text_15.png",
	-- 	[PlayType.DISPLAY_JI_ZEREN] = "mahjong_tile/text_14.png",
	-- 	[PlayType.DISPLAY_JI_WUGU_CHONGFENG] = "mahjong_tile/text_15.png",
	-- 	[PlayType.DISPLAY_JI_WUGU_ZEREN] = "mahjong_tile/text_14.png",
	-- 	[PlayType.DISPLAY_TING] = "mahjong_tile/text_27.png",
 --        [CardDefines.CardType.Wan + 10000] = "gaming/icon_wan.png",
 --        [CardDefines.CardType.Tiao + 10000] = "gaming/icon_tiao.png",
 --        [CardDefines.CardType.Tong + 10000] = "gaming/icon_tong.png",
	-- }

	-- local index = -1
	-- if #self._statusPlayType > 0 then
	-- 	for idx, val in ipairs( self._statusPlayType ) do
	-- 		if val == playType then
	-- 			index = idx
	-- 			break
	-- 		end
	-- 	end
	-- end

	-- if tf and index == -1 then
	-- 	-- 添加一个显示图标
	-- 	table.insert(self._statusPlayType, playType)
	-- elseif not tf and index ~= -1 then
	-- 	-- 移除一个显示图标（需要更新全部的图标）
	-- 	table.remove(self._statusPlayType, index)
	-- end

	-- -- 更新图标显示
	-- local lastImg = nil
	-- local index = nil
	-- for idx, val in ipairs( self._statusPlayType ) do
	-- 	local img = nil
	-- 	if self._statusImgWidget[idx] == nil then
	-- 		img = cc.Sprite:create()
	-- 		self._imgCustomIcon:getParent():addChild(img)
	-- 		table.insert(self._statusImgWidget, img)
	-- 	else
	-- 		img = self._statusImgWidget[idx]
	-- 	end

	-- 	img:setTexture(skins[val])
	-- 	img:setVisible(true)
	-- 	if lastImg ~= nil then
	-- 		local x,y = lastImg:getPosition()
	-- 		local size = lastImg:getContentSize()
	-- 		local size2 = img:getContentSize()
	-- 		local x = x + size.width/2 + size2.width/2
	-- 		img:setPosition(cc.p(x,y))
	-- 	end
	-- 	lastImg = img

	-- 	index = idx
	-- end

	-- for i = index + 1, #self._statusImgWidget do
	-- 	self._statusImgWidget[i]:setVisible(false)
	-- end

	local skins = {
		[PlayType.DISPLAY_JI_SHOUQUAN] 			= {btn = self._imgCustomIcon, skin = "Icon/icon_pc.png"},
		[PlayType.DISPLAY_JI_CHONGFENG] 		= {btn = self._imgCustomIcon, skin = "Icon/icon_pc.png"},
		[PlayType.DISPLAY_JI_ZEREN] 			= {btn = self._imgCustomIcon, skin = "Icon/icon_pz.png"},
		[PlayType.DISPLAY_JI_WUGU_CHONGFENG] 	= {btn = self._imgCustomIcon2, skin = "Icon/icon_wc.png"},
		[PlayType.DISPLAY_JI_WUGU_ZEREN] 		= {btn = self._imgCustomIcon2, skin = "Icon/icon_wz.png"},
		[PlayType.DISPLAY_TING] 				= {btn = self._imgTing, skin = ""},
        [CardDefines.CardType.Wan + 10000] 		= {btn = self._imgLack, skin = "Icon/icon_wan.png"},
        [CardDefines.CardType.Tiao + 10000] 	= {btn = self._imgLack, skin = "Icon/icon_tiao.png"},
        [CardDefines.CardType.Tong + 10000] 	= {btn = self._imgLack, skin = "Icon/icon_tong.png"},
	}

	if not tf and playType == nil then
		-- 清空所有的显示
		for _, val in pairs( skins ) do
			val.btn:setVisible(false)
		end
	else
		local config = skins[playType]
		if config ~= nil then
			-- 显示
			config.btn:setVisible(tf)
			-- 更新当前的icon图标
			if config.skin ~= nil and config.skin ~= "" then
				config.btn:setTexture(config.skin)
			end
		end
	end
end

-- 设置状态图标
function UIRoomSeat:setStatusImage2(tf, skin)
	if tf == true then
		self._imgCustomIcon2:setVisible(true)
		self._imgCustomIcon2:setTexture(skin)
		self._imgCustomIcon:setScale(1)
	else
		self._imgCustomIcon2:setVisible(false)
	end
end

-- 设置玩家是否在线
function UIRoomSeat:setPlayerOnline(tf, text)
	self._imgOffLineTips:setVisible(false)
	if text ~= nil then
		self._imgOffLineIcon:setString(text)
		self._imgOffLineTips:setVisible(text == "离线" and not game.service.RoomService:getInstance():isHaveBeginFirstGame() and game.service.RoomService:getInstance():getRoomClubId() ~= 0)
	end
	self._imgOffLineIcon:setVisible(tf == false)
end

-- 显示玩家是否已经准备好
function UIRoomSeat:setPlayerReady(tf)
	self._imgReady:setVisible(tf)
end

-- 设置状态文本
function UIRoomSeat:setStatusLable(value)
end

function UIRoomSeat:setHuStatus(status)
    local hu_skin = {
        [PlayType.HU_ZI_MO .. 1] = "Icon/icon_suanfen_zimo.png",
        [PlayType.HU_ZI_MO .. 0] = "Icon/icon_suanfen_jiaopao.png",
        [PlayType.HU_DIAN_PAO .. 1] = "Icon/icon_suanfen_dianpao.png",
		[PlayType.HU_DIAN_PAO .. 0] = "Icon/icon_suanfen_dianpao1.png",
		[PlayType.HU_DIAN_PAO .. 2] = "Icon/icon_suanfen_hupai.png",
        [PlayType.HU_JIAO_PAI .. 1] = "Icon/icon_suanfen_jiaopao.png",
        [PlayType.HU_JIAO_PAI .. 0] = "Icon/icon_suanfen_jiaopao.png",
        [PlayType.HU_WEI_JIAO_PAI .. 1] = "Icon/icon_suanfen_weijiaopai.png",
        [PlayType.HU_WEI_JIAO_PAI .. 0] = "Icon/icon_suanfen_weijiaopai.png",
		[PlayType.HU_MEN_HU .. 1] = "Icon/icon_suanfen_jiaopao.png",
        [PlayType.HU_MEN_HU .. 0] = "Icon/icon_suanfen_jiaopao.png",
    }
	if next(status) == nil then
		return
	end
	local index = status.playType .. status.op
	if self._huStatus == nil then
		self._huStatus = ccui.ImageView:create(hu_skin[index])
		self._parentUI:addChild(self._huStatus)
		self._huStatus:setPosition(self:getHuStatusPosition())
	end
	self._huStatus:setVisible(true)
	self._huStatus:loadTexture(hu_skin[index])
end

function UIRoomSeat:getHuStatusPosition()
	return self:getCardLayout().huStatusPosition
end

-- 显示操作指示器
function UIRoomSeat:showIndicator(tf)
	self._imgHightLight:setVisible(false)
	self._indicatorCenterImage:setVisible(tf)

	if self._animFrame == nil then
		self._animFrame = UI_ANIM.UIAnim.new("ui/csb/Effect_frame.csb")
		self._imgHightLight:getParent():addChild(self._animFrame._csbAnim)
		self._animFrame._csbAnim:setPosition(cc.p(self._imgHightLight:getPosition()))
		self._animFrame:play(nil, nil, true, -1)
		self._animFrame._csbAnim:setLocalZOrder(-1)
	end

	self._animFrame._csbAnim:setVisible(tf)
end

function UIRoomSeat:createCard(cardState, cardValue, tagIconType, scale)
	local card = CardFactory:getInstance():createCard2(self._chairType, cardState, cardValue, tagIconType, scale)
	self:getCardParentNode():addChild(card);
	return card;
end

function UIRoomSeat:releaseCard(card)
	
end

--[[*
 * 播放打出的牌到出牌区的动画
 * cardDiscard.cardNumber可能是无效的，使用cardValue创建
 *]]
function UIRoomSeat:onDiscardACard(cardValue)
	local effectChuPaiFangDaTriggle = game.service.LocalPlayerSettingService:getInstance():getEffectValues().effect_ChuPaiTingLiu
	
	-- 这张牌包含了动画、显示在出牌区所有功能
	local card = CardFactory:getInstance():createCard2(self._chairType, CardDefines.CardState.Chupai, cardValue, nil, self._cardLayout.discardedLayout.scale)
	card:changeColor(self._cardLayout.discardColor)
    self._playerProcessor._cardList:addDiscardedCard(card)
    self:getCardParentNode():addChild(card)
	
	-- 开始动画
	-- 移动到 *打牌动画* 开始的地方
	card:setPosition(self._cardLayout.discardedAniStart)
	-- 设置层级
	card:setLocalZOrder(self._cardLayout.discardedAniStartZOrder)

	-- 获得牌应该在桌面的位置
	local discardPlace = self:ManageDiscardedMahjongPositions(self._playerProcessor._cardList, self._cardLayout, false, {card})[card]
	local scale2Big = cc.ScaleTo:create(effectChuPaiFangDaTriggle and 0.05 or 0.1, 2)
	local delay = cc.DelayTime:create(0.75)
	local scale2DiscardSize = cc.ScaleTo:create(0.1, self:DISCARD_SCALE())
	local move2DiscardPos = cc.MoveTo:create(effectChuPaiFangDaTriggle and 0.1 or 0.1, cc.p(discardPlace.pos.x, discardPlace.pos.y))
	local callback = cc.CallFunc:create(function()
		-- 重新排序
		card:setLocalZOrder(discardPlace.zOrder)
		card:setPosition(cc.p(discardPlace.pos.x, discardPlace.pos.y))
		local gameService = gameMode.mahjong.Context.getInstance():getGameService()	
		if not effectChuPaiFangDaTriggle then	
			gameService:getRoomUI():markDiscardedCardIndicator(card) -- 动画完成, 设置新打出的牌标记		
		end		
	end)

	game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})

	local show_card = CardFactory:getInstance():createCard2(CardDefines.Chair.Down, CardDefines.CardState.Chupai, cardValue, nil, self._cardLayout.discardedLayout.scale)
	show_card:setPosition(self._cardLayout.discardedAniStart)
	table.insert( self._showCards, show_card)

	card:setVisible(false)

	local showDelay = cc.DelayTime:create(0.45)		

	if effectChuPaiFangDaTriggle then 
		-- 设置层级
		show_card:setLocalZOrder(self._cardLayout.discardedAniStartZOrder)
		self:getCardParentNode():addChild(show_card)	

		--出牌停留
		local showSeq = cc.Sequence:create(scale2Big)
		show_card:runAction(showSeq)
		
		self._mustRunCallback = nil
		self._mustRunCallback = function (event)
			local scale2DiscardSize = cc.ScaleTo:create(0.05, self:DISCARD_SCALE())
			local move2DiscardPos = cc.MoveTo:create(0.05, cc.p(discardPlace.pos.x, discardPlace.pos.y))
			local showCardCallback = cc.CallFunc:create(function()
				-- 重新排序
				-- card:setLocalZOrder(discardPlace.zOrder)
				-- card:setPosition(cc.p(discardPlace.pos.x, discardPlace.pos.y))

				card:setVisible(true)

				-- 一系列操作删除showcards
				table.foreach(self._showCards, function ( k, v)
					if v == show_card then
						table.remove(self._showCards, k)
					end
				end)
				show_card:removeFromParent()
				CardFactory:getInstance():releaseCard(show_card)
			end)
			local seqShowCard = cc.Sequence:create(scale2DiscardSize, move2DiscardPos ,showCardCallback)
			show_card:runAction(seqShowCard)	
			self._mustRunCallback = nil		
		end

		local gameService = gameMode.mahjong.Context.getInstance():getGameService()
		gameService:getRoomUI():hideDiscardedCardIndicator()
	else
		-- 设置层级
		show_card:setLocalZOrder(self._cardLayout.discardedAniStartZOrder)
		self:getCardParentNode():addChild(show_card)	
		
		local myCallback = cc.CallFunc:create(function ()		
			card:setVisible(true)

			-- 一系列操作删除showcards
			table.foreach(self._showCards, function ( k, v)
				if v == show_card then
					table.remove(self._showCards, k)
				end
			end)
			show_card:removeFromParent()
			CardFactory:getInstance():releaseCard(show_card)
		end)
		-- 出牌不停留
		local showSeq = cc.Sequence:create(scale2Big,showDelay, scale2DiscardSize, move2DiscardPos ,myCallback)
		show_card:runAction(showSeq)
	end

	local seq = cc.Sequence:create(delay , callback)
	card:runAction(seq)
end

function UIRoomSeat:runTipsAction(discardLayout, card, scale2DiscardSizeAction, callbackAction)
	-- local show_card = CardFactory:getInstance():createCard2(self._chairType, CardDefines.CardState.Chupai, card._cardValue, self._cardList:getCardCornerTypes(cardValue), self._cardLayout.discardedLayout.scale)
	-- local size = discardLayout:getContentSize()
	-- discardLayout:setVisible(true)
	-- discardLayout:addChild(show_card)
	-- show_card:setScale(1.5)
	-- show_card:setPosition(size.width / 2, size.height / 2)
	-- discardLayout:getParent():setLocalZOrder(10000)
	-- card:setVisible(false) -- 播放出牌放大动画，就暂时隐藏这个牌，动画播完了再显示

	-- local task = nil
	-- local mustRunCallback = function () 
	-- 	card:setVisible(true)
	-- 	discardLayout:setVisible(false)
	-- 	CardFactory:getInstance():releaseCard(show_card)
	-- 	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(task)
	-- end

	-- local speed = 1
	-- local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	-- if iskindof(gameService, "GameService_MahjongReplay") == true then
	-- 	speed = speed / gameService:getReplaySpeedIdx() 
	-- end
	-- task = cc.Director:getInstance():getScheduler():scheduleScriptFunc(mustRunCallback, speed, false)
	
	-- local delay = cc.DelayTime:create(0.5)
	-- local seq = cc.Sequence:create(scale2DiscardSizeAction, delay, callbackAction)
	-- card:runAction(seq)
end

-- 显示刚摸到的牌
function UIRoomSeat:onDrawCard(card)
	local place = self:ManageCardsPositions(self._playerProcessor._cardList, self._cardLayout, false, {card})[card];
	card:setPosition(cc.p(place.pos.x, place.pos.y));
	card:setZOrder(place.zOrder)
end

-- 将新摸到的牌插入手牌中
function UIRoomSeat:onInsertDrewCard(card)
	self:ManageCardsPositions(self._playerProcessor._cardList, self:getCardLayout(), true);
end

--当前局的最大牌数
function UIRoomSeat:maxCardNumber()
	return self._maxCardNumber;
end

-- 判断当前玩家操作是否属于过胡
function UIRoomSeat:isGuoHu(targetOp)
	if targetOp == PlayType.OPERATE_PASS and self._isCanHu then
		--当前属于过胡 (操作为过 且 可操作列表中存在胡)
		return true;
	end

	return false;
end

--[[
@ param totalCardsNum number
]]
function UIRoomSeat:maxCardNumberReset(totalCardsNum)
    self._maxCardNumber = totalCardsNum;
    self._cardOffset = math.floor((config.GlobalConfig.MAX_HAND_CARDNUMBER - self._maxCardNumber - 2) / 2);            
end

-----------------------------
-- 手牌布局相关函数
-----------------------------
-- @param cardGroup: CardGroup 	当前要操作的控件
-- @param index: number 		当前cardGroup的索引
-- @param setPos: boolean 		当前操作的控件是不是
-- @param cardsNeedPlaceHolder: Card[] 		当前组内的牌不设置坐标，只是把正确的坐标传出去
-- @param isMingDa 是否是明打，在对齐的时候使用
-- @return {Card, {pos: point, zOrder: number}}
function UIRoomSeat:_getGroupCardPos(cardGroup, index, setPos, cardsNeedPlaceHolder, isMingDa)
	local placeHolders = {}
	local cardLayout = self:getCardLayout()
	
	-- 记录当前的组的所有 坐标，当是最后一个时候，不用重新计算了，直接取用中间的那个
	local pts_back = {};	-- point array
	-- 当牌数少于最大牌数时，做的一个偏移，保持牌看起来是在中间的
	local offset = self._cardOffset;
	-- 当前牌的基准zorder
	local zOrder = cardLayout:getZOrder(self._hasHuWhenBattleFinished);
	
	-- 一个吃碰扛组占用3个竖牌位置
	local currIndex = index * 3 + offset;
	-- 找到当前索引对应所在的坐标

	-- 亮牌后的偏移
	local start = cardLayout.anchor
	if isMingDa and (self._chairType == CardDefines.Chair.Left or self._chairType == CardDefines.Chair.Right) then
		start = cc.pSub(start, cc.pSub(cardLayout.gangOffsetLie_mingDa, cardLayout.gangOffsetLie))
	end

	local pt = cc.pAdd(start, cc.pMul(cardLayout.bgAdvance, currIndex));
	-- 索引对应的zOrder
	zOrder = zOrder + cardLayout.zOrderAcvance * currIndex;
	
	--[[
	-- 由于牌是中心对齐的，所以在设置坐标的时候，一张横牌的占用的空间是两张牌(自己还有下一张)同时计算出来的
	-- 所以要记录一下前面的牌是否是横倒的
	--]]
	local lastIsTrans = false;
	for j=1, #cardGroup.cards do
		local i = j - 1
		local card = cardGroup.cards[j];
		card:changeColor(cardLayout.handCardColor)
		
		-- 步进位置
		local advance = cardLayout:getAdvance(i==0);
		lastIsTrans = card:getChairType() ~= self._chairType;

		-- 牌的修正坐标，为了不影响其它牌，原值是累加的，这一组共用的，这里重新创建一个新的变量
		local ptFix = null;
		zOrder = zOrder + cardLayout.zOrderAcvance
		if i == 3 then
			-- 当是扛牌的那个顶上的牌的时候，这个牌的坐标直接套用中间那张牌就可以了，然后修正坐标以及zorder
			pt = cc.pSub(pts_back[2], cardLayout.gangOffset)
			ptFix = clone(pt);
			zOrder = zOrder + cardLayout.gangZOrderOffset
		else
			pt = cc.pAdd(pt, advance);
			if isMingDa then
				ptFix = cc.pAdd(pt, cardLayout.gangOffsetLie_mingDa);
			else
				ptFix = cc.pAdd(pt, cardLayout.gangOffsetLie);
			end
		end
		
		if setPos == true then
			card:setPosition(ptFix);
			card:setZOrder(zOrder);
			-- TODO：bug 当移动的时候，再次设置坐标，会移动到一个不可控的坐标，清除一下
			if card:getNumberOfRunningActions() > 0 then
				card:stopAllActions()
				card:setScale(self:GROUP_SCALE())
			end
		end
		
		if table.indexof(cardsNeedPlaceHolder, card) ~= false then
			-- 获取放置位置
			placeHolders[card] = { pos = clone(ptFix), zOrder = zOrder }
		end
		table.insert(pts_back, clone(ptFix))
	end

	return placeHolders;
end

-- @param card: Card 当前要操作的控件
-- @param index: number 当前card的索引
-- @param setPos: boolean 当前操作的控件是不是
-- @param cardsNeedPlaceHolder: Card[] 当前组内的牌不设置坐标，只是把正确的坐标传出去
-- @return {Card, {pos: point, zOrder: number}}
function UIRoomSeat:_getHandCardPos(card, index, setPos, cardsNeedPlaceHolder, isMingDa)
--	: kodUtil.Map<Card, { pos: KodGames.Point, zOrder: number }> {
	local placeHolders = {}
	
	if cardsNeedPlaceHolder == nil then
		cardsNeedPlaceHolder = {}
	end
	
	local cardLayout = self:getCardLayout()
	
	-- 记录当前的组的所有 坐标，当是最后一个时候，不用重新计算了，直接取用中间的那个
	local pts_back = {};	-- point array
	-- 当牌数少于最大牌数时，做的一个偏移，保持牌看起来是在中间的
	local offset = self._cardOffset;
	-- 当前牌的基准zorder
	local zOrder = cardLayout:getZOrder(self._hasHuWhenBattleFinished);
	
	-- 亮牌后的偏移
	local start = cardLayout.anchor
	if isMingDa and (self._chairType == CardDefines.Chair.Left or self._chairType == CardDefines.Chair.Right) then
		start = cc.pSub(start, cc.pSub(cardLayout.gangOffsetLie_mingDa, cardLayout.gangOffsetLie))
	end

	-- 这里的坐标实际要延后半张牌的坐标
	local startPoint = cc.pAdd(start, cc.pMul(cardLayout.bgAdvance, 0.5))
	if index == self:maxCardNumber() then
		-- 这张处理成摸牌
		startPoint = cc.pAdd(startPoint, cardLayout.drawCardSpace);
	end
	
	index = index + offset;
	-- 找到当前索引对应所在的坐标
	local pt = cc.pAdd(startPoint, cc.pMul(cardLayout.bgAdvance, index));
	
	-- 索引对应的zOrder
	zOrder = zOrder + cardLayout.zOrderAcvance * (index + 1);
	if setPos == true then
		card:setPosition(pt);
		card:setZOrder(zOrder);
		-- TODO：bug 当移动的时候，再次设置坐标，会移动到一个不可控的坐标，清除一下
		if card:getNumberOfRunningActions() > 0 then
			card:stopAllActions()
			card:setScale(self:CARD_SCALE())
		end
	end
	card:changeColor(cardLayout.handCardColor)
	
	if table.indexof(cardsNeedPlaceHolder, card) ~= false then
		placeHolders[card] = { pos = clone(pt), zOrder = zOrder };
	end

	return placeHolders;
end

--[[
-- 管理手牌位置
-- 统一设置手牌位置及Zorder
-- 会调用cardList.sort();
-- 
-- @param layout: CardLayout 
-- @param setPos: boolean 是设置位置还是单纯计算位置, true表示设置位置, false表示获取位置
-- @param cardsNeedPlaceHolder: Card[] 获取指定牌的位置, 当setPos为TRUE, 不设置这张牌的位置
-- @return {Card, {pos: point, zOrder: number}}
--]]
function UIRoomSeat:ManageCardsPositions(cardList, layout, setPos, cardsNeedPlaceHolder,isDrag)
--	: kodUtil.Map<Card, { pos: KodGames.Point, zOrder: number }> {
	if Macro.assertTrue(self.battleFinished, "self.battleFinished") then
		return;
	end

	if cardsNeedPlaceHolder == nil then
		cardsNeedPlaceHolder = {}
	end

	cardList:sort();
	local placeHolders = {} -- {Card, {pos: point, zOrder: number}}

	-- TODO：各种变态对齐，处理
	local isMingDa = false
	if #cardList.handCards > 0 then
		if self:getChairType() == CardDefines.Chair.Down then
			isMingDa = cardList.handCards[1]._cardState == CardDefines.CardState.Chupai
		else
			isMingDa = cardList.handCards[1]._cardValue ~= 255
		end
	end
	-- TODO：还要在平辅手牌后，左右两家做一下偏移，b了
	-- 大体偏移量为：
	-- cardLayout.gangOffsetLie_mingDa - cardLayout.gangOffsetLie

	local zOrder = layout:getZOrder(self.hasHuWhenBattleFinished);
	for groupIdx=1, #cardList.cardGroups do
		local group = cardList.cardGroups[groupIdx];
		table.foreach(self:_getGroupCardPos(group, groupIdx-1, setPos, cardsNeedPlaceHolder, isMingDa), function(card, val)
			placeHolders[card] = val;
		end)
	end

	-- 一般手牌
	-- 如果提前碰到摸牌，那么后续的牌索引要减1
	local fixIndx = 0;
	local groupIndex = #cardList.cardGroups * 3;
	
	-- 修改为从左到右获取，因为中间有个摸牌的存在，导制index可能会出错，因为最后一张可能不是摸牌，但是确占用了index = 13！
	for cardIdx = 1, #cardList.handCards do
		local card = cardList.handCards[cardIdx];
		local index = 0;
		if card == cardList.lastDrewCard then
			-- 单独放置刚摸到的牌
			fixIndx = 1;
			index = self:maxCardNumber();
		else
			index = groupIndex + cardIdx - fixIndx - 1;
		end

		if index > self:maxCardNumber() and self:maxCardNumber() > 0 then
			-- 出现多牌！ 上传，只上传一次
			local roomService = game.service.RoomService.getInstance();
			local dataEyeService = game.service.DataEyeService.getInstance();
			local gameService = gameMode.mahjong.Context.getInstance():getGameService()
			if roomService ~= nil and dataEyeService:needReportCardListError(roomService:getRoomId(), gameService:getCurrentRoundCount()) then
				local cardsStr = "handCards:["
				for iddx = 1, #cardList.handCards do
					cardsStr = cardsStr .. cardList.handCards[iddx]._cardValue .. ","
				end
				for iddx=1, #cardList.cardGroups do
					local group = cardList.cardGroups[iddx];
					cardsStr = cardsStr .. "["
					for idddx=1, #group.cards do
						cardsStr = cardsStr .. group.cards[idddx]._cardValue .. ","
					end
					cardsStr = cardsStr .. "]"
				end
				cardsStr = cardsStr .. "]"
				dataEyeService:reportCardListError(roomService:getRoomId(), gameService:getCurrentRoundCount(), cardsStr)
			end
		end
		
		table.foreach(self:_getHandCardPos(card, index, setPos, cardsNeedPlaceHolder, isMingDa), function(card, val)
			placeHolders[card] = val;
		end)
	end

	return placeHolders;
end

-- @param cardList: Card[]
-- @param subCardLayout: SubCardLayout 
-- @param setPos: boolean 是设置位置还是单纯计算位置, true表示设置位置, false表示获取位置
-- @param cardsNeedPlaceHolder: Card[] 获取指定牌的位置, 当setPos为TRUE, 不设置这张牌的位置
-- @param keepDrawCard?: boolean
-- @return {Card, {pos: point, zOrder: number}}
function UIRoomSeat:_ManageSubLayoutPositions(cards, subCardLayout, setPos, cardsNeedPlaceHolder)
--	: kodUtil.Map<Card, { pos: KodGames.Point, zOrder: number }> {
	local placeHolders = {} -- {Card, {pos: point, zOrder: number}}
	if cardsNeedPlaceHolder == nil then
		cardsNeedPlaceHolder = {}
	end

	local lineOffset = cc.p(0, 0);
	local offset = clone(lineOffset);
	local zOrder = subCardLayout.zOrder;

	for i = 1, #cards do
		-- 步进位置
		if i ~= 1 then
			if (i-1) % subCardLayout.lineSize == 0 then
				-- 换行了,从下一行开头继续
				lineOffset = cc.pAdd(lineOffset, subCardLayout.lineAdvance)
				offset = clone(lineOffset);
				zOrder = zOrder + subCardLayout.zOrderLineAcvance;
			else
				-- 下一个
				offset = cc.pAdd(offset, subCardLayout.advance);
				zOrder = zOrder + subCardLayout.zOrderAdvance;
			end
		end

		local card = cards[i];
		if table.indexof(cardsNeedPlaceHolder, card) == false then
			if setPos == true then
				card:setPosition(cc.pAdd(subCardLayout.anchor, offset));
				card:setZOrder(zOrder);
			end
		else
			placeHolders[card] = { pos = cc.pAdd(subCardLayout.anchor, offset), zOrder = zOrder };
		end
	end

--[[	if setPos == true then
		self.parent.updateZOrder();
	end
--]]
	return placeHolders;
end


-- 管理打出的牌的位置 
-- @param cardLayout: CardLayout
-- @param setPosition: boolean
-- @param cardsNeedPlaceHolder: Card[] = []
-- @return {Card, {pos: point, zOrder: number}}
function UIRoomSeat:ManageDiscardedMahjongPositions(cardList, cardLayout, setPos, cardsNeedPlaceHolder)
	return self:_ManageSubLayoutPositions(cardList.discardedCardList, cardLayout.discardedLayout, setPos, cardsNeedPlaceHolder);
end


-- 管理花牌（财神牌）位置 
-- @param cardLayout: CardLayout
-- @param setPosition: boolean
-- @param cardsNeedPlaceHolder: Card[] = []
-- @return {Card, {pos: point, zOrder: number}}
function UIRoomSeat:_ManageHuaPositions(cardList, cardLayout, setPos, cardsNeedPlaceHolder)
	return self:_ManageSubLayoutPositions(cardList.huaCards, cardLayout.huaLayout, setPos, cardsNeedPlaceHolder);
end

-- 管理胡牌的位置
-- @param cardLayout: CardLayout
-- @param setPosition: boolean
-- @param cardsNeedPlaceHolder: Card[] = []
-- @return {Card, {pos: point, zOrder: number}}
function UIRoomSeat:_ManageHuPositions(cardList, cardLayout, setPos, cardsNeedPlaceHolder)
	return self:_ManageSubLayoutPositions(cardList.huCards, cardLayout.huLayout, setPos, cardsNeedPlaceHolder);
end

function UIRoomSeat:onLack(lackType)
    if lackType == CardDefines.CardType.Invalid then
        -- 传-1的时候，表示不显示定缺图标
        -- self:setStatusImage(false);
        return;
    end

    -- 设置缺门图标
    self:setStatusImage(true, lackType + 10000);
end

function UIRoomSeat:onMatchResult()
	UIManager:getInstance():show("UIRoundReportPage")
end

--------------------------------
-- 操作按钮相关功能
--------------------------------
function UIRoomSeat:hasWaitingOperation()
	return #self._waitingOpBtns ~= 0
end

function UIRoomSeat:onWaitingOperation(playType, selectCallback, setting)
	-- 获取对应的操作
	local opBtn = self:_getOperationBtn(playType, setting);
	local isReplay = GameFSM.getInstance():getCurrentState().class.__cname == "GameState_MahjongReplay"
	if Macro.assertFalse(opBtn:isVisible() == false or isReplay) then
		table.insert(self._waitingOpBtns, opBtn)

		if playType == PlayType.OPERATE_CAN_HU then
			--当前可胡
			self._isCanHu = true;
		end

		-- console.log("Register waiting operation:" + playType);
--		opBtn.offAll();
		bindEventCallBack(opBtn, function ()
			if opBtn:isVisible() == true then
				Logger.debug("opBtn onClick playType = " .. tostring(playType))
				selectCallback()
			end
		end, ccui.TouchEventType.ended)
	end

	-- 按钮排序
	self:_manageWaitingOpButtons();

	-- 显示操作指示器
--	UIManager.Instance.GetUI<BattlePage>(BattlePage).onWaitingOperation(self.chairType);
end

-- 清除操作按钮
function UIRoomSeat:clearOpButtons()
	for _,btn in ipairs(self._waitingOpBtns) do
		btn:setVisible(false)
		-- TODO : 清除提示
	end
	self._waitingOpBtns = {}
	self._isCanHu = false;

	if self._animTips ~= nil then
		self._animTips._csbAnim:setVisible(false)
	end
end

-- 获取指定操作对应的操作按钮
-- @param playType: number
-- @return button
function UIRoomSeat:_getOperationBtn(playType, setting)
	local btn = self._operationBtns[playType]
	if nil == btn then
		local cardLayout = self:getCardLayout();
		-- 没有，创建一个
		btn = ccui.Button:create(setting.skin, setting.skin)
		btn:setScale(cardLayout.opBtnScale)
		btn:setRotation(cardLayout.opBtnRotation)
		btn:setLocalZOrder(cardLayout.opBtnZorder)
		btn:setVisible(false)
		btn:setAnchorPoint(cc.p(0.5,0.5))

		self:getCardParentNode():addChild(btn)
		self._operationBtns[playType] = btn
	end
	
	return btn
end

-- 玩家正在选在的操作按钮排序
function UIRoomSeat:_manageWaitingOpButtons()
	-- 排序，按照waitingOperationSetting声明的顺序，从右到左
	table.sort(self._waitingOpBtns, function(__btna, __btnb)
		local numa = -1;
		local numb = -1;
		-- TODO : 不应该直接访问_operationSettings
		table.foreach(self._playerProcessor._operationSettings, function(__index, setting)
			local btn = self:_getOperationBtn(setting.op, setting)
			if __btna == btn then
				numa = __index
			end
			if __btnb == btn then
				numb = __index
			end
		end)
		return numa < numb
	end)

	local cardLayout = self:getCardLayout();
	local startPos = clone(cardLayout.opBtnAnchor)
	for i, v in ipairs( self._waitingOpBtns ) do
		local opBtn = v
		opBtn:setVisible(true)
		if i == 1 then
			opBtn:setPosition(startPos)
		else
			local preBtn = self._waitingOpBtns[i - 1]
			local prex, prey = preBtn:getPosition()
			local size = preBtn:getContentSize()
			opBtn:setPosition(cc.p(prex + size.width*cardLayout.opBtnAdvance.x*cardLayout.opBtnScale, 
				prey + size.height*cardLayout.opBtnAdvance.y*cardLayout.opBtnScale))
		end
	end
end

-- 回访时显示将要选择的操作
function UIRoomSeat:hintWaitingOperationResult(playType, operationWaitTime)
	for _, setting in ipairs(self._playerProcessor._operationSettings) do
		if setting.targetOp == playType then
			local btn = self._operationBtns[setting.op]
			if self._animTips == nil then
				self._animTips = UI_ANIM.UIAnim.new("ui/csb/Effect_Point.csb")
				btn:getParent():addChild(self._animTips._csbAnim)
				self._animTips._csbAnim:setLocalZOrder(9999)
				self._animTips._csbAnim:setRotation(btn:getRotation())
			end

			self._animTips:play(nil, nil, true, operationWaitTime)
			self._animTips._csbAnim:setPosition(cc.p(btn:getPosition()))
			self._animTips._csbAnim:setVisible(true)
			return;
		end
	end	
end

function UIRoomSeat:updateBankerCount(count)
	if count > 1 then
		self._bgBankCount:setVisible(true)
		self._bmBankCount:setString("+"..count)
	else
		self._bgBankCount:setVisible(false)
	end
end

--[[
	@param k 判断的关键字 handCards 为手牌， 其它一样
	@param isSameJudge 如果是同色判断
]]
function UIRoomSeat:getColor(k,isSameJudge)
	local color
	if isSameJudge then
		color=self._cardLayout.samecardColor
	elseif k=='handCards' then
		color=self._cardLayout.handCardColor
	else
		color=self._cardLayout.discardColor
	end
	return color
end

--[[
	@param isSameJudge 当前是否是显示同牌
	@param cardValue 当前要处理的牌值
]]
function UIRoomSeat:changeCardColor(isSameJudge, cardValue)
	local v = self._playerProcessor
	-- 当前的吃碰杠
	for i1,v1 in ipairs(v._cardList.cardGroups) do
		if v1.cardState == CardDefines.CardState.Pengpai then
			-- 碰
			for i2,v2 in ipairs(v1.cards) do
				if v2:getCardValue() ~= cardValue then
					break
				end
				v2:changeColor(self:getColor("handCards",isSameJudge), true)
			end
		elseif v1.cardState == CardDefines.CardState.Pengpai then
			-- 吃
			for i2,v2 in ipairs(v1.cards) do
				if v2:getCardValue() == cardValue then
					if v2:getCardValue() == cardValue then
						v2:changeColor(self:getColor("handCards",isSameJudge), true)
					end
				end
			end
		else
			-- 3种杠
			if v1.cards[1]:getCardValue() == cardValue then
				for i2,v2 in ipairs(v1.cards) do
					if v2:getCardValue() ~= cardValue then
						break
					end
					v2:changeColor(self:getColor("handCards",isSameJudge), true)
				end
			end
		end
	end

	-- 当前的弃牌堆
	for i1,v1 in ipairs(v._cardList.discardedCardList) do
		if v1:getCardValue() == cardValue then
			v1:changeColor(self:getColor("",isSameJudge), true)
		end
	end

	-- 当前的已胡牌堆
	for i1,v1 in ipairs(v._cardList.huCards) do
		if v1:getCardValue() == cardValue then
			v1:changeColor(self:getColor("",isSameJudge), true)
		end
	end
end

function UIRoomSeat:clearCards()
end

return UIRoomSeat