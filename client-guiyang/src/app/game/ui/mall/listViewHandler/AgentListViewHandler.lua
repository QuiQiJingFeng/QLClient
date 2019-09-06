local TEXT_FONT_SIZE = 25
local LIST_ITEMS_MARGIN = 20
local super = require("app.game.ui.mall.listViewHandler.AbstractListViewHandler")
local AgentListViewHandler = class("AgentListViewHandler", super)

function AgentListViewHandler:ctor(rawListView)
    self.listView = rawListView

    self:_initView()

    if GameMain.getInstance():isReviewVersion() then
        self.listView:setVisible(false)
    else
        game.service.LocalPlayerService.getInstance():addEventListener("EVENT_CONTACT_INFO_GET", handler(self, self._onEventContactInfoGet), self)
        --请求代理信息
        game.service.LocalPlayerService.getInstance():queryContact();
    end
end

function AgentListViewHandler:_initView()
    self._templateTextTitle = seekNodeByName(self.listView, "Template_Text_Title", "ccui.Text")
    self._templateTextWeiXin = seekNodeByName(self.listView, "Template_Text_WeiXin", "ccui.Text")
    self._templateCopyButton = seekNodeByName(self.listView, "Template_Button_Copy", "ccui.Button")

    self._templateTextTitle:retain()
    self._templateTextTitle:setVisible(false)
    self._templateTextTitle:removeFromParent()

    self._templateTextWeiXin:retain()
    self._templateTextWeiXin:setVisible(false)
    self._templateTextWeiXin:removeFromParent()

    self._templateCopyButton:retain()
    self._templateCopyButton:setVisible(false)
    self._templateCopyButton:removeFromParent()

    self.listView:removeAllChildren()
    self.listView:setTouchEnabled(false)
end

function AgentListViewHandler:_onEventContactInfoGet(event)
    local data = event.protocol
    local content = data.content
    local weixinList = data.weiXins

    self.listView:setTouchEnabled(#weixinList > 1)
    self.listView:removeAllChildren()
    local indexInListView = 0
    indexInListView = self:_createTitleTextAndAppendInList(content, indexInListView)
    for _, weiXinStr in ipairs(weixinList) do
        indexInListView = self:_createWeiXinTextAndAppendInList(weiXinStr, indexInListView)
        indexInListView = self:_createCopyButtonAndAppendInList(weiXinStr, indexInListView)
    end
    
    self.listView:setItemsMargin(LIST_ITEMS_MARGIN)
    self.listView:requestDoLayout()
	self.listView:doLayout()
end

function AgentListViewHandler:_createTitleTextAndAppendInList(str, indexInListView)
    local text = ccui.Text:create()
    text:setFontSize(TEXT_FONT_SIZE)
    text:setTextColor(self._templateTextTitle:getTextColor())
    text:setString(str)
    self.listView:addChild(text, indexInListView)
    return indexInListView + 1
end

function AgentListViewHandler:_createWeiXinTextAndAppendInList(str, indexInListView)
    local text = ccui.Text:create()
    text:setFontSize(TEXT_FONT_SIZE)
    text:setTextColor(self._templateTextWeiXin:getTextColor())
    text:setString(str)
    self.listView:addChild(text, indexInListView)
    return indexInListView + 1
end

function AgentListViewHandler:_createCopyButtonAndAppendInList(str, indexInListView)
    local clonedObject = self._templateCopyButton:clone()
    clonedObject:setVisible(true)
    bindEventCallBack(clonedObject, function()
        if game.plugin.Runtime.setClipboard(str) == true then
            game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_CopyAgentWeiXin);
        end
    end, ccui.TouchEventType.ended)
    self.listView:addChild(clonedObject, indexInListView)
    return indexInListView + 1
end

-- overwrite
function AgentListViewHandler:dispose()
    self._templateTextTitle:release()
    self._templateTextWeiXin:release()
    self._templateCopyButton:release()
    game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
    super.dispose(self)
end

return AgentListViewHandler