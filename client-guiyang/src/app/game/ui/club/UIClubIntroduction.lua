local csbPath = "ui/csb/Club/UIClubIntroduction.csb"
local super = require("app.game.ui.UIBase")

--[[
    管理介绍界面
        只做显示，内容美术做好了
]]

local UIClubIntroduction = class("UIClubIntroduction", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubIntroduction:ctor()
    self._btnQuit           = nil       -- 退出
end

function UIClubIntroduction:init()
    self._btnQuit           = seekNodeByName(self, "Button_x_Clubjs",       "ccui.Button")

    self:_registerCallBack()
end

function UIClubIntroduction:_registerCallBack()
    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
end

function UIClubIntroduction:_onBtnQuitClick()
    UIManager:getInstance():hide("UIClubIntroduction")
end

function UIClubIntroduction:onShow()
end

function UIClubIntroduction:onHide()
end

function UIClubIntroduction:needBlackMask()
	return true
end

function UIClubIntroduction:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubIntroduction:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubIntroduction