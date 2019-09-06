local csbPath = "ui/csb/Backpack/UIBagInfo.csb"

local UIElemItem= class("UIElemItem",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIElemItem:ctor()
end


function UIElemItem:init()

	self._imageItem = seekNodeByName(self, "Image_1", "ccui.ImageView")
	self._imageItem:ignoreContentAdaptWithSize(true)
	self._textItem = seekNodeByName(self, "Text_name", "ccui.Text")
	self._textDesc = seekNodeByName(self, "Text_content", "ccui.Text")
	self._textTime = seekNodeByName(self, "Text_time", "ccui.Text")
	self._textTime:setVisible(false)
end


function UIElemItem:needBlackMask()
    return true
end

function UIElemItem:closeWhenClickMask()
	return true
end

function UIElemItem:onShow(itemId, count)
	local icon = PropReader.getIconByIdAndCount(itemId,count)
	local name = PropReader.getNameById(itemId)
	local desc = PropReader.getPropById(itemId).desc
	local strType = PropReader.getTypeById(itemId)
	if strType ~= "HeadFrame" and strType  ~= "RedPackage" then
		name = name.."*"..count
	end
	
	self._imageItem:getParent():removeChildByName("csbItem")
	if string.sub(icon, string.len( icon )-3) == ".csb" then
		--头像框的处理		
		self._imageItem:setVisible(false)
		local pNode = cc.CSLoader:createNode(icon)
		local ani = cc.CSLoader:createTimeline(icon)
		ani:gotoFrameAndPlay(0, true)
		-- pNode:setScale(0.8)
		pNode:runAction(ani)
		pNode:setPosition(self._imageItem:getPosition())
		pNode:setName("csbItem")
		self._imageItem:getParent():addChild(pNode)
	else
		self._imageItem:setVisible(true)
		self._imageItem:loadTexture(icon)
	end
	self._textItem:setString(name)
	self._textDesc:setString(desc)


	if strType == "RedPackage" then		--特殊化处理随机红包，后面赶紧删了吧
		self._textItem:setString("随机红包")
		self._textDesc:setString("随机获得1-100元红包，可在公众号 'myqhd2017' 领取")
	end
end


return UIElemItem
