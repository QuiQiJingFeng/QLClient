local csbPath = "ui/csb/Mail/UINotice.csb"
local UINotice = class("UINotice", function() return cc.CSLoader:createNode(csbPath) end)

function UINotice:ctor(parent)
    self._parent = parent

    self._txtTitle = seekNodeByName(self, "Text_tital_Notice", "ccui.Text")
    self._txtContent = seekNodeByName(self, "Text_content_Notice", "ccui.Text")
    self._scrollView = seekNodeByName(self, "ScrollView_Notice", "ccui.ScrollView")
end


function UINotice:show()
    self:setVisible(true)
    
    game.service.NoticeMailService:getInstance():onCGQueryAnnouncementREQ()
    game.service.NoticeMailService:getInstance():addEventListener("EVENT_NOTICE", function(event)
        self:_onshowNotice(event.noticeData[1] or {})
    end, self)
end

function UINotice:_onshowNotice(data)
    if next(data) == nil or (data.title == "" and data.content == "") then
        data = {
            title = "安全提示",
            content = MultiArea.getSafeNotices(game.service.LocalPlayerService:getInstance():getArea()),
        }
    end

    self._txtTitle:setString(data.title)
    self._txtContent:setString(data.content)
    self._txtContent:ignoreContentAdaptWithSize(false)
    local size = self._scrollView:getContentSize()
    self._txtContent:setTextAreaSize(cc.size(size.width, 0))
    self._txtContent:setAnchorPoint(cc.p(0.5, 1))
	local realSize = self._txtContent:getVirtualRendererSize()
	self._txtContent:setContentSize(cc.size(size.width, realSize.height))
    self._scrollView:setScrollBarEnabled(false)

	self._scrollView:setInnerContainerSize(cc.size(size.width, realSize.height))
	if self._scrollView:getContentSize().height < realSize.height then
		self._txtContent:setPositionY(realSize.height)
	else
		self._txtContent:setPositionY(size.height)
	end

    game.service.NoticeMailService:getInstance():onRedDotChanged(net.protocol.NMDotType.ANNOUNCEMENT)
end

function UINotice:hide()
    game.service.NoticeMailService:getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UINotice