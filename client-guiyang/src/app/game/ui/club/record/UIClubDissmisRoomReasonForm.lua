local csbPath = "ui/csb/Club/UIClubDissmisRoomReasonForm.csb"
local super = require("app.game.ui.UIBase")

local UIClubDissmisRoomReasonForm = class("UIClubDissmisRoomReasonForm", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    解散房间原因列表
        为了地区统一化，只需要在各自地区配置文件中配置即可
        如果没有配置在此文件中会默认调用贵阳的配置
]]

-- 由于UI的原因每行只能配置三个原因
local COUNT = 3

function UIClubDissmisRoomReasonForm:ctor()
    self._reasonForm = {}
end

function UIClubDissmisRoomReasonForm:init()
    self._textPhone = seekNodeByName(self, "TextField_phone", "ccui.TextField") -- 手机号
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭
    self._btnDisband = seekNodeByName(self, "Button_disband", "ccui.Button") -- 解散

    self._listReasonForm = seekNodeByName(self, "ListView_reasonForm", "ccui.ListView")
    self._listReasonForm:setScrollBarEnabled(false)

    -- 选项item
    self._ItemReason = ccui.Helper:seekNodeByName(self._listReasonForm, "Panel_reason")
    self._ItemReason:removeFromParent(false)
    self:addChild(self._ItemReason)
    self._ItemReason:setVisible(false)

    -- 文字item
     self._ItemType = ccui.Helper:seekNodeByName(self._listReasonForm, "Panel_type")
    self._ItemType:removeFromParent(false)
    self:addChild(self._ItemType)
    self._ItemType:setVisible(false)

    bindEventCallBack(self._btnClose, handler(self, self._onCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDisband, handler(self, self._onDisbandClick), ccui.TouchEventType.ended)
end

function UIClubDissmisRoomReasonForm:onShow()
    self._textPhone:setTextColor(cc.c4b(151, 86, 31, 255))
    self._textPhone:setString("")

    self:_initUI()
end

-- 初始化UI
function UIClubDissmisRoomReasonForm:_initUI()
   self._listReasonForm:removeAllChildren()
    -- 读取地区解散房间原因列表
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local reasonForm = MultiArea.getReasonForm(areaId)
    Macro.assertTrue(#reasonForm == 0, "Dissolution reason configuration table error")

    -- 判断是否为统一类型
    local type = ""
    local reasons = {}

    for k, reasonInfo in ipairs(reasonForm) do
        -- 不是统一类型的情况 或者 当满足每行个数时
        if (type ~= "" and type ~= reasonInfo.type and #reasons > 0) or (#reasons == COUNT) then 
            self:_initReasonItem(reasons)
            reasons = {}
        end
        
        if reasonInfo.id == 0 then
            local node = self._ItemType:clone()
            self._listReasonForm:addChild(node)
            node:setVisible(true)
            local text = ccui.Helper:seekNodeByName(node, "Text_content")
            text:setString(reasonInfo.name)
        else
            table.insert(reasons, reasonInfo)
        end

        type = reasonInfo.type
    end

    if #reasons > 0 then
        self:_initReasonItem(reasons)
        reasons = {}
    end
end

-- 初始化原因item
function UIClubDissmisRoomReasonForm:_initReasonItem(reasonInfo)
    local node = self._ItemReason:clone()
    self._listReasonForm:addChild(node)
    node:setVisible(true)
    for i = 1, COUNT do
        local checkBox = ccui.Helper:seekNodeByName(node, "CheckBox_reason_" .. i)
        local text = ccui.Helper:seekNodeByName(node, "Text_reason_" .. i)
        checkBox:setVisible(i <= #reasonInfo)
        text:setVisible(i <= #reasonInfo)
        
        if i <= #reasonInfo then
            local isSelected = false
            checkBox:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    isSelected = checkBox:isSelected()
                elseif eventType == ccui.TouchEventType.moved then
                elseif eventType == ccui.TouchEventType.ended then
                    self:_onClickCheckBox(sender, reasonInfo[i])
                elseif eventType == ccui.TouchEventType.canceled then
                    checkBox:setSelected(isSelected)
                end
            end)
        
            text:setString(reasonInfo[i].name)
        end
    end
end

function UIClubDissmisRoomReasonForm:_onClickCheckBox(sender, data)
    if sender:isSelected() then
        -- 产品要求只能选三个原因
        if #self._reasonForm == 3 then
            sender:setSelected(false)
            game.ui.UIMessageTipsMgr.getInstance():showTips("最多选择三个解散原因")
        else
            table.insert(self._reasonForm, data.id)
        end
    else
        -- 当取消选中时要从本地的存储中删除
        table.removebyvalue(self._reasonForm, data.id)
    end
end

function UIClubDissmisRoomReasonForm:_onDisbandClick()
    if #self._reasonForm > 0 then
        local loginPhoneService = game.service.LoginService:getInstance():getLoginPhoneService()
        if self._textPhone:getString() ~= "" and loginPhoneService:isVerificationPhone(self._textPhone:getString()) == false then
            game.ui.UIMessageTipsMgr.getInstance():showTips("请输出正确的手机号")
            return
        end
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Determining_Dissolution)
        game.service.RoomService:getInstance():sendCBStartVoteDestroyREQ(self._textPhone:getString(), self._reasonForm)
        self:_onCloseClick()
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("请至少选择一个解散原因,我们会努力改进")
    end
end

function UIClubDissmisRoomReasonForm:_onCloseClick()
    UIManager:getInstance():destroy("UIClubDissmisRoomReasonForm")
end


function UIClubDissmisRoomReasonForm:onHide()
end

function UIClubDissmisRoomReasonForm:needBlackMask()
	return true
end

function UIClubDissmisRoomReasonForm:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubDissmisRoomReasonForm:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubDissmisRoomReasonForm