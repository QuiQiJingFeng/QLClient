local csbPath = "ui/csb/UIPersonalCenter.csb"
local super = require("app.game.ui.UIBase")

local UIPersonalCenter = class("UIPersonalCenter", super, function () return kod.LoadCSBNode(csbPath) end)

-- 玩家信息
local type =
{
    {name = "基本资料", ui = "UIPlayerInfo", id = 1, redDotKey = ""},
    --{ name = "我的钱包", ui = "UIWallet", id = 2, redDotKey = "wallet" }
}

function UIPersonalCenter:ctor()
    self._btnCheckList = {}
    self._uiElemList = {}
end

function UIPersonalCenter:init()
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    self._node = seekNodeByName(self, "Node_node", "cc.Node")

    self._listviewPlayerInfo = seekNodeByName(self, "ListView_playerInfo", "ccui.ListView")

    -- 不显示滚动条, 无法在编辑器设置
    self._listviewPlayerInfo:setScrollBarEnabled(false)
    self._listviewPlayerInfo:setTouchEnabled(false)
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listviewPlayerInfo, "GAME_TYPE_BUTTON")
    self._listviewItemBig:removeFromParent(false)
    self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)

    bindEventCallBack(self._btnClose, handler(self, self._onCloseClick), ccui.TouchEventType.ended)
end

function UIPersonalCenter:onShow()
    self._typeId = 0
    self:_initList()

    self:playAnimation_Scale()
end

function UIPersonalCenter:_initList()
    self._listviewPlayerInfo:removeAllChildren()

    for _, v in ipairs(type) do
        local node = self._listviewItemBig:clone()
        self._listviewPlayerInfo:addChild(node)
        node:setVisible(true)
        local redDot = node:getChildByName("RedDot")
        if redDot == nil then
            redDot = ccui.ImageView:create("img/Img_red.png")
            redDot:setAnchorPoint(0.5, 0.5)
            redDot:setName("RedDot")
            node:addChild(redDot)
            redDot:setPositionPercent(cc.p(0.9, 0.8))
        end
        if v.redDotKey ~= nil and v.redDotKey ~= "" then
            redDot:setVisible(manager.RedDotStateTreeManager.getInstance():isVisible(v.redDotKey))
        else
            redDot:hide()
        end
        local name = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_3")
        name:setString(v.name)
        local isSelected = false
        node:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = node:isSelected()
            elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then
                self:_onItemTypeClicked(v)
                -- 统计点击排行榜页签次数
                game.service.DataEyeService.getInstance():onEvent(v.ui)
                node:setSelected(true)
                -- 点击后刷新红点
                redDot:hide()
                if v.redDotKey then
                    local manager = manager.RedDotStateTreeManager.getInstance()
                    manager:changeRedDotData(v.redDotKey, 0)
                end
            elseif eventType == ccui.TouchEventType.canceled then
                node:setSelected(isSelected)
            end
        end)
        self._btnCheckList[v.id] = node
    end

    self:_onItemTypeClicked(type[1])
end


function UIPersonalCenter:_onItemTypeClicked(data)
    -- 按钮的显示与隐藏
    for k,v in pairs(self._btnCheckList) do
        if k == data.id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
    end

    -- 当前已显示该界面再点击无效
    if self._typeId == data.id then
        return
    end

    if self._uiElemList[data.id] == nil then
        local clz = require("app.game.ui.playerInfo." .. data.ui)
        if self == nil then 
            local isExist = cc.FileUtils:getInstance():isFileExist(csbPath)
            Logger.debug(isExist and "true" or "false")
        end 
        local ui = clz.new(self)
        self._uiElemList[data.id] = ui
        self._node:addChild(ui)
    end

    self:_hideAllPages()
    self._uiElemList[data.id]:show()
end

function UIPersonalCenter:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

function UIPersonalCenter:_onCloseClick()
    UIManager:getInstance():destroy("UIPersonalCenter")
end

function UIPersonalCenter:onHide()
    self:_hideAllPages()
    self._btnCheckList = {}
    self._uiElemList = {}
    self._typeId = 0
end

function UIPersonalCenter:needBlackMask()
    return true
end

function UIPersonalCenter:closeWhenClickMask()
    return false
end


return UIPersonalCenter