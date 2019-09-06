local csbPath = "ui/csb/Club/UIClubCreate2.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UIClubCreate2 = class("UIClubCreate2", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubCreate2:ctor()
end

function UIClubCreate2:init()
    self._textClubName = seekNodeByName(self, "TextField_clubName", "ccui.TextField") -- 俱乐部名字
    self._btnCreate = seekNodeByName(self, "Button_create", "ccui.Button") -- 创建

    bindEventCallBack(self._btnCreate, handler(self, self._onCreateClick), ccui.TouchEventType.ended)
    game.service.LoginService.getInstance():addEventListener("EVENT_BINDPHONE_CHANGED", handler(self, self._onCreateClub), self)
    game.service.club.ClubService.getInstance():getClubMemberService():addEventListener("EVENT_CLUB_CREATE_RESULT", function (event)
        if event.result then
            UIManager:getInstance():destroy("UIClubCreate2")
        else
            if self._textClubName ~= nil then 
                self._textClubName:setString("")
            end 
        end
    end , self)
end

function UIClubCreate2:onShow()
    self._textClubName:setTextColor(cc.c4b(151, 86, 31, 255))
    self._textClubName:setString("")
    self:playAnimation_Scale()
end

function UIClubCreate2:_onCreateClick()
    local bindPhone = game.service.LocalPlayerService.getInstance():getBindPhone()
    if bindPhone then
        self:_onCreateClub()
    else
        -- 手机绑定二次确认弹窗
        game.ui.UIMessageBoxMgr.getInstance():show("绑定手机号即可通过手机号登陆并提升账户安全性，请您绑定手机号", {"立即绑定", "取消"},
            function()
                UIManager:getInstance():show("UIPhoneLogin",game.globalConst.phoneMgr.phonebind)
            end,
            function()
                self:_onCreateClub()
            end,
            true,
            false,
            1
        )
    end
end

function UIClubCreate2:_onCreateClub()
    local clubName = self._textClubName:getString()
    -- 默认头像
    game.service.club.ClubService.getInstance():getClubMemberService():sendCCLCreateClubREQ(clubName, ClubConstant:getClubDefaultIconName())
end

function UIClubCreate2:onHide()
    game.service.LoginService.getInstance():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)

    -- 键盘自动隐藏
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)
end

function UIClubCreate2:needBlackMask()
	return true
end

function UIClubCreate2:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubCreate2:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubCreate2