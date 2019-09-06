--[[
??????
--]]
local csbPath = "ui/csb/UIDiamondShop.csb"
local super = require("app.game.ui.UIBase")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local UIDiamondShop = class("UIDiamondShop", super, function () return kod.LoadCSBNode(csbPath) end)

function UIDiamondShop:ctor()
    self._btnOK = nil
    self._listContent = nil
    self._listPanelItem = nil
    self._listGroupItem = nil
end

function UIDiamondShop:init()
    self._btnOK = seekNodeByName(self, "Button_btn_DiamondShop", "ccui.Button")
    self._listContent = seekNodeByName(self, "listContent", "ccui.ListView")
    self._listPanelItem = seekNodeByName(self._listContent, "listPanelItem", "ccui.Text")
    self._listGroupItem = seekNodeByName(self._listContent, "listGroupItem", "ccui.Layout")

    self:_registerCallBack()
end

function UIDiamondShop:_registerCallBack()
    bindEventCallBack(self._btnOK, handler(self, self.onClickOK),ccui.TouchEventType.ended)
end

function UIDiamondShop:needBlackMask()
    return true;
end

function UIDiamondShop:clear()
    local children = self._listContent:getChildren()
    for _, child in ipairs(children) do
        if child:getName() == "listPanelItem_cloned" or
            child:getName() == "listGroupItem_cloned" then
            child:removeFromParent()
        end
    end
end

function UIDiamondShop:onShow(...)
    -- local shows = {
    --     {"text", "钻石不足、游戏反馈等问题请联系客服："},
    --     {"account", "weixin_test1"},
    --     {"account", "weixin_test2"},
    --     {"account", "weixin_test3"},
    --     {"text", "bug反馈等问题请联系客服："},
    --     {"account", "weixin_test4"},
    -- }
    local params = {...}
    local data = params[1]
    local shows = {}
    if data.content ~= nil and data.content ~= "" then
        table.insert(shows, {"text", data.content})
    end
    if data.weiXins ~= nil and #data.weiXins > 0 then
        for i = 1, #data.weiXins do
            table.insert(shows, {"account", data.weiXins[i]})
        end
    end

    self:clear()
    self:showScrollBar(shows)
    self:setData(shows)
end

-- 滚动条显示
function UIDiamondShop:showScrollBar(shows)
    local list_Height = self._listContent:getContentSize().height
    local text_Height = self._listPanelItem:getContentSize().height
    local layout_Height = self._listGroupItem:getContentSize().height

    -- 当没有配文字显示时，UI默认有文字显示所以要提前加上文字框高度
    local height = text_Height
    for i = 1, #shows do
        -- 微信号的layout
        if shows[i][1] == "account" then
            height = height + layout_Height
        else
            -- text
            -- 文字多了要按文字的高度去适配而不是按照原来框的大小去适配
            local tetxItem = seekNodeByName(self._listPanelItem, "listTextItem", "ccui.Text")
            tetxItem:setString(shows[i][2])
            tetxItem:setTextAreaSize(cc.size(self._listPanelItem:getContentSize().width, 0))
            local _size = tetxItem:getVirtualRendererSize();
            -- 配了文字时，文字高度超过文本框高度，就先减去原来文字框的高度，在加文字的高度
            -- 没有超过就不用操作了，默认值就是文字框的高度
            if text_Height < _size.height then
                height = height - text_Height + _size.height
            end
        end
    end

    -- 如果layout和text的高度大于list的高度就显示滚动条并且可以拖动
    if height+text_Height < list_Height then
        self._listContent:setScrollBarEnabled(false)
	    self._listContent:setTouchEnabled(false)
    else
        self._listContent:setScrollBarEnabled(true)
	    self._listContent:setTouchEnabled(true)
    end    
end

function UIDiamondShop:setData(shows)
    local textCounts = 1
    local groupCounts = 1
    for i = 1, #shows do
        if shows[i][1] == "account" then
            local currItem = nil
            if groupCounts == 1 then
                currItem = self._listGroupItem
            else
                currItem = self._listGroupItem:clone()
                currItem:setName("listGroupItem_cloned")
                self._listContent:addChild(currItem)
            end

            local text = seekNodeByName(currItem, "listGroupTextItem", "ccui.Text")
            local button = seekNodeByName(currItem, "Button_listGroupButton", "ccui.Button")
            text:setString(shows[i][2])
            bindEventCallBack(button, function()
				-- TODO : 这是在干什么
				if game.plugin.Runtime.setClipboard(shows[i][2]) == true then
					game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
				end
            end,ccui.TouchEventType.ended)
            groupCounts = groupCounts + 1
        else
            local currItem = nil
            if textCounts == 1 then
                currItem = self._listPanelItem
            else
                currItem = self._listPanelItem:clone()
                currItem:setName("listPanelItem_cloned")
                self._listContent:addChild(currItem)
            end
            local tetxItem = seekNodeByName(currItem, "listTextItem", "ccui.Text")
            tetxItem:setString(shows[i][2])
            --设置_listTextItem高度
            local contentSize = currItem:getContentSize()
            tetxItem:setTextAreaSize(cc.size(contentSize.width, 0))
            local _size = tetxItem:getVirtualRendererSize();
            tetxItem:setContentSize(cc.size(contentSize.width, _size.height))
            -- 当文字高度超过框的高度就重新设置框的高度
            if contentSize.height < _size.height then
                currItem:setContentSize(cc.size(contentSize.width, _size.height))
            end
            
            textCounts = textCounts + 1
        end
    end
    
    -- 没有配置 weixin显示
    if groupCounts == 1 then
        self._listGroupItem:setVisible(false)
    end

end

function UIDiamondShop:onClickOK()
    UIManager:getInstance():destroy("UIDiamondShop")
end

return UIDiamondShop;

