local csbPath = "ui/csb/Club/UIClubActivityCreate.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    创建活动界面

]]

local UIClubActivityCreate = class("UIClubActivityCreate", super, function() return cc.CSLoader:createNode(csbPath) end)

function UIClubActivityCreate:ctor(parent)
    self._parent = parent

    self._activityTypes = {}
    self._clubId = nil

    self._activityType = nil

    self._startTime = nil
    self._endTime = nil

    self._textIputActivityName = seekNodeByName(self, "TextField_ActivityName", "ccui.TextField") -- 活动名称
    self._btnSetActivities = seekNodeByName(self, "Button_Activity_Done", "ccui.Button") -- 设置活动按钮

    -- 时间设置
    self._btnStartTime = seekNodeByName(self, "Button_Start_Time", "ccui.Button") -- 起始时间
    self._btnEndTime = seekNodeByName(self, "Button_End_Time", "ccui.Button") -- 结束时间
    self._textStartTime = seekNodeByName(self._btnStartTime, "Text_quarry_start_time", "ccui.Text")
    self._textEndTime = seekNodeByName(self._btnEndTime, "Text_quarry_start_time", "ccui.Text")

    --邀请活动显示
    self._textInviteReadme = seekNodeByName(self, "Text_Activity_Readme_0", "ccui.Text")
    self._textInviteReadme:setVisible(false)
    self._textInviteNum = seekNodeByName(self, "TextField_ActivityName_0", "ccui.TextField")
    self._textInviteNum:setVisible(false)
    self._imageBack = seekNodeByName(self, "Image_1", "ccui.ImageView")
    self._imageBack:setVisible(false)


    
    bindEventCallBack(self._btnStartTime, handler(self, self._setActivityTiem), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEndTime, handler(self, self._setActivityTiem), ccui.TouchEventType.ended)

    bindEventCallBack(self._btnSetActivities, handler(self, self._onBtnSetActivitiesClick), ccui.TouchEventType.ended)

    --用于输入控制，保证只输入数字,bindEventCallback只提供点击事件方法，不能在这使用
    self._textInviteNum:addEventListener(handler(self,self._onTextChange))
end

function UIClubActivityCreate:show(clubId, data)
    self:setVisible(true)
    self._clubId = clubId

    self._textIputActivityName:setPlaceHolderColor(config.ColorConfig.InputField.Common.InputHolder)
    self._textIputActivityName:setTextColor(config.ColorConfig.InputField.Common.inputTextColor)

    self._textInviteNum:setPlaceHolderColor(config.ColorConfig.InputField.Common.InputHolder)
    self._textInviteNum:setTextColor(config.ColorConfig.InputField.Common.inputTextColor)

    if self._parent._saveTime[ClubConstant:getTimeType().END] ~= nil then
        self._endTime = os.time{
            year = self._parent._saveTime[ClubConstant:getTimeType().END].year,
            month = self._parent._saveTime[ClubConstant:getTimeType().END].month,
            day = self._parent._saveTime[ClubConstant:getTimeType().END].day,
            hour = self._parent._saveTime[ClubConstant:getTimeType().END].hour,
            min = self._parent._saveTime[ClubConstant:getTimeType().END].min
        }

        self._textEndTime:setString(os.date("%Y-%m-%d %H:%M", self._endTime))
    end

    if self._parent._saveTime[ClubConstant:getTimeType().START] ~= nil then
        self._startTime = os.time{
            year = self._parent._saveTime[ClubConstant:getTimeType().START].year,
            month = self._parent._saveTime[ClubConstant:getTimeType().START].month,
            day = self._parent._saveTime[ClubConstant:getTimeType().START].day,
            hour = self._parent._saveTime[ClubConstant:getTimeType().START].hour,
            min = self._parent._saveTime[ClubConstant:getTimeType().START].min
        }

        self._textStartTime:setString(os.date("%Y-%m-%d %H:%M", self._startTime))
    end
    
    self:_initActivityType()
end

-- 初始化活动类型选项
function UIClubActivityCreate:_initActivityType()
    -- 活动类型
    self._activityTypes = {}
    local activityType, index = ClubConstant:getClubActivityType()
    for i = 1, 4 do
        local node = seekNodeByName(self, "Activity_Type_" .. i, "ccui.CheckBox")

        local isSelected = false
        node:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = node:isSelected()
			elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then	
				self:_onItemTypeClicked(index[i])
				node:setSelected(true)
                self._textInviteReadme:setVisible(i == 4) 
                self._textInviteNum:setVisible(i == 4)
                self._imageBack:setVisible(i == 4)
          	elseif eventType == ccui.TouchEventType.canceled then
                node:setSelected(isSelected)
            end
        end)
        self._activityTypes[index[i]] = node
    end

    self:_onItemTypeClicked(self._activityType or index[1])
end

function UIClubActivityCreate:_onItemTypeClicked(index)
    for k,v in pairs(self._activityTypes) do
        if k == index then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end
    self._activityType = index
end

function UIClubActivityCreate:_setActivityTiem(sender)
    -- 记录一下是结束时间还是开始时间
    local type = ClubConstant:getTimeType().END
    if sender:getName() == "Button_Start_Time" then
        type = ClubConstant:getTimeType().START
    end

    -- 显示选择时间界面
    if self._parent._uiElemList["UIClubActivityTime"] == nil then
        local clz = require("app.game.ui.club.activity.UIClubActivityTime")
        local ui = clz.new(self)
        self._parent._uiElemList["UIClubActivityTime"] = ui
        self._parent._node:addChild(ui)
    end
    self._parent:_hideAllPages()
    self._parent._uiElemList["UIClubActivityTime"]:show(type, self._clubId)
end

-- 向服务器发送活动信息
function UIClubActivityCreate:_onBtnSetActivitiesClick()
    if self._textIputActivityName:getString() == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入活动名称")
        return
    end
    if self._startTime == nil or self._endTime == nil then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的活动时间")
        return
    end
    local clubActivityType = ClubConstant:getClubActivityType()
    if self._activityType == clubActivityType.InvitePlayers and self._textInviteNum:getString() == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入牌局数")
        return
    end

    local activityType, index = ClubConstant:getClubActivityType()
    print('number~~~~~~~~~~~~~~~~~~~',tonumber(self._textInviteNum:getString()))
    
    game.service.club.ClubService.getInstance():getClubActivityService():sendCCLAddManagerActivityREQ(
        self._clubId,
        self._textIputActivityName:getString(),
        index[self._activityType],
        self._startTime * 1000,
        self._endTime * 1000,
        tonumber(self._textInviteNum:getString())
    )

    -- 清空缓存信息
    self._parent._saveTime = {}
    self._startTime = nil
    self._endTime = nil
    self._textIputActivityName:setString("")
    local activityType, index = ClubConstant:getClubActivityType()
    self:_onItemTypeClicked(index[1])

    self._textEndTime:setString("请选择结束时间")
    self._textStartTime:setString("请选择开始时间")
end

function UIClubActivityCreate:hide()
    self._activityTypes = {}
    self:setVisible(false)
end

--保证输入框只输入正整数
function UIClubActivityCreate:_onTextChange(textField,eventType)
    if eventType == ccui.TextFiledEventType.insert_text then
        local str = textField:getString()
        if string.len(str) > 2 then
            str = string.sub(str, 1, 2)
        end
        local v = 0        
        for i = 1,string.len(str) do
            if string.byte(str,i) < string.byte('0') or string.byte(str,i) > string.byte('9') then
                break
            end
            v = i
        end
        if v == 0 then
            str = '1'
        else
            str = string.sub(str, 1, v)
        end
        if str == '0' then
            str = '1'
        end
    
        textField:setString(str)
    end
end


return UIClubActivityCreate
 