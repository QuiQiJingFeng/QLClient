--[[
弹窗公告界面
1. 支持图片显示和文字֧
2. 图片可以一张一张显示
--]]
local csbPath = "ui/csb/UINotice.csb"
local super = require("app.game.ui.UIBase")

local UINotice = class("UINotice", super, function () return kod.LoadCSBNode(csbPath) end)

function UINotice:ctor()
	self._btnClose  = nil;
end

function UINotice:needBlackMask()
	return true;
end

function UINotice:closeWhenClickMask()
	return true
end

function UINotice:init()
	self._btnClose  = seekNodeByName(self, "Button_Close",  "ccui.Button");
	self._imageContent = seekNodeByName(self, "Image_bg_Notice",  "ccui.ImageView");
	self._imageNotice = seekNodeByName(self, "Sprite_content_Notice", "cc.Sprite")
	self._labelBg = seekNodeByName(self, "Panel_content_Notice",  "ccui.Layout");
	self._labelTitle = seekNodeByName(self, "BitmapFontLabel_1",  "ccui.TextBMFont");
	self._labelContent = seekNodeByName(self, "Text_content_Notice",  "ccui.Text");
	self._labelTitleBg = seekNodeByName(self, "Image_bg_1_messagelist", "ccui.ImageView")
	self._labelTitle_Bg = seekNodeByName(self, "Image_top_1_messagelist", "ccui.ImageView")

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended);
end
--[[
	- 参数列表
		- 1.true 为图片公告 2.图片
		- 1.false 为文字公告 2.文字内容
]]
function UINotice:onShow(...)
	local ags = {...}
	if ags[1] then
		self:_showImageNotice(ags[2])
	else
		self:_showTextNoice(ags[2])
	end
    -- 图片公告隐藏title
	self._labelTitle_Bg:setVisible(ags[1] == false)
end

function UINotice:_clearContent()
	self._imageContent:setVisible(false);
	-- TODO : 清空设置的图片
	self._labelBg:setVisible(false);
	self._labelTitle:setString("");
	self._labelContent:setString("");
end

function UINotice:_showImageNotice(filePath)
	-- 显示图片公告
	self._labelTitle:setVisible(false)
	self._labelContent:setVisible(false)
	self._imageContent:setVisible(false);
	self._labelBg:setVisible(false);
	self._imageNotice:setVisible(true)
	self._labelTitleBg:setVisible(false);
	self._labelTitle_Bg:setVisible(false)
	
	if self._imageNotice.loadTexture then						
		self._imageNotice:loadTexture(filePath)
	elseif self._imageNotice.setTexture then
		self._imageNotice:setTexture(filePath)
	end
		
	self:_adjustImageNotice()
end

function UINotice:_showTextNoice(data)
	-- 显示文本公告
	self._labelTitle:setVisible(true)
	self._labelContent:setVisible(true)
	self._imageContent:setVisible(true);
	self._imageNotice:setVisible(false)
	self._labelTitleBg:setVisible(true);
	self._labelTitle_Bg:setVisible(true)
	self._labelBg:setVisible(true);
	self._labelTitle:setString(data.noticeName);
	self._labelContent:setString(data.content);
	local labelBgSize = self._labelBg:getContentSize()
	self._labelContent:ignoreContentAdaptWithSize(false)
	self._labelContent:setTextAreaSize(cc.size(labelBgSize.width, labelBgSize.height))
	local s = self._labelContent:getVirtualRendererSize()
	self._labelContent:setContentSize(cc.size(labelBgSize.width, s.height))

	-- 公告名称背景根据公告名称的长度设置大小
	-- local ss = self._labelTitle:getVirtualRendererSize()
    -- self._labelTitle_Bg:setContentSize(cc.size(ss.width + 50, ss.height))
end
-- 根据屏幕调整图片公告显示
function UINotice:_adjustImageNotice()
	local screenSize = cc.Director:getInstance():getWinSize()
	local noticeSize = self._imageNotice:getContentSize()
	local scaleX = 1.0
	local scaleY = 1.0
	if screenSize.width < noticeSize.width or screenSize.height < noticeSize.height then	
		scaleX =  screenSize.width / noticeSize.width
		scaleY =  screenSize.height / noticeSize.height
	end
	self._imageNotice:setScale(scaleX, scaleY)
end

function UINotice:_onClickClose(sender)
	UIManager:getInstance():hide("UINotice")
	game.service.NoticeService.getInstance():_showNotice()
end

return UINotice;
