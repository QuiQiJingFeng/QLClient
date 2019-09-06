local csbPath = "ui/csb/Club/UIClubJoin.csb"
local super = require("app.game.ui.UIBase")

--[[
    加入亲友圈界面
]]

local JION_TYPE_1 =
{
    {"有邀请码", "UIClubJoin_InvitationCode"},
}

local JION_TYPE_2 =
{
    {"无邀请码", "UIClubJoin_Recommend"},
    {"有邀请码", "UIClubJoin_InvitationCode"},
}
local UIClubJoin = class("UIClubJoin", super, function() return cc.CSLoader:createNode(csbPath) end)

function UIClubJoin:ctor()
    self._node = seekNodeByName(self, "Panel_node", "ccui.Layout")

    self._listClubJion = seekNodeByName(self, "ListView_Join_Type", "ccui.ListView")

    self._listClubJion:setScrollBarEnabled(false)
	self._listClubJion:setTouchEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listClubJion, "CheckBox_JoinType")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)
end

function UIClubJoin:show()
    self:setVisible(true)
    self:setPosition(0, 0)
     -- 清空列表
    self._listClubJion:removeAllChildren()

    self._btnCheckList = {}

    local type = JION_TYPE_1
    local userData = game.service.club.ClubService.getInstance():getUserData()
    -- 根据服务器配置的白名单显示不同功能的界面
    if userData:getIsInWhiteList() then
        type = JION_TYPE_2
    end
    for i = 1, #type do
        local node = self._listviewItemBig:clone()
		self._listClubJion:addChild(node)
		node:setVisible(true)

        -- 显示功能名字
        local textType = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_15")
        textType:setString(type[i][1])

        local isSelected = false
        node:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = node:isSelected()
			elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then	
				self:_onItemTypeClicked(type[i])
				node:setSelected(true)
          	elseif eventType == ccui.TouchEventType.canceled then
                node:setSelected(isSelected)
            end
        end)
        self._btnCheckList[type[i][2]] = node
    end

    -- 暂时先隐藏
    self._listClubJion:setVisible(false)

    -- 默认显示亲友圈资源
    self:_onItemTypeClicked(type[1])
end

-- 显示子界面
function UIClubJoin:_onItemTypeClicked(itemType)
     -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if k == itemType[2] then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end

    -- 加载子界面
    if self._uiElemList[itemType[2]] == nil then
        local clz = require("app.game.ui.club.create." .. itemType[2])
        local ui = clz.new(self)
        self._uiElemList[itemType[2]] = ui
        self._node:addChild(ui)
    end

    self:_hideAllPages()
    self._uiElemList[itemType[2]]:show()
end

function UIClubJoin:_hideAllPages()
    -- 防止没有显示父界面就隐藏子界面
    if self._uiElemList == nil then
        return
    end

    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

function UIClubJoin:hide()
    -- 清空数据
    self:_hideAllPages()
    self._uiElemList = {}
    self._btnCheckList= {}

    self:setVisible(false)
end

return UIClubJoin