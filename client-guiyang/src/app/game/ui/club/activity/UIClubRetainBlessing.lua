local csbPath = "ui/csb/Club/UIClubRetainBlessing.csb"
local super = require("app.game.ui.UIBase")
local UIItem = require("app.game.ui.element.UIItem")

local UIClubRetainBlessing = class("UIClubRetainBlessing", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubRetainBlessing:ctor()
    self._panelNodes = {}
    self._packageId = 0
end

function UIClubRetainBlessing:init()
    self._btnQuit = seekNodeByName(self, "Button_quit", "ccui.Button")
    self._btnOk = seekNodeByName(self, "Button_ok", "ccui.Button")
    self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text")

    self._listBlessing = seekNodeByName(self, "ListView_Blessing", "ccui.ListView")
    
    -- 不显示滚动条, 无法在编辑器设置
    self._listBlessing:setScrollBarEnabled(false)
    self._listBlessing:setTouchEnabled(false)
    self._listViewItemBig = ccui.Helper:seekNodeByName(self._listBlessing, "Panel_commodity")
    self._listViewItemBig:removeFromParent(false)
    self:addChild(self._listViewItemBig)
    self._listViewItemBig:setVisible(false)

    bindEventCallBack(self._btnQuit, handler(self, self._onClickQuit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk, handler(self, self._onClickOk), ccui.TouchEventType.ended)
end

function UIClubRetainBlessing:_onClickQuit()
    UIManager:getInstance():hide("UIClubRetainBlessing")
end

function UIClubRetainBlessing:_onClickOk()
    game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CLUB_WEEK_SIGN):sendCACSelectClubWeekRewardPackageREQ(self._packageId)
end

function UIClubRetainBlessing:onShow(protocol)
    self._textTips:setString(string.format("恭喜您第一次在%s完成牌局，选一个喜欢的专属礼包吧！", config.STRING.COMMON))
    self._info = clone(protocol.rewardPackages)
    self:_initListViewItem()
end

function UIClubRetainBlessing:_initListViewItem()
    self._listBlessing:removeAllChildren()
    self._panelNodes = {}
    for i = 1, #self._info do
        local node = self._listViewItemBig:clone()
        self._listBlessing:addChild(node)
        node:setVisible(true)
        
        table.insert(self._panelNodes, node)

        local btnSelected = ccui.Helper:seekNodeByName(node, "Button_selected")

        bindEventCallBack(btnSelected, function()
            self:_setSelectedStatus(i, self._info[i])
        end, ccui.TouchEventType.ended)

        for j = 1, #self._info[i].rewardItems do
            local panel = ccui.Helper:seekNodeByName(node, string.format("Panel_Gift%d", j))
            local img = ccui.Helper:seekNodeByName(panel, "Panel_Node")
            local text = ccui.Helper:seekNodeByName(panel, "Text_Name")
            UIItem.extend(img, text, self._info[i].rewardItems[j].itemId, self._info[i].rewardItems[j].count, self._info[i].rewardItems[j].time)
        end
    end

    self._listBlessing:requestDoLayout()
    self._listBlessing:doLayout()

    self:_setSelectedStatus(1, self._info[1])
end

-- 设置选中状态
function UIClubRetainBlessing:_setSelectedStatus(idx, data)
    for i = 1, #self._panelNodes do
        local imgSelected = ccui.Helper:seekNodeByName(self._panelNodes[i], "Image_selected") -- 选中状态
        local imgNotSelected = ccui.Helper:seekNodeByName(self._panelNodes[i], "Image_notSelected") -- 未选中状态
        if i == idx then
            imgNotSelected:setVisible(false)
            imgSelected:setVisible(true)
            self._packageId = data.packageId
        else
            imgNotSelected:setVisible(true)
            imgSelected:setVisible(false)
        end
        
    end
    
end

function UIClubRetainBlessing:onHide()
end

function UIClubRetainBlessing:needBlackMask()
    return true
end

function UIClubRetainBlessing:closeWhenClickMask()
    return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRetainBlessing:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top
end

return UIClubRetainBlessing