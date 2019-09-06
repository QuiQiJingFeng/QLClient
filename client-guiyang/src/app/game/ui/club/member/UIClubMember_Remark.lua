local csbPath = "ui/csb/Club/UIClubMember_Remark.csb"
local super = require("app.game.ui.UIBase")

--[[
    玩家备注信息编辑界面
]]

local UIClubMember_Remark = class("UIClubMember_Remark", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubMember_Remark:ctor()
	self._textFieldRemark = nil -- 备注输入框
	self._btnDefine = nil -- 确定
	self._btnCancel = nil -- 取消
end

function UIClubMember_Remark:init()
	self._btnDefine = seekNodeByName(self, "Button_define", "ccui.Button")
	self._btnCancel = seekNodeByName(self, "Button_cancel", "ccui.Button")
    self._textFieldRemark = seekNodeByName(self, "TextField_remark", "ccui.TextField")
	
    bindEventCallBack(self._btnDefine, handler(self, self._onClickDefine), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
	
end

function UIClubMember_Remark:onShow(data)
    self._data = data
end

function UIClubMember_Remark:_onClickDefine()
    game.service.club.ClubService.getInstance():getClubMemberService():sendCCLModifyMemberRemarkREQ(self._data.clubId, self._data.roleId, self._textFieldRemark:getString())
    self:_onClickCancel()
end

function UIClubMember_Remark:_onClickCancel()
    UIManager:getInstance():destroy("UIClubMember_Remark")
end

function UIClubMember_Remark:onHide()
    -- 键盘自动隐藏
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)
end

function UIClubMember_Remark:needBlackMask()
	return true
end

function UIClubMember_Remark:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubMember_Remark:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubMember_Remark