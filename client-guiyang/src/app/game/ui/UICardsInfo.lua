local csbPath = "ui/csb/UICardsInfo.csb"
local super = require("app.game.ui.UIBase")
local Constants = require("app.gameMode.mahjong.core.Constants")
local UICardsInfo= class("UICardsInfo", super, function() return kod.LoadCSBNode(csbPath) end)
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

-- 主要牌起始位置
local MAIN_START_X = 120;

-- 特殊牌位置
local SUB_CARD_Y = 137;
local SUB_END_X = 855;
local SUB_START_X = 250;

-- 有特殊牌时间距和牌倍率
-- 有特殊牌时主要牌下移距离
local MUTI_SPACE_Y = 16;
local MUTI_SCALE = 0.9;
local MUTI_SUB_SCALE = 0.7;
-- 杠牌第四张的空隙 */
local GANG_SPACE = 15;
-- 特殊牌位置
local SPECIAL_POS = {x = 858, y = - 12};
-- 麻将牌大小
local CARD_SIZE = {width = 42, height = 62};

-- 卡牌有效宽度与资源总宽度的比值
local CARD_REAL_WIDTH_ESCAPE = 0.88
local CARD_REAL_WIDTH_HAND = 0.88
local CARD_REAL_WIDTH_GROUP = 0.88
local CARD_REAL_WIDTH_GROUP_BUGANG = 0.98
local CARD_REAL_WIDTH_GROUP_ANGANG = 0.78

function UICardsInfo:ctor()
    self._cardsUI = {}
    self._btnClose = nil
    self._gui = {}
    self._guiSet = {}
    self._zheng = {}
    self._uiPlayers = {}
    self._showCards = {};
end

function UICardsInfo:init()
    self._btnClose = seekNodeByName(self, "Button_x_CardInfo", "ccui.Button")

	--玩家列表
	self._playerListView = seekNodeByName(self, "ListView_Player", "ccui.ListView");
    --玩家项
    self._playerNode = ccui.Helper:seekNodeByName(self._playerListView, "Panel_player_CardsInfo")
	self._playerNode:removeFromParent(false)
	self:addChild(self._playerNode)
	self._playerNode:setVisible(false)

	--余牌项
    self._remainCardNode = ccui.Helper:seekNodeByName(self._playerListView, "Panel_remain_CardsInfo")
	self._remainCardNode:removeFromParent(false)
	self:addChild(self._remainCardNode)
	self._remainCardNode:setVisible(false)
    
    self:_bindCallback()
end

function UICardsInfo:_bindCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onCloseButton), ccui.TouchEventType.ended)
end

function UICardsInfo:onShow(...)
    local args = { ... }

    local playersInfo = args[2]
    local playersData = args[1]
    self._playerListView:removeAllChildren()
    --根据玩家数量插入指定数量的playerUI
	if #playersData > 0 then
		for i, data in ipairs(playersData) do
            local node = self._playerNode:clone()
            node:setVisible(true)
            self._playerListView:insertCustomItem(node,i-1)

            local face = seekNodeByName(node, "Image_face_CardsInfo", "ccui.ImageView")
            local name = seekNodeByName(node, "Text_name_CardsInfo", "ccui.Text")
            game.util.PlayerHeadIconUtil.setIcon(face, playersInfo[i].iconUrl)
            name:setString(kod.util.String.getMaxLenString(playersInfo[i].roleName, 8))

            self:_setMajiangData(face, playersData[i])
		end
	end

    self:_setRemainData(args[3])
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UICardsInfo:isFullScreen()
	return true;
end

function UICardsInfo:needBlackMask()
	return true;
end

function UICardsInfo:closeWhenClickMask()
	return false
end

function UICardsInfo:destroy()
	-- 当前界面销毁的时候，判断当前界面是否还有残留的卡牌
	if Macro.assertTrue(#self._showCards > 0, "UICardsInfo Cards not release!") then
		for k,v in pairs(self._showCards) do
			CardFactory:getInstance():releaseCard(v);
		end
		self._showCards = {};
	end
end

function UICardsInfo:_onCloseButton()
    for k,v in pairs(self._showCards) do
        CardFactory:getInstance():releaseCard(v);
    end
    self._showCards = {};

    UIManager:getInstance():destroy("UICardsInfo")
end

function UICardsInfo:_setUIPlayerInfo(idx, playerInfo)
    local uiPlayer = self._uiPlayers[idx]
    game.util.PlayerHeadIconUtil.setIcon(uiPlayer.face, playerInfo.iconUrl)
    uiPlayer.name:setString(kod.util.String.getMaxLenString(playerInfo.roleName, 8))
    uiPlayer.face:getParent():setVisible(true)
end

--设置牌局余牌
function UICardsInfo:_setRemainData(remainData)
    --没有余牌(黄庄)，不显示余排区域
    
    if #remainData == 0 then
        return;
    end

    local node = self._remainCardNode:clone()
    node:setVisible(true)
    self._playerListView:addChild(node)

    local colNum = 29
    --根据行数动态设置背景层大小
    node:setContentSize(cc.size(node:getContentSize().width
        , node:getContentSize().height * math.ceil(#remainData / colNum) + 20))

    local yupaiY = node:getContentSize().height - 28
    local yupaiX = MAIN_START_X - 88
    local tempYupaiX = yupaiX
    local floor = 0;

    for i, cardValue in ipairs(remainData) do
        local cardInfo = self:_addOneCard(node, cardValue, yupaiX, yupaiY, -i)
        cardInfo:setScale(0.7)
        cardInfo:setPositionX(yupaiX);
        cardInfo:setPositionY(yupaiY -  (cardInfo:getContentSize().height * 0.5 + 12) * floor )
        yupaiX = yupaiX + cardInfo:getContentSize().width * cardInfo:getScale()

        if i % colNum == 0 then
            floor = floor + 1;
            yupaiX = tempYupaiX;
        end
    end
end

function UICardsInfo:_setMajiangData(face, playerData)
    --[[ test
    if idx ~= 1 then return end
    --]]
    local root = face
    root:getParent():setVisible(true)
    local facePosY = root:getPositionY()
    local nowX = MAIN_START_X
    local nowY = -2
    local huX = SUB_END_X
    local huY = nowY
    local huaX = SUB_END_X
    local huaY = nowY
    local qipaiX = MAIN_START_X - 5
    local qipaiY = root:getContentSize().height - 18
    local mainScale = 1
    local subScale = 1
	--马牌和花牌
	local specialCardMap = {};
	local specialPosX = SPECIAL_POS.x;
	local historyRecordService = game.service.HistoryRecordService:getInstance()
	-- 对显示顺序排序
	-- table.sort(playerData.operateCards, function(l, r) return historyRecordService:playTypeToSortValue(l.playType) < historyRecordService:playTypeToSortValue(r.playType) end)
	table.bubbleSort(playerData.operateCards, function(l, r) return historyRecordService:playTypeToSortValue(l.playType) <= historyRecordService:playTypeToSortValue(r.playType) end)
	
	local huPai = {}
	local hua = {}
	
	--弃牌
	local tempQipaiX = qipaiX
	local floor = 0;
	for i, cardValue in ipairs(playerData.outCards) do
		local cardInfo = self:_addOneCard(root, cardValue, qipaiX, qipaiY)
		cardInfo:setScale(0.7)
		cardInfo:setPositionX(qipaiX);
		cardInfo:setPositionY(qipaiY - cardInfo:getContentSize().height * cardInfo:getScale() * 0.4 * floor)
		qipaiX = qipaiX + cardInfo:getContentSize().width * cardInfo:getScale()
		
		if i % 25 == 0 then
			floor = floor + 1;
			qipaiX = tempQipaiX;
		end
	end
	
	-- 鬼牌
	local guisData = {}
	for _, n in ipairs(playerData.operateCards) do
		if Constants.PlayType.Check(n.playType, Constants.PlayType.DISPLAY_SHOW_MASTER_CARD) then
			table.insert(guisData, n)
		end
	end
	
	if #guisData > 0 then
		for i = 1, #guisData do
			for j = 1, #guisData[i].cards do
				table.insert(self._gui, guisData[i].cards[j])
				self._guiSet[guisData[i].cards[j]] = true
			end
		end
	end
	
	-- 正牌
	local zhengsData = {}
	for _, n in ipairs(playerData.operateCards) do
		if Constants.PlayType.Check(n.playType, Constants.PlayType.DISPLAY_ZHENG_CARD) then
			table.insert(zhengsData, n)
		end
	end
	
	if #zhengsData > 0 then
		for i = 1, #zhengsData do
			for j = 1, #zhengsData[i].cards do
				table.insert(self._zheng, zhengsData[i].cards[j])
			end
		end
	end
	
	-- 胡牌单独提出来(胡牌大于1时改变显示格局)
	local husData = {}
	for _, n in ipairs(playerData.operateCards) do
		if Constants.PlayType.Check(n.playType, Constants.PlayType.OPERATE_HU) or Constants.PlayType.Check(n.playType, Constants.PlayType.OPERATE_MEN) then
			table.insert(husData, n)
		end
	end
	
	if #husData > 0 then
		for i = 1, #husData do
			for j = 1, #husData[i].cards do
				table.insert(huPai, husData[i].cards[j])
			end
		end
	end
	
	-- 花牌单独提出来(有花牌时改变显示格局)
	local huasData = {}
	for _, n in ipairs(playerData.operateCards) do
		if Constants.PlayType.Check(n.playType, Constants.PlayType.DISPLAY_EX_CARD) or Constants.PlayType.Check(n.playType, Constants.PlayType.DISPLAY_HONG_ZHONG) then
			table.insert(huasData, n)
		end
	end
	
	if #huasData > 0 then
		for i = 1, #huasData do
			for j = 1, #huasData[i].cards do
				table.insert(hua, huasData[i].cards[j])
			end
		end
	end
	
	-- 显示吃碰杠
	for _, operateCard in ipairs(playerData.operateCards) do
		if operateCard.playType == Constants.PlayType.OPERATE_AN_GANG then
			for i = 1, 3 do
				local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY, 0, CardDefines.CardState.GangPai2)
				nowX = nowX + CARD_SIZE.width * cardInfo:getScale()
			end
			
			local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY + GANG_SPACE * mainScale, 10)
			cardInfo:setPositionX(cardInfo:getPositionX() - 2 * CARD_SIZE.width * cardInfo:getScale())
			nowX = nowX + 12
		elseif operateCard.playType == Constants.PlayType.OPERATE_GANG_A_CARD then
			for i = 1, 3 do
				local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY)
				nowX = nowX + CARD_SIZE.width * cardInfo:getScale()
			end
			
			local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY + GANG_SPACE * mainScale, 10);
			cardInfo:setPositionX(cardInfo:getPositionX() - 2 * CARD_SIZE.width * cardInfo:getScale())
			nowX = nowX + 12
		elseif operateCard.playType == Constants.PlayType.OPERATE_BU_GANG_A_CARD then
			for i = 1, 3 do
				local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY)
				nowX = nowX + CARD_SIZE.width * cardInfo:getScale()
			end
			
			local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY + GANG_SPACE * mainScale, 10)
			cardInfo:setPositionX(cardInfo:getPositionX() - 2 * CARD_SIZE.width * cardInfo:getScale())
			nowX = nowX + 12;
		elseif operateCard.playType == Constants.PlayType.OPERATE_PENG_A_CARD then
			for i = 1, 3 do
				local cardInfo = self:_addOneCard(root, operateCard.cards[1], nowX, nowY)
				nowX = nowX + CARD_SIZE.width * cardInfo:getScale()
			end
			
			nowX = nowX + 12
		elseif operateCard.playType == Constants.PlayType.OPERATE_CHI_A_CARD then
			for _, cardValue in ipairs(operateCard.cards) do
				local cardInfo = self._addOneCard(root, cardValue, nowX, nowY)
				nowX = nowX + CARD_SIZE.width * cardInfo:getScale()
			end
			
			nowX = nowX + 12
		else
			--马牌和花牌
			if specialCardMap[operateCard.playType] == nil then
				specialCardMap[operateCard.playType] = operateCard.cards
			end
		end
	end
	
	-- 显示手牌
	table.sort(playerData.handCards, function(a, b)
		local aIsGui = self._guiSet[a] and 1 or 0
		local bIsGui = self._guiSet[b] and 1 or 0
		if aIsGui == 1 or bIsGui == 1 then
			return bIsGui < aIsGui
		end
		
		return a < b
	end)
	
	for _, cardValue in ipairs(playerData.handCards) do
		local cornerTypes = {}
		if self._guiSet[cardValue] then
			table.insert(cornerTypes, CardDefines.CornerType.GuiPai)
		end
		local cardInfo = self:_addOneCard(root, cardValue, nowX, nowY, nil, nil, cornerTypes)
		nowX = nowX + CARD_SIZE.width * cardInfo:getScale()
	end
	
	nowX = nowX + 12
	
	-- 如果胡牌大于1则用特殊方式显示胡牌
	if #huPai == 1 then
		local cornerTypes = {}
		if self._guiSet[huPai[1]] then
			table.insert(cornerTypes, CardDefines.CornerType.GuiPai)
		end
		self:_addOneCard(root, huPai[1], nowX, nowY, nil, nil, cornerTypes)
	elseif #huPai > 1 then
		for _, cardValue in ipairs(huPai) do
			local cardInfo = self:_addOneCard(root, cardValue, huX, huY)
			huX = huX - CARD_SIZE.width * cardInfo:getScale()
		end
	end
	
	-- 如果有花牌则用特殊方式显示花牌
	if #hua > 0 then
		for _, cardValue in ipairs(hua) do
			local cardInfo = self:_addOneCard(root, cardValue, huaX, huaY)
			huaX = huaX + CARD_SIZE.width * cardInfo:getScale()
		end
	end
	--特殊牌的摆放位置（花牌、奖马、买马）
	table.foreach(specialCardMap, function(key, value)
		if key == Constants.PlayType.DISPLAY_DEAL_BETTING_HORSE then
			-- 取得高亮牌
			local highlight = specialCardMap[Constants.PlayType.DISPLAY_BETTING_HORSE];
			for i, cardValue in ipairs(specialCardMap[key]) do
				local state = table.indexof(highlight, cardValue) ~= false and CardDefines.CardState.Ma_Win or CardDefines.CardState.Chupai;
				local cardInfo = self:_addOneCard(root, cardValue, specialPosX, SPECIAL_POS.y, 0, state);
				cardInfo:setScale(0.5)
				specialPosX = specialPosX -(CARD_SIZE.width +(state ~= CardDefines.CardState.Chupai and 4 or 0)) * cardInfo:getScale();
			end
		elseif key == Constants.PlayType.DISPLAY_HORSE_CARD then
			-- 取得赢的牌
			local win = specialCardMap[Constants.PlayType.DISPLAY_WIN_HORSE_CARD];
			-- 取得输的牌
			local lose = specialCardMap[Constants.PlayType.DISPLAY_LOSE_HORSE_CARD];
			for i, cardValue in ipairs(specialCardMap[key]) do
				local state = table.indexof(lose, cardValue) ~= false and CardDefines.CardState.Ma_Lose or CardDefines.CardState.Chupai
				state = table.indexof(win, cardValue) ~= false and CardDefines.CardState.Ma_Win or state
				local cardInfo = self:_addOneCard(root, cardValue, specialPosX, SPECIAL_POS.y, 0, state);
				cardInfo:setScale(0.5)
				cardInfo:setPositionY(SPECIAL_POS.y + CARD_SIZE.height * cardInfo:getScale())
				specialPosX = specialPosX -(CARD_SIZE.width +(state ~= CardDefines.CardState.Chupai and 4 or 0)) * cardInfo:getScale();
			end
		elseif key == Constants.PlayType.DISPLAY_EX_CARD then
			-- 直接生成牌
			for i, cardValue in ipairs(specialCardMap[key]) do
				local cardInfo = self:_addOneCard(root, cardNumber, SPECIAL_POS.x, SPECIAL_POS.y);
				cardInfo:setScale(0.5)
				cardInfo:setPositionY(SPECIAL_POS.y + CARD_SIZE.height * cardInfo:getScale() * 2)
				specialPosX = specialPosX -(CARD_SIZE.width +(state ~= CardDefines.CardState.Chupai and 4 or 0)) * cardInfo:getScale();
			end
		end
		specialPosX = SPECIAL_POS.x;
	end)
end

function UICardsInfo:_addOneCard(box, cardValue, x, y, zOrder, playtype, cornerTypes)
	if type(cardValue) ~= "number" then
		return
	end
	
	zOrder = zOrder or 0
	
	local cardInfo = CardFactory:getInstance():CreateCard({chair = CardDefines.Chair.Down, state = playtype or CardDefines.CardState.Chupai, cardValue = cardValue, cornerTypes = cornerTypes, fromRull = true});
	table.insert(self._showCards, cardInfo);
	box:addChild(cardInfo, zOrder)
	cardInfo:setPositionX(x);
	cardInfo:setPositionY(y - 13);
	cardInfo:setScale(0.9)
	
	return cardInfo;
end

return UICardsInfo