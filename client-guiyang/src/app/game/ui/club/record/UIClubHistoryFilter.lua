local csbPath = "ui/csb/Club/UIClubHistoryFind.csb"
local super = require("app.game.ui.UIBase")
local UIClubHistoryFilter = class("UIClubHistoryFilter", super, function() return kod.LoadCSBNode(csbPath) end)
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")
function UIClubHistoryFilter:ctor()
end

function UIClubHistoryFilter:_onTextChanged(sender,eventType)
    -- 统计战绩页面更改条件弹窗分数输入框点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Zhanji_Change_shurukuang);

    if eventType == 0  then
        if device.platform == "ios" then
            self._pannel:setPositionPercent(cc.p(0.5,0.7))
        end
        if sender:getString() == "" then
            sender:setString(" ")
        end
        sender:setString("")
    end
    if eventType == 1 then
        if device.platform == "ios" then 
            self._pannel:setPositionPercent(cc.p(0.5,0.5))
        end
        if sender:getString() == " " then       
            sender:setString("")
        end
    end
    if eventType== 2 or eventType==3 then
        local str = sender:getString()
        str=string.trim(str)
        local sTable = kod.util.String.stringToTable(str)
        local roomNumber = ""
        for i=1,#sTable do
            if tonumber(sTable[i]) ~= nil then
                -- 开头输入时0的情况监测处理
                if i==1 and sTable[i]=='0' and #sTable>1 then
                else
                    roomNumber = roomNumber .. sTable[i]
                end  
            else
                game.ui.UIMessageTipsMgr.getInstance():showTips('只能输入数字')
            end
        end
        sender:setString(roomNumber)
    end
end

function UIClubHistoryFilter:init()
    self._btnClose              = seekNodeByName(self, "Button_Close",      "ccui.Button")
    self._dateChange          = seekNodeByName(self, "Button_select",      "ccui.Button") 
    self._btnConfirm          = seekNodeByName(self, "Button_Write",      "ccui.Button")  
    self._btnCancel          = seekNodeByName(self, "Button_NotWrite",      "ccui.Button")
    self._pannel = seekNodeByName(self, "Panel_Node", "ccui.Layout")

   	self._textScore = seekNodeByName(self, "TextField_Score", "ccui.TextField")
    self._textScore:addEventListener(handler(self, self._onTextChanged))
    self._textDate = seekNodeByName(self, "Text_Date", "ccui.Text")
    self._disband = seekNodeByName(self, "CheckBox_disband", "ccui.CheckBox")
    self:_registerCallBack()
end

function UIClubHistoryFilter:onHide()
    UIManager.getInstance():hide('UIClubHistoryDateSet')
end

function UIClubHistoryFilter:_onUIHide()
	UIManager.getInstance():hide('UIClubHistoryFilter')
end

function UIClubHistoryFilter:_onDateChange()
    -- 统计战绩页面更改条件弹窗更改日期按钮点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Zhanji_Change_riqi);

	UIManager.getInstance():show('UIClubHistoryDateSet',self._querytime)
end

function UIClubHistoryFilter:_onBtnConfirm()
    local minscore = self._textScore:getString()
    if minscore == "" then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入大赢家分")
        return
    end
    if tonumber(minscore)>999 then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("输入大赢家分不能超过999")
        self._textScore:setString('0')
        return
    end
    if self._callBack ~= nil then
        self._callBack(self._querytime, minscore, self._disband:isSelected())
        self:_onUIHide()
    end
end

function UIClubHistoryFilter:_registerCallBack()
    bindEventCallBack(self._btnClose, handler(self, self._onUIHide), ccui.TouchEventType.ended)
    bindEventCallBack(self._dateChange, handler(self, self._onDateChange), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnConfirm, handler(self, self._onBtnConfirm), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onUIHide), ccui.TouchEventType.ended)
    -- bindEventCallBack(self._disband, handler(self, self._onBtnDisbandClick), ccui.TouchEventType.ended)
end

-- function UIClubHistoryFilter:_onBtnDisbandClick()
--     self._checkDisband = self._disband:isSelected()
-- end

function UIClubHistoryFilter:_onClickFilterChange()
    local time = self._textDate:getString()
    UIManager.getInstance():show('UIClubHistoryFilter', time)
end

function UIClubHistoryFilter:_setTime(time)
    local date = os.date("%Y-%m-%d", time)
    self._querytime=time
    self._textDate:setString(date)
end

function UIClubHistoryFilter:onShow(querytime, minscore, permissionDisBand, callBack)
    --读取颜色值
	local CList = GainLabelColorUtil.new(self , 1 , 1) 
    -- 设置输入框的颜色
    --self._textScore:setPlaceHolderColor(cc.c4b(CList.colors[1].r,CList.colors[1].g,CList.colors[1].b,255))
    self._textScore:setTextColor(cc.c4b(151, 86, 31, 255))

    self._minscore = minscore
    self._querytime = querytime
    self:_setTime(self._querytime)
    self._textScore:setString(minscore)
    self._callBack = callBack

    self._disband:setSelected(false)
    self._disband:setVisible(permissionDisBand)

    self:playAnimation_Scale()
end

function UIClubHistoryFilter:needBlackMask()
	return true;
end

function UIClubHistoryFilter:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubHistoryFilter:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

return UIClubHistoryFilter