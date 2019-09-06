local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local super = require("app.gameMode.mahjong.ObjBase")
local Card = class("Card", super, function() return cc.Node:create() end)

local cardIdGenerator = 0
local function generateId()
	cardIdGenerator = cardIdGenerator + 1
	return cardIdGenerator;
end

local cornerConfig = {
	[CardDefines.CornerType.GuiPai] = "art/mahjong_card/icon_lanz.png",
	[CardDefines.CornerType.ZhengPai] = "art/mahjong_card/icon_zheng.png",
	[CardDefines.CornerType.RemaingCards] = "art/mahjong_card/icon_ts2.png",
}

function Card:ctor()
	super.ctor(self)
	self._id = generateId()
	self._cardIndex = 1
	self._cardValue = - 1;
	self._cardName = nil;
	self._chairTypeType = CardDefines.Chair.Invalid;
	self._cardState = CardDefines.CardState.Invalid;
	self._backGroundType = CardDefines.BackGroundType.Invalid;
	self._disabled = false;
	-- 是否忽视点击
	self._ignoreClick = false;
	self._isGuiPai = false;
	self._card = nil;
	--牌面,万条筒等
	self.surface = nil;
	--遮罩,蒙灰
	self._darkMask = nil;
	--牌的所有角标
	self._cornerMasks = {};
	-- 是否可以点击
	self.mouseEnabled = true
	-- 拍背
	self._realBtn = nil
	self._bg = nil
	-- 牌面
	self._face = nil
	-- 项点颜色
	self._color = nil
	-- 吃碰扛的提示信息
	self._tips = nil
	self:retain()
	
	self._csb = nil
	self._img = nil
	self._texture = nil
	-- game.service.LocalPlayerSettingService.getInstance():addEventListener("CARD_BACKGROUND_CHANGED", 
	-- 	handler(self, self._onChangeBackground), self)
	-- game.service.LocalPlayerSettingService.getInstance():addEventListener("EFFECT_PENGGANGTISHI_CHANGED", 
	-- 	handler(self, self._onPengGangTiShiChanged), self)
end

function Card:getId()
	return self._id;
end

function Card:getCardValue()
	return self._cardValue;
end

--调试用
function Card:getCardName()
	return GetCardName(self._cardValue);
end

--显示用。属于哪一列(上下左右4个玩家)
function Card:getChairType()
	return self._chairTypeType;
end

function Card:getCardState()
	return self._cardState;
end

function Card:getBackGroundType()
	return self._backGroundType;
end

function Card:getIsGuiPai()
	return self._isGuiPai;
end

function Card:getBg()
	return self._face
end

function Card:_imageLoadTexture(image, frame)
	--[[针对最近出现的牌桌上可能多个幺鸡的问题，猜测是因为cocos本身因为内存报警而清空了无用的frame,以下为C++中director处理函数
	void Director::purgeCachedData(void)
	{
		FontFNT::purgeCachedData();
		FontAtlasCache::purgeCachedData();

		if (s_SharedDirector->getOpenGLView())
		{
			SpriteFrameCache::getInstance()->removeUnusedSpriteFrames();
			_textureCache->removeUnusedTextures();

			// Note: some tests such as ActionsTest are leaking refcounted textures
			// There should be no test textures left in the cache
			log("%s\n", _textureCache->getCachedTextureInfo().c_str());
		}
		FileUtils::getInstance()->purgeCachedEntries();
	}
	]]
	--如果该frame已经被清空,则报告错误，并重新加载plist
	if not cc.SpriteFrameCache:getInstance():getSpriteFrame(frame) then
		local data = {
			frame = frame,
			card = self._cardValue
		}
		-- dispatchGlobalEvent("MAHJONG_REPORT_ERROR", data)
		Macro.assertTrue(true, "missing card frame:" .. frame)
		
		--这儿是否可以单独加载本局牌对应的plist?
		CardFactory:getInstance():_loadAtlasFile()
	end
	image:loadTexture(frame, ccui.TextureResType.plistType)
end

function Card:_buttonLoadTextures(button, frame1, frame2, frame3)
	--作用同上个函数
	if not cc.SpriteFrameCache:getInstance():getSpriteFrame(frame1)
	or not cc.SpriteFrameCache:getInstance():getSpriteFrame(frame2)
	or not cc.SpriteFrameCache:getInstance():getSpriteFrame(frame3) then
		local data = {
			frame1 = frame1,
			frame2 = frame2,
			frame3 = frame3,
			card = self._cardValue
		}
		-- dispatchGlobalEvent("MAHJONG_REPORT_ERROR", data)
		Macro.assertTrue(true, "missing button Textures:" .. frame1)
		
		--这儿是否可以单独加载本局牌对应的plist?
		CardFactory:getInstance():_loadAtlasFile()
	end
	button:loadTextures(frame1, frame2, frame3, ccui.TextureResType.plistType)
end

-- 索引检测防止错误的索引导致创建不存在的csb使游戏崩溃
function Card:check3dCsbIllegal(csb, index)
	if not config.getIs3D() then
		return false
	end
	
	local flag = false
	if string.find(csb, "HP") or string.find(csb, "GP") then
		if index < 1 or index > 14 then
			flag = true
		end
	end
	
	if string.find(csb, "QP") then
		if index < - 2 or index > 13 then
			flag = true
		end
	end
	
	return flag
end
-- 设置牌显示信息
function Card:reset(cardValue, chairType, cardState, backgroundType, cornerTypes, csb, img, bg, style, conerTxt, cardIndex)
	
	self._cardIndex = cardIndex or 1
	self._cardValue = cardValue;
	self._cardName = ""--GetCardName(cardValue);
	self._chairTypeType = chairType;
	self._cardState = cardState;
	self._backGroundType = backgroundType;
	self._disabled = false;
	self._csb = csb
	self._style = style
	self:setVisible(true)
	
	local errorLog = string.format("error create3Dcard for csb:%s,index:%s", tostring(self._csb) or "nil", tostring(self._cardIndex) or "nil")
	--if Macro.assetTrue(self:check3dCsbIllegal(self._csb, self._cardIndex), errorLog) then
	if self:check3dCsbIllegal(self._csb, self._cardIndex) then 
		self._cardIndex = 1
	end
	csb = string.format(csb, style.csb, self._cardIndex)
	
	Logger.info("createNewCard csb======>" .. csb)
	if self._card and self._card:getParent() then
		self:cleanTexture()
		self._card:removeFromParent()
	end
	
	
	self._card = cc.CSLoader:createNode(csb);
	self:addChild(self._card);
	self:setSkewX(0);
	self._realBtn = seekNodeByName(self._card, "Button_BG", "ccui.Button")	
	self._face = seekNodeByName(self._card, "Image_Title", "ccui.ImageView")
	self._realBtn:setTouchEnabled(false)
	self._darkMask = seekNodeByName(self._card, "Image_Gray", "ccui.ImageView")
	if self._darkMask then
		self._darkMask:setVisible(false)
	end
	self:enableTouch()
	
	self._img = nil
	if nil ~= self._face and nil ~= img then
		self._img = img
		img = string.format(img, style.atlas)
		-- print("loadTexture~~~~~~~~~~..",img,csb)
		-- self._face:loadTexture(img, ccui.TextureResType.plistType);
		self:_imageLoadTexture(self._face, img)
		self._texture = img -- 记录一下face的texture
		CardFactory:getInstance():addTexture(self._texture)
	end
	self._bg = nil
	if nil ~= self._realBtn and nil ~= bg and style.csb ~= "3d_new" then
		self._bg = bg
		bg = string.format(bg, style.atlas, style.bg)
		-- self._realBtn:loadTextures(bg, bg, bg, ccui.TextureResType.plistType)
		self:_buttonLoadTextures(self._realBtn, bg, bg, bg)
	end
	self:setContentSize(self._realBtn:getContentSize())
	
	self:setCornerMasks(cornerTypes, chairType, conerTxt)
end

-- 3D麻将手牌排序后重新设置CSB
function Card:resetCardCsbFor3DIndex(index)
	local isCsbNeedChange = string.find(self._csb, "%%d")
	if self._cardIndex ~= index and isCsbNeedChange then
		self:setStyle(self._style, self._csb, self._img, self._bg, index)
	end
end

-- 对某张牌换风格
-- 本来是用来换牌面的，但是由于可能有些牌上有动画，有状态
-- 这些可能是无法复制，或者继承的
-- 所以这个方法暂时废弃
-- 但是对于一些需要换牌的某个状态(csb,img)等需求，可能会有奇效，所以留着
function Card:setStyle(style, csb, img, bg, index)
	self._cardIndex = index or 1
	-- 删除之前的
	self:cleanTexture()
	self._card:removeFromParent(true);
	self._card = nil;
	
	local errorLog = string.format("error create3Dcard for csb:%s,index:%s", csb, self._cardIndex)
	--if Macro.assetTrue(self:check3dCsbIllegal(csb, self._cardIndex), errorLog) then
	if self:check3dCsbIllegal(csb, self._cardIndex) then 
		self._cardIndex = 1
	end
	
	csb = csb and csb or self._csb
	csb = string.format(csb, style.csb, self._cardIndex)
	Logger.info("createNewCard csb======>" .. csb)
	self._card = cc.CSLoader:createNode(csb);
	self:addChild(self._card);
	
	self._card:setLocalZOrder(- 1)
	self._realBtn = seekNodeByName(self._card, "Button_BG", "ccui.Button")	
	self._face = seekNodeByName(self._card, "Image_Title", "ccui.ImageView")
	self._realBtn:setTouchEnabled(false)
	self._darkMask = seekNodeByName(self._card, "Image_Gray", "ccui.ImageView")
	if self._darkMask then
		self._darkMask:setVisible(false)
	end
	
	img = img and img or self._img
	if nil ~= self._face and nil ~= img then
		img = string.format(img, style.atlas)
		-- self._face:loadTexture(img, ccui.TextureResType.plistType);
		self:_imageLoadTexture(self._face, img)
		self:cleanTexture()
		self._texture = img -- 记录一下face的texture
		CardFactory:getInstance():addTexture(self._texture)
	end
	bg = bg and bg or self._bg
	if nil ~= self._realBtn and nil ~= bg and style.csb ~= "3d_new" then
		self._bg = bg
		bg = string.format(bg, style.atlas, style.bg)
		-- self._realBtn:loadTextures(bg, bg, bg, ccui.TextureResType.plistType)
		self:_buttonLoadTextures(self._realBtn, bg, bg, bg)
	end
	
	self:setContentSize(self._realBtn:getContentSize())
	
	self:changeColor(self._color, true)
	-- todo: 理论上还要恢复置灰、点击等状态，暂时先不弄了
end

-- function Card:_calcBoundingBox()
-- 	local bb = self._realBtn:getBoundingBox()
-- 	local pt = self._card:convertToWorldSpace(cc.p(bb.x, bb.y)) -- _card is _realBtn's parent
-- 	bb.x, bb.y = pt.x, pt.y
-- 	self._boundingBox = bb		
-- end
--不可操作
function Card:disable(force)
	self._disabled = true;
	if self._darkMask then
		self._darkMask:setVisible(true)
	end
	self._realBtn:setTouchEnabled(false)
	--self.darkMask.visible = true;
end

--可操作
function Card:enable(force)
	self._disabled = false;
	if self._darkMask then
		self._darkMask:setVisible(false)
	end
	if force then
		self._realBtn:setTouchEnabled(force)
	end
	--self.darkMask.visible = false;
end

function Card:enableTouch()
	self._realBtn:setTouchEnabled(false)
	self._ignoreClick = false;
end

function Card:disableTouch()
	self._realBtn:setTouchEnabled(true)
	self._ignoreClick = true;
end

function Card:stop()
	self._cardValue = - 1;
	self._cardName = nil;
	self._chairTypeType = CardDefines.Chair.Invalid;
	self._cardState = CardDefines.CardState.Invalid;
	self._backGroundType = CardDefines.BackGroundType.Invalid;
	
	self._card:removeFromParent(true);
	self._card = nil;
	self:cleanTexture()
	--牌面,万条筒等
	self.surface = nil;
	--遮罩,蒙灰
	self._darkMask = nil;
	-- 项点颜色
	self._color = nil
	-- 吃碰扛的提示信息
	if self._tips ~= nil then
		self._tips:removeFromParent(true)
		self._tips = nil
	end
	--鬼牌角标
	for _, cornerImg in pairs(self._cornerMasks) do
		cornerImg:removeFromParent(true)
	end
	self._cornerMasks = {}
	
	-- 是否可以点击
	self.mouseEnabled = true
	
	self._csb = nil
	self._img = nil
end

function Card:_release()
	game.service.LocalPlayerSettingService.getInstance():removeEventListenersByTag(self)
	super:release();
end

function Card:delete()
	if self._tips ~= nil then
		self._tips:removeFromParent(true)
		self._tips = nil
	end
	--鬼牌角标
	for _, cornerImg in pairs(self._cornerMasks) do
		if not tolua.isnull(cornerImg) then 
			cornerImg:removeFromParent(true)
		end 
	end
	self._cornerMasks = {}
	
	self._color = nil
	self:setRotation(0)
	self:stopAllActions()
	self:removeFromParent(false);
	super.delete(self);
end

function Card:cleanTexture()
	if self._texture ~= nil then
		CardFactory:getInstance():removeTexture(self._texture)
		self._texture = nil
	end
end

-- function Card:setPosition(point)
-- 	cc.Node.setPosition(self, point) 	
-- 	self:_calcBoundingBox()
-- end
-- function Card:_getPosition()
-- 	return self._card:getPosition()
-- end
function Card:setZOrder(zOrder)
	self:setLocalZOrder(zOrder)
end

function Card:setSize(size)
	-- self._realBtn:ignoreContentAdaptWithSize(true)
	-- self._realBtn:setContentSize(size)
end

function Card:changeSize(widget, scale)
	-- widget:ignoreContentAdaptWithSize(true)
	-- local size = widget:getContentSize()
	-- local selfScale = widget:getScale()
	-- scale = scale * selfScale
	-- size.width = size.width * scale
	-- size.height = size.height * scale
	-- widget:setContentSize(size)
end

function Card:getSize()
	local box = self._realBtn:getBoundingBox()
	local scale = self:getScale()
	local width = box.width * scale
	local height = box.height * scale
	return width, height
end

--[[	改变顶点颜色
]]
-- force 可强制改变已经创建出来的牌的颜色(如果颜色没设置就不改变了)
function Card:changeColor(ccr, force)
	if self._color and(not force) or not ccr then
		return
	end
	self._color = ccr
	local function check(node)
		local chidren = node:getChildren()
		table.foreach(chidren, function(key, val)
			check(val)
		end)
		node:setColor(ccr)
	end
	check(self)
end

-- 显示吃碰扛相关提示
-- pos == -1 是转弯豆的图标, TODO : 转弯豆应该使用角标
function Card:showTips(pos)
	local skin = ""
	if pos ~= - 1 then
		-- 0,1,2,3 => 下，左，上，右
		local skins = {
			"art/mahjong_card/icon_zs2.png",
			"art/mahjong_card/icon_zs4.png",
			"art/mahjong_card/icon_zs1.png",
			"art/mahjong_card/icon_zs3.png",
		}
		
		local index =(self._chairTypeType - 1 + pos - 1) % 4 + 1
		skin = skins[index]
	else
		skin = "art/mahjong_card/icon_zwd.png"
	end
	if self._tips == nil then
		self._tips = ccui.ImageView:create()
		self:addChild(self._tips)
	end
	
	-- self._tips:loadTexture(skin, ccui.TextureResType.plistType);
	self:_imageLoadTexture(self._tips, skin)
	local box = self._realBtn:getBoundingBox()
	local x = box.width * 0.5
	local y = box.height * 0.5
	local boxt = self._tips:getBoundingBox()
	
	self._tips:setGlobalZOrder(5000)
	if config.getIs3D() and self._chairTypeType ~= CardDefines.Chair.Down and self._chairTypeType ~= CardDefines.Chair.Top then
		self._tips:setScale(1)
		self._tips:setPosition(cc.p(0, - y + boxt.height / 2 + 12))
	else
		self._tips:setScale(config.getIs3D() and 0.8 or 0.5)
		self._tips:setPosition(cc.p(0, - y + boxt.height / 2 - 6))
	end
	-- 设置碰杠提示
	-- local trigger = game.service.LocalPlayerSettingService:getInstance():getEffectValues().effect_PengGangTiShi
	-- self._tips:setVisible(trigger)
end

--设置所有牌标,cornerTxt目前只支持一种角标的使用自定义文字
function Card:setCornerMasks(cornerTypes, chairType, cornerTxt)
	if not cornerTypes then
		return
	end
	if type(cornerTypes) == "table" then
		for _, cornerType in ipairs(cornerTypes) do
			self:_setCorner(cornerType, chairType)
		end
	else
		self:_setCorner(cornerTypes, chairType, cornerTxt)
	end
end
--设置牌标
function Card:_setCorner(cornerType, chairType, cornerTxt)
	local skin = cornerConfig[cornerType]
	if skin then
		local cornerImg = ccui.ImageView:create()
		table.insert(self._cornerMasks, cornerImg)
		-- cornerImg:loadTexture(skin, ccui.TextureResType.plistType);
		self:_imageLoadTexture(cornerImg, skin)
		
		local size = self._face:getContentSize()
		--local scale = self:getScaleX()
		cornerImg:ignoreContentAdaptWithSize(false)
		--cornerImg:setScale(scale)
		local offset = 0
		if chairType % 2 == 0 then
			offset = 10
		end
		cornerImg:setPosition(size.width/2 + 2, size.height / 2 + offset + 2)
		cornerImg:setContentSize(size)
		
		-- 添加自定义文字
		local text = ccui.TextBMFont:create()
		text:setFntFile("art/font/Tips1.fnt")
		text:setAnchorPoint(cc.p(1, 0))
		text:setString(cornerTxt)
		local isClassic = game.service.GlobalSetting.getInstance().isClassic and not config.getIs3D()
		if isClassic then
			text:setScale(1)
		else
			text:setScale(2.2)
		end
		text:setPosition(size.width - 6, 0)
		cornerImg:addChild(text)
		
		self._face:addChild(cornerImg)
	end
end

function Card:scale(scale)
	-- if self._realBtn then
	-- 	self:changeSize(self._realBtn, scale)
	-- end
	-- if self._face then
	-- 	-- self:changeSize(self._face, scale)
	-- end
	self:setScale(scale)
end

function Card:rotation(degree)
	if nil ~= self._face and degree ~= 0 then
		if degree == 90 then
			-- 这个已经配在UI上了，不用处理了。。。
		elseif degree == 180 then
			self._face:setRotation(degree)
			self._face:setPositionY(33)
		elseif degree == - 90 then
			self._face:setRotation(degree)
			self._face:setPositionX(23)
		end
	end
end

-- position 全局坐标
function Card:isIn(position)
	--[[local size = self._realBtn:getContentSize()
	local x, y = self._realBtn:getPosition()
	local pt = cc.p(x,y)
	pt = self._realBtn:convertToWorldSpace(pt)
	local anchor = self._realBtn:getAnchorPoint()
	local scale = self._realBtn:getScale()
	local sz2pt = cc.p(size.width, size.height)
	sz2pt = self._realBtn:convertToWorldSpace(sz2pt)
	-- pt.x = pt.x - size.width * anchor.x * scale
	-- pt.y = pt.y - size.height * anchor.y * scale
	local rect = cc.rect(pt.x, pt.y, size.width, size.height)
	-- dump(scale, "scale =====>", 10)
	-- dump(anchor, "anchor =====>", 10)
	-- dump(rect, "rect =====>", 10)
	-- dump(position, "position =====>", 10)	
	return cc.rectContainsPoint(rect, position)]]
	local box = self._realBtn:getBoundingBox()
	local box_Clone = clone(box)
	box_Clone.y = box_Clone.y - 15
	box_Clone.height = box_Clone.height + 30
	local pos = self._realBtn:getParent():convertToNodeSpace(position)
	return cc.rectContainsPoint(box_Clone, pos)
end

-- 次功能有许多问题，先不上，注释
-- local toResSrc = {
--     [CardDefines.BackGroundType.Invalid] = nil,
--     [CardDefines.BackGroundType.Stand] = "mg_bg.png",
--     [CardDefines.BackGroundType.Stand_Top] = "mj_bg3.png",
--     [CardDefines.BackGroundType.Stand_Left] = "mj_bg5.png",
--     [CardDefines.BackGroundType.Stand_Right] = "mj_bg4.png",
--     [CardDefines.BackGroundType.Lie_Sur] = "mj_bg2.png",
--     [CardDefines.BackGroundType.Lie_Sur_Glow] = "mj_bg9.png",
--     [CardDefines.BackGroundType.Lie_Back] = "mj_bg7.png",
--     [CardDefines.BackGroundType.Lie_H_Sur_Left] = "mj_bg6.png",
--     [CardDefines.BackGroundType.Lie_H_Sur_Right] = "mj_bg9.png",
--     [CardDefines.BackGroundType.Lie_H_Sur_Glow] = "mj_bg10.png",
--     [CardDefines.BackGroundType.Lie_H_Back] = "mj_bg8.png",
--     [CardDefines.BackGroundType.Stand_Back] = "mj_bg1.png",
-- }
-- function Card:_onChangeBackground(event)
-- 	-- 当realBtn为空的表示为UI中美术创建的牌，不需要处理
-- 	if self._realBtn == nil then return end
-- 	-- local i = self._backGroundType == 0 and "" or tostring(self._backGroundType)
-- 	-- local bgIndex = event.value
-- 	-- local src = "art/card_bg_" .. bgIndex .. "/mj_bg" .. i .. ".png"
-- 	-- self._realBtn:loadTextures(src, src, src)
-- 	local textureName = toResSrc[self._backGroundType] -- 如果card处在 stop，textureName为nil
-- 	if textureName == nil then return end
-- 	local bgIndex = event.value
-- 	local src = "art/card_bg_" .. bgIndex .. "/" .. textureName
-- 	self._realBtn:loadTextures(src, src, src)
-- end
-- 碰杠提示事件回调
-- function Card:_onPengGangTiShiChanged(event)
-- 	if self._tips == nil then return end 
-- 	self._tips:setVisible(event.value)
-- end
return Card 