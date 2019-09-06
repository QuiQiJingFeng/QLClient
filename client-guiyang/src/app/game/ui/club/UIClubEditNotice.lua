local csbPath = "ui/csb/Club/UIClubEditNotice.csb"
local super = require("app.game.ui.UIBase")

local UIClubEditNotice = class("UIClubEditNotice", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    亲友圈公告编辑界面
]]
function UIClubEditNotice:ctor()
    self._btnOk = nil -- 确定
    self._textInput = nil -- 输入框
    self._clubId = nil -- 亲友圈Id
    self._btnQuit = nil -- 退出
end

function UIClubEditNotice:init()
    self._textInput = seekNodeByName(self, "TextField_z_Clubsr", "ccui.TextField")
    self._btnOk = seekNodeByName(self, "Btn_qd_Clubsr", "ccui.Button")
     self._btnQuit = seekNodeByName(self, "Button_6", "ccui.Button")

    bindEventCallBack(self._btnOk, handler(self, self._onBtnOKClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
end

function UIClubEditNotice:onShow(clubId, clubNotice)
    self._clubId = clubId
    self._clubNotice = clubNotice

    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)

    if club.data == nil then
        return
    end

    -- 设置输入框的颜色
	--self._textInput:setPlaceHolderColor(cc.c4b(255, 255, 255, 255))
    self._textInput:setTextColor(cc.c4b(151, 86, 31, 255))
    self._textInput:setString(club.data.clubNotice)
end

function UIClubEditNotice:_onBtnOKClick()
    -- 亲友圈公告内容没有改变就不像服务器发送请求
    if self._clubNotice == self._textInput:getString() then
        self:_onBtnQuitClick()
        return
    end

    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)

    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubNoticeREQ(self._clubId, self._textInput:getString())
end

function UIClubEditNotice:_onBtnQuitClick()
    UIManager:getInstance():hide("UIClubEditNotice")
end

function UIClubEditNotice:onHide()
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)
end


function UIClubEditNotice:needBlackMask()
	return true
end

function UIClubEditNotice:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubEditNotice:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubEditNotice