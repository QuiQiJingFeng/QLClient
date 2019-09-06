local csbPath = "ui/csb/Club/UIClubMain.csb"
local super = require("app.game.ui.UIBase")

local CLUBITEM_TYPE = 
{
    {config.STRING.UICLUBMAIN_STRING_100, "UIClubJoin_InvitationCode"},
    {config.STRING.UICLUBMAIN_STRING_101, "UIClubCreate"},
    {config.STRING.UICLUBMAIN_STRING_102, "UIClubList"}
}


-- local hasUpload = false

--[[
    亲友圈主界面
]]

local UIClubMain = class("UIClubMain", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubMain:ctor()
    self._listClubItem = nil -- 亲友圈主界面功能
    self._btnQuit = nil -- 返回
    self._btnCheckList = {}
    self._uiElemList = {}
    self._node = nil

    self._isRecommend = true
    self._isRequest = false
end

function UIClubMain:init()
    self._btnQuit = seekNodeByName(self, "Button_X_CreateRoom", "ccui.Button")
    self._listClubItem = seekNodeByName(self, "ListView_Game_Type_Btn", "ccui.ListView")
    self._node = seekNodeByName(self, "Image_bg0_Recommend", "ccui.ImageView")

    self._listClubItem:setScrollBarEnabled(false)
	self._listClubItem:setTouchEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listClubItem, "Panel_Node")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
end

function UIClubMain:onShow(isRecommend)
    self._isRequest = false
    self._isRecommend = isRecommend
    self._listClubItem:removeAllChildren()
    self:_initClubItemUI()

    self:playAnimation_Scale()

    self:_showTabBadge()
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._showTabBadge), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_ADDED", handler(self, self._initClubItemUI), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_DELETED", handler(self, self._initClubItemUI), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_QUERY_CLUB_INFO", handler(self, self._onUpdataClubInfo), self)
end

function UIClubMain:_onUpdataClubInfo()
    if self._isRequest then
        self:_initClubItemUI()
    end
end

function UIClubMain:_isRequestInfo()
    if self._isRequest then return true end
    local clubList = game.service.club.ClubService.getInstance():getClubList()
    if #clubList.clubs > 0 then
        return true
    end

    game.service.club.ClubService.getInstance():_sendCCLQueryClubInfosREQ()
    self._isRequest = true

    -- if not hasUpload then
    --     hasUpload = true
    --     game.service.UploadLogService:getInstance():setNeedUpload(true)
    --     game.service.UploadLogService:getInstance():doUpload()
    -- end
end

-- 入会申请小红点
function UIClubMain:_showTabBadge()
    local service = game.service.club.ClubService.getInstance()
    if self._btnCheckList[CLUBITEM_TYPE[1][2]] ~= nil then
        local imgRed = ccui.Helper:seekNodeByName(self._btnCheckList[CLUBITEM_TYPE[1][2]], "GAME_TYPE_BUTTON_FREE_0")
        imgRed:setVisible(service:getUserData():hasInvitationBadges() or service:getUserData():hasRecommandInvitationBadges())
    end
end


function UIClubMain:_initClubItemUI()
    local clubList = game.service.club.ClubService.getInstance():getClubList()
    
     -- 清空列表
    self._listClubItem:removeAllChildren()

    -- 玩家没有亲友圈的情况不显示我的亲友圈页签
    local count = #clubList.clubs > 0 and 3 or 2
    
    self._btnCheckList = {}

    for i = 1, count do
        local node = self._listviewItemBig:clone()
		self._listClubItem:addChild(node)
		node:setVisible(true)

        -- 显示功能名字
        local checkNode = ccui.Helper:seekNodeByName(node, "GAME_TYPE_BUTTON")
        local textType = ccui.Helper:seekNodeByName(checkNode, "GAME_TYPE_BUTTON_TXT")
        textType:setString(CLUBITEM_TYPE[i][1])

        -- 小红点默认不显示
        local imgRed = ccui.Helper:seekNodeByName(checkNode, "GAME_TYPE_BUTTON_FREE_0")
        imgRed:setVisible(false)

        local isSelected = false
        checkNode:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = checkNode:isSelected()
			elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then	
				self:_onItemTypeClicked(CLUBITEM_TYPE[i])
                checkNode:setSelected(true)
          	elseif eventType == ccui.TouchEventType.canceled then
                checkNode:setSelected(isSelected)
            end
        end)
        self._btnCheckList[CLUBITEM_TYPE[i][2]] = checkNode
    end

    -- 我的亲友圈也签上的红点
    if self._btnCheckList[CLUBITEM_TYPE[3][2]] ~= nil then
        local imgRed = ccui.Helper:seekNodeByName(self._btnCheckList[CLUBITEM_TYPE[3][2]], "GAME_TYPE_BUTTON_FREE_0")
        local clubList = game.service.club.ClubService.getInstance():getClubList()
        if #clubList.clubs > 0 then
            for _, data in ipairs(clubList.clubs) do
                if data:hasApplicationBadges() or data:hasTaskBadges() then
                    imgRed:setVisible(true)
                    break
                end
            end
        end
    end

    -- 有亲友圈的玩家默认显示亲友圈页签，没有的默认显示加入亲友圈页签
    if self._isRecommend then
        self:_onItemTypeClicked(CLUBITEM_TYPE[count == 2 and 1 or 3])
    else
        self:_onItemTypeClicked(CLUBITEM_TYPE[1])
    end
    self._listClubItem:forceDoLayout()
    self:_isRequestInfo()
end

function UIClubMain:_onItemTypeClicked(itemType)
    -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if k == itemType[2] then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end

    if self._uiElemList[itemType[2]] == nil then
        local clz = require("app.game.ui.club.create." .. itemType[2])
        local ui = clz.new(self)
        self._uiElemList[itemType[2]] = ui
        self._node:addChild(ui)
    end

    self:_hideAllPages()
    self._uiElemList[itemType[2]]:show()
end

function UIClubMain:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

-- 返回
function UIClubMain:_onBtnQuitClick()
    UIManager:getInstance():hide("UIClubMain")
end

function UIClubMain:onHide()
    -- 取消监听事件
    self:_hideAllPages()
    self._uiElemList = {}
    self._btnCheckList= {}
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
end

function UIClubMain:needBlackMask()
	return true
end

function UIClubMain:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubMain:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubMain
