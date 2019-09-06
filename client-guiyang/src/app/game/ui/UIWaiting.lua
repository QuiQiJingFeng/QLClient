local csbPath = "ui/csb/UIWaiting.csb"
local super = require("app.game.ui.UIBase")
local Constants = require("app.gameMode.mahjong.core.Constants")

--[[
    提前开局玩家等待界面等待
]]

local UIWaiting = class("UIWaiting", super, function () return kod.LoadCSBNode(csbPath) end)

function UIWaiting:ctor()
    self._btnLeave              = nil       -- 离开
    self._listPlayer            = nil       -- 玩家信息
    self._panelHead             = nil
end

function UIWaiting:init()
    self._btnLeave          = seekNodeByName(self, "Button_lk_DDZ",      "ccui.Button")
    self._listPlayer        = seekNodeByName(self, "ListView_list_DDZ", "ccui.ListView")
    -- 不显示滚动条
    self._listPlayer:setScrollBarEnabled(false)

    self._panelHead = ccui.Helper:seekNodeByName(self._listPlayer, "Panel_player_DDZ")
	self._panelHead:removeFromParent(false)
	self:addChild(self._panelHead)
	self._panelHead:setVisible(false)


    bindEventCallBack(self._btnLeave,    handler(self, self._onBtnLeave),     ccui.TouchEventType.ended)
end

function UIWaiting:onShow(...)
    self._data = ...
    
    self:_updataPlayerInfo()
end

function UIWaiting:_updataPlayerInfo()
    self._listPlayer:removeAllItems()
    local playerCount = game.service.RoomService:getInstance():getMaxPlayerCount()
    for i = 1, playerCount do
        local node = self._panelHead:clone()
		self._listPlayer:addChild(node)
		node:setVisible(true)

        local imgHead   = ccui.Helper:seekNodeByName(node, "Image_face_player_DDZ")         -- 头像
        local textName = ccui.Helper:seekNodeByName(node, "Text_name_player_DDZ")           -- 玩家昵称
        local imgMask =  ccui.Helper:seekNodeByName(node, "Image_black_player_DDZ")         -- 蒙灰
        local textStatus =  ccui.Helper:seekNodeByName(node, "BitmapFontLabel_zt_DDZ")      -- 玩家状态

        textName:setVisible(false)
        imgMask:setVisible(false)
        textStatus:setVisible(false)

        if i <= #self._data then
            local player = self._data[i]
            game.util.PlayerHeadIconUtil.setIcon(imgHead, player.headImageUrl)
            textName:setVisible(true)
            textName:setString(game.service.club.ClubService.getInstance():getInterceptString(player.nickname, 8))
            if bit.band(player.status, Constants.PlayerStatus.WAITING) ~= 0 then
                imgMask:setVisible(true)
                textStatus:setVisible(true)
                textStatus:setString("等待中")  
            end
        else
            textStatus:setVisible(true)
            textStatus:setString("待加入") 
        end
    end
end

-- 离开队列
function UIWaiting:_onBtnLeave()
    game.ui.UIMessageBoxMgr.getInstance():show("现在离开等待队列，可能会被其他玩家替代位置失去进入房间机会，确定离开吗？", {"离开", "取消"}, function()
        game.service.RoomService.getInstance():quitRoom()
        UIManager:getInstance():hide("UIWaiting")
    end)
end

function UIWaiting:onHide()
    self._listPlayer:removeAllItems()
end


function UIWaiting:needBlackMask()
	return false
end

function UIWaiting:closeWhenClickMask()
	return false
end



return UIWaiting