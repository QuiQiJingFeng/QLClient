local csbPath = 'ui/csb/Prop/UIPropDetail.csb'
local super = require("app.game.ui.UIBase")
local UIPropDetail = class("UIPropDetail", super, function() return kod.LoadCSBNode(csbPath) end)

function UIPropDetail:needBlackMask() return true end
function UIPropDetail:closeWhenClickMask() return true end


function UIPropDetail:ctor()
end

function UIPropDetail:init()
	--即将过期的标志
	self._imgFlagDate = seekNodeByName(self, "imgFlagDate", "ccui.ImageView")
	--物品图标
	self._imgIcon = seekNodeByName(self, "imgIcon", "ccui.Layout")
	--物品名称
	self._texName = seekNodeByName(self, "textName", "ccui.Text")
	--物品时限
	self._textDate = seekNodeByName(self, "textPropDate", "ccui.Text")
	--物品详细信息
	self._textDetail = seekNodeByName(self, "textDetail", "ccui.Text")
	
	self._scrollView = seekNodeByName(self, "scrollView", "ccui.ScrollView")
	
end

-- 目前很多用不到就先不写全了
function UIPropDetail:onShow(propId)
	local prop = PropReader.getPropById(propId)
	PropReader.setIconForNode(self._imgIcon, propId)
	self._texName:setString(prop.name)
	
	self._imgFlagDate:setVisible(false)
	
	self._textDetail:setString(
	string.format("道具名称：%s;\n有效期：永久;\n道具属性：%s;\n道具介绍：%s",
	prop.name, PropReader.getTypeNameById(propId), prop.desc)
	)
	
	local size = self._textDetail:getContentSize()
	self._textDetail:setTextAreaSize(cc.size(size.width, 0))
	local realSize = self._textDetail:getVirtualRendererSize()
	self._textDetail:setContentSize(cc.size(realSize.width, realSize.height))
	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, realSize.height))
	
end


function UIPropDetail:onHide()
	
end


return UIPropDetail 