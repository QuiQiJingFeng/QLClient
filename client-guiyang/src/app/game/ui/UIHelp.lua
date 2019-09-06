local csbPath = "ui/csb/UIHelp.csb"
local super = require("app.game.ui.UIBase")

local GAME_TYPE_SETTING = config.GlobalConfig.getRoomSetting().GAME_TYPE_SETTING
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local UIHelp = class("UIHelp", super, function () return kod.LoadCSBNode(csbPath) end)
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")
local room = require( "app.game.ui.RoomSettingHelper" )

local TabTypes = { TAB_GUIYANG = 1, TAB_ZUNYI = 2, TAB_ANSHUN = 3 }

--帮助页面的所有玩法标签
function UIHelp:ctor()
	--牌的其实位置
	self._cardStartX = 30;
	--牌间距
	self._cardSpace = 30;
	--堆叠牌的垂直距离
	self._cardStackSpace = 12;
	--文字行间距
	self._textSpace = 6;
	-- 不同标签之间默认距离
	self._titleSpace = 20;
	--大标题文字字号
	self._titleFontSize = 36;
	--子标题文字字号
	self._subtitleFontSize = 30;
	--其他文字字号
	self._otherFontSize = 24;
	--牌型所占高度
	self._cardsBoxHeight = 74;
	--当前Y坐标
	self._currentPosY = 0;
	--JSON配置文件
	self.CONFIG = {};
	--缓存生成的麻将牌
	self._showCards = {};
	self._gameTagOnBtns = {};
	self._gameTagOffBtns = {};
	self._btnClose = nil;
	self._scrollHelp = nil;
	self._infoPanel = nil;
	self._curTab = nil
	self._btnCheckList = {};

	self.modelNode = seekNodeByName(self, "Panel_TYPE_BUTTON", "ccui.Layout")
    self.modelNode:setVisible(false)
    self.modelNode:removeFromParent(false)
end

function UIHelp:init()
	self._btnClose = seekNodeByName(self,"ButtonClose","ccui.Button")
	self._scrollHelp = seekNodeByName(self,"ScrollView_Help","ccui.ScrollView")
	self._btnList = seekNodeByName(self, "ListView_Game_Type_Btn", "ccui.ListView")
	self._btnList:removeAllChildren()

	self._scrollHelp:setScrollBarEnabled(false);
	self:initGameTypeUI();

	self:addCallBack()
end

function UIHelp:addCallBack()
	bindEventCallBack(self._btnClose, handler(self, self.onBtnCloseClick),ccui.TouchEventType.ended);
end

-- TODO:现在只有主动调用的销毁，没有被动关闭的销毁，处理一下
function UIHelp:destroy()
	self:_stopSetHelpContentTask()
	for k,v in pairs(self._showCards) do
		CardFactory:getInstance():releaseCard(v);
	end
	self._showCards = {};
end

function UIHelp:onBtnCloseClick(sender)
	self:close();
end

--[[
    @desc: 这个方法改成第一个参数还是现有玩法的type，但是第二个是配置，可以提取不同的配置
    author:{马驰骋}
    time:2017-09-13 16:55:51
    return keys=原来的gameTypes数组，gameTypes=配置
]]
function UIHelp:getGameTypes()
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local keys = MultiArea.getGameTypeKeys(areaId)
    local gameTypes = MultiArea.getGameTypeMap(areaId)
    return keys, gameTypes
end

function UIHelp:initGameTypeUI()
	local gameTypes, gameTypesConfig = self:getGameTypes()
	for k, gameType in pairs(gameTypes) do
		local config = gameTypesConfig[gameType]
		local node = nil
		node = self.modelNode:clone()
		node:setName("GAME_TYPE_BUTTON_cloned")
		node:setVisible(true)
		local isSelected = false
		local checkBox = seekNodeByName(node, "GAME_TYPE_BUTTON", "ccui.CheckBox")
		checkBox:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
				isSelected = checkBox:isSelected()
			elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then	
				self:onGameTypeClicked(gameType)
				checkBox:setSelected(true)
          	elseif eventType == ccui.TouchEventType.canceled then
			  	checkBox:setSelected(isSelected)
            end
        end)
		self._btnCheckList[gameType] = checkBox
		self._btnList:addChild(node)

		local gameTypeTxt = seekNodeByName(node, "GAME_TYPE_BUTTON_TXT", "ccui.TextBMFont")
		gameTypeTxt:setString(config.name)		
	end
end

function UIHelp:onShow(...)
	local args = {...}
	local default = args[1]
	local t = cc.FileUtils:getInstance():getStringFromFile(self:getHelpPath())
	self.CONFIG = loadstring(t)()

	--默认选中第一个玩法
	local gameTypes, gameTypesConfig = self:getGameTypes()
	self:onGameTypeClicked(default or gameTypes[1])
	self._btnCheckList[default or gameTypes[1]]:setSelected(true)
end

-- 多地区获取帮助文档路径,防止帮助文档过长，而且可能存在不同地区同一玩法不同规则说明的情况 分成不同的文件
function UIHelp:getHelpPath()
	local path = ""
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
	table.foreach(config.GlobalConfig.AREAS, function(key, val)
		if val.id == areaId then
			path = val.helpPath
		end
	end)
	return path
end

--生成文字并加入容器,文本属性已经设定好 */
function UIHelp:createLabel(text, color, fontSize)
	local Label = ccui.Text:create();
	Label:setString(text);
	Label:ignoreContentAdaptWithSize(true);
	Label:setTextAreaSize(cc.size(790,0))
	Label:setTextColor(color);
	Label:setFontSize(fontSize);
	Label:setAnchorPoint(cc.p(0,1));
	--local _size = Label:getVirtualRendererSize()
	local _size = Label:getAutoRenderSize()
	local __size = self._scrollHelp:getContentSize();
	local offset = 20 
	Label:setContentSize(cc.size(__size.width, _size.height + offset));
	self._infoPanel:addChild(Label);
	Label:setPositionY(self._currentPosY);
	self._currentPosY = self._currentPosY - _size.height - offset;
    --Label:fitToScreen()
end

--添加一张麻将到对应box中 */

function UIHelp:addOneCard(box, cardValue, X)
	local cardInfo = CardFactory:getInstance():CreateCard({ chair = CardDefines.Chair.Down, state = CardDefines.CardState.Chupai, cardValue = cardValue, fromRull = true });
	table.insert(self._showCards,cardInfo);
	box:addChild(cardInfo);
	cardInfo:setPositionX(X);
	cardInfo:setPositionY(0);
	return cardInfo;
end

--生成一个box用来盛放牌,来代替图片,所以完全按照图片尺寸来设定的固定值 */
function UIHelp:createCards(cards)
	local box = ccui.Layout:create();
	box:setPositionY(self._currentPosY);
	self._infoPanel:addChild(box);
	--self._scrollHelp:addChild(box);
	self._currentPosY = self._currentPosY - self._cardsBoxHeight;
	local hasGang = false;
	local posX = self._cardStartX;

	local spaceNum = 0
	local spaceLength = 0;
	
	for _,v in ipairs(cards) do
		if v == 0 then
			--0 代表空格我们先计算空格的总数
			spaceNum = spaceNum + 1 ;
		end
	end

	--均分空隙
	spaceLength = self._cardSpace / spaceNum;

	--读取json中的cards属性并创建麻将牌
	for i = 1, #cards do
		local card = cards[i];
		--如果card属性是一个数组则生成一个堆叠的牌来显示杠的效果,对于有杠的牌型额外进行小位置调整
		if "table" == type(card) then
			if "number" ~= type(card[1]) then
				Logger.error("玩法json的card项存在无效属性")
				return;
			end
			hasGang = true;
			local cardInfo = self:addOneCard(box, card[1], posX);
			local _card = self:addOneCard(box, card[1], posX)
			_card:setPositionY(_card:getPositionY() + self._cardStackSpace);
			posX = posX + cardInfo:getContentSize().width;
		else
			if "number" ~= type(card) then
				Logger.error("玩法json的card项存在无效属性")
				return;
			end
			if card == 0 then
				--添加空隙
				posX = posX + spaceLength;
			else
				local width = self:addOneCard(box, card, posX):getContentSize().width;
				posX = posX + width
			end
		end
	end
	
	box:setPositionY(box:getPositionY() - self._cardsBoxHeight / 2);
	
	if hasGang then
		box:setPositionY(box:getPositionY() - self._cardStackSpace / 2);
	end
end

function UIHelp:onGameTypeClicked(gameType)
	-- --按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
		v:setSelected(false)
	end
	--加载对应玩法
	self._infoPanel = ccui.Layout:create();
	self._infoPanel:setAnchorPoint(cc.p(0, 1))
	self._infoPanel:setContentSize(cc.p(self._scrollHelp:getContentSize().width,0));
	
	self:setHelpForTheSelectGameType(gameType);
end

--从JSON中读取玩法配置，加入到对应滚动列表中 */
function UIHelp:setHelpForTheSelectGameType(gameType)
	--初始化panel属性
	self._scrollHelp:removeAllChildren(true);
	self._currentPosY = 0;
	for k,v in pairs(self._showCards) do
		CardFactory:getInstance():releaseCard(v);
	end
	self._showCards = {};
	if nil == self.CONFIG[gameType] then
		Logger.error("玩法配置错误请检查");
		return;
	end

	self:_stopSetHelpContentTask()
	self._configSetHelpContent = self.CONFIG[gameType]
	self._stepSetHelpContent = 0
	self._setHelpContentTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._setHelpContentStep), 0, false)
	local contentSize = self._scrollHelp:getContentSize()
	self._infoPanel:setPosition(0, contentSize.height)
	self._scrollHelp:setInnerContainerSize(contentSize)
	self._scrollHelp:addChild(self._infoPanel)
	self._scrollHelp:stopAutoScroll()
	self._scrollHelp:getInnerContainer():setPositionY(0)
end

function UIHelp:_stopSetHelpContentTask()
	if self._setHelpContentTask then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._setHelpContentTask)
		self._setHelpContentTask = nil
	end
end

function UIHelp:_setHelpContentStep()
	self._stepSetHelpContent = self._stepSetHelpContent + 1
	if self._stepSetHelpContent > #(self._configSetHelpContent) then
		self:_stopSetHelpContentTask()
		return
	end
	local space = self._titleSpace
	local config = self._configSetHelpContent[self._stepSetHelpContent]

    --读取颜色值
	local CList = GainLabelColorUtil.new(self , 3) 

	for element, value in pairs(config) do
		if     "title"    == element then
			self:createLabel(value, cc.c4b(CList.colors[1].r,CList.colors[1].g,CList.colors[1].b,255), self._titleFontSize)
		elseif "subTitle" == element then
			self:createLabel(value, cc.c4b(CList.colors[2].r,CList.colors[2].g,CList.colors[2].b,255), self._subtitleFontSize)
		elseif "content"  == element then
			self:createLabel(value, cc.c4b(CList.colors[2].r,CList.colors[2].g,CList.colors[2].b,255), self._otherFontSize)
		elseif "cards"    == element then
			self:createCards(value)
		elseif "space"    == element then
			space = value
		else
			Logger.error("玩法配置有问题请检查")
		end
	end
	self._currentPosY = self._currentPosY - space
	local contentSize = self._scrollHelp:getContentSize()
	if -self._currentPosY > contentSize.height then
		self._infoPanel:setPositionY(-self._currentPosY)
		self._scrollHelp:setInnerContainerSize(cc.size(self._scrollHelp:getContentSize().width, -self._currentPosY))
	end
end

function UIHelp:close()
	self:_stopSetHelpContentTask()
	for k,v in pairs(self._showCards) do
		CardFactory:getInstance():releaseCard(v);
	end
	self._showCards = {};
	UIManager:getInstance():destroy("UIHelp");
end

function UIHelp:needBlackMask()
	return true;
end

function UIHelp:closeWhenClickMask()
	return false
end

return UIHelp;
