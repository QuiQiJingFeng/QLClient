local csbPath = "ui/csb/Club/UIClubCreate.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UIClubCreate = class("UIClubCreate", super, function() return cc.CSLoader:createNode(csbPath) end)

--[[
    -- 亲友圈创建
]]


function UIClubCreate:ctor(parent)
    self._parent = parent
    self:setPosition(0, 0)
    self._weChat = ""

    self._btnCreate = seekNodeByName(self, "Button_sqjl_Clublist_0", "ccui.Button") -- 创建
    self._textIputCode = seekNodeByName(self, "TextField_sr_ClubCreat", "ccui.TextField") -- 输入您想创建的亲友圈昵称
    self._btnClone = seekNodeByName(self, "Button_sqjl_Clublist_0_0", "ccui.Button") -- 复制
    self._textWeChat = seekNodeByName(self, "Text_Worning_CreateRoom", "ccui.Text") -- 微信号
    -- self._panelPlacard = seekNodeByName(self, "Panel_3", "ccui.Layout") -- 公告

    self:_registerCallBack()
end

function UIClubCreate:_registerCallBack()
    bindEventCallBack(self._btnCreate, handler(self, self._onBtnCreateClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClone, handler(self, self._onBtnCloneClick), ccui.TouchEventType.ended)

    -- bindEventCallBack(self._panelPlacard, handler(self, self._onPlacardClick), ccui.TouchEventType.ended)
end

function UIClubCreate:show()
    self:setVisible(true)
    self._textIputCode:setString("")

    --self._textIputCode:setPlaceHolderColor(config.ColorConfig.InputField.Common.InputHolder)
    self._textIputCode:setTextColor(cc.c4b(151, 86, 31, 255))

    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    self._weChat = MultiArea.getWeChat(areaId)
    self._textWeChat:setString(string.format("了解更多详情请添加微信:%s", self._weChat))

    game.service.LoginService.getInstance():addEventListener("EVENT_BINDPHONE_CHANGED", handler(self, self._onCreateClub), self)
end

function UIClubCreate:_onBtnCloneClick()
    if self._weChat ~= "" and game.plugin.Runtime.setClipboard(tostring(self._weChat)) == true then
		game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    end
end

function UIClubCreate:_onBtnCreateClick()
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

function UIClubCreate:_onCreateClub()
    local clubName = self._textIputCode:getString()
    -- 默认头像
    game.service.club.ClubService.getInstance():getClubMemberService():sendCCLCreateClubREQ(clubName, ClubConstant:getClubDefaultIconName())
end

function UIClubCreate:_onPlacardClick()
    game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBCREATE_STRING_100, {"我同意"})
end

function UIClubCreate:hide()
    game.service.LoginService.getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIClubCreate
