local ScrollText = require("app.game.util.ScrollText")
local csbPath = "ui/csb/Club/UIClubGroupCreate.csb"
local UIClubGroupCreate = class("UIClubGroupCreate", function() return cc.CSLoader:createNode(csbPath) end)

--[[
    经理创建小组界面
]]

function UIClubGroupCreate:ctor(parent)
    self._parent = parent

    self._textInputId = seekNodeByName(self, "TextField_id", "ccui.TextField")
    self._textInputName = seekNodeByName(self, "TextField_name", "ccui.TextField")
    self._textInputScore = seekNodeByName(self, "TextField_score", "ccui.TextField")
    self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text")
    self._textTips = ScrollText.new(self._textTips, 28, true)

    self._btnOk = seekNodeByName(self, "Button_ok", "ccui.Button")
    self._btnDelete = seekNodeByName(self, "Button_delete", "ccui.Button")
    self._btnCreate = seekNodeByName(self, "Button_create", "ccui.Button")
    self._btnChoice = seekNodeByName(self, "Button_Choice", "ccui.Button")

    self._imgMask = seekNodeByName(self, "Image_mask", "ccui.ImageView")

    self._textInputScore:addEventListener(handler(self, self._onChangedNumber))
    self._textInputId:addEventListener(handler(self, self._onChangedNumber))

    bindEventCallBack(self._btnOk, handler(self, self._onClickOk), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDelete, handler(self, self._onClickDelete), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCreate, handler(self, self._onClickCreate), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnChoice, handler(self, self._onClickChoice), ccui.TouchEventType.ended)
end

function UIClubGroupCreate:show(groupInfo)
    --self._textInputId:setPlaceHolderColor(config.ColorConfig.InputField.Common.InputHolder)
    self._textInputId:setTextColor(cc.c4b(151, 86, 31, 255))

    --self._textInputName:setPlaceHolderColor(config.ColorConfig.InputField.Common.InputHolder)
    self._textInputName:setTextColor(cc.c4b(151, 86, 31, 255))

    --self._textInputScore:setPlaceHolderColor(config.ColorConfig.InputField.Common.InputHolder)
    self._textInputScore:setTextColor(cc.c4b(151, 86, 31, 255))


    self:setVisible(true)
    local text = [[%s搭档:
1.两个群主可以将各自的%s成员汇集到同一个%s切磋牌技;
2.你设置的搭档可以将他%s的成员一键导入进你的%s;
3.搭档可以查看自己成员的牌局数和大赢家数，并且可以查询战绩;
4.解除搭档后，搭档以及他导入的成员依然是%s成员;
5.每个%s最多同时存在5个搭档。
    ]]
    self._textTips:setString(string.format(text, config.STRING.COMMON, config.STRING.COMMON, config.STRING.COMMON, config.STRING.COMMON, config.STRING.COMMON, config.STRING.COMMON, config.STRING.COMMON))

    self._groupInfo = groupInfo
    self:_initInputInfo()
    self:_initUI()
    

    game.service.club.ClubService.getInstance():getClubGroupService():addEventListener(
        "EVENT_CLUB_GROUP_INFO_CHAGE", 
        handler(self, self._updataClubGroupInfo),
        self
    )

    game.service.club.ClubService.getInstance():getClubGroupService():addEventListener(
        "EVENT_CLUB_GROUP_LEADER_INFO",
        handler(self, self._initLeaderInfo),
        self
    )
end

function UIClubGroupCreate:_initUI()
    self._btnOk:setVisible(self._groupInfo ~= nil)
    self._btnDelete:setVisible(self._groupInfo ~= nil)
    self._btnCreate:setVisible(self._groupInfo == nil)
    self._btnChoice:setVisible(self._groupInfo == nil)
    self._textInputId:setTouchEnabled(self._groupInfo == nil)
    self._imgMask:setVisible(self._groupInfo ~= nil)
    if self._groupInfo ~= nil then
        self._textInputId:setString(self._groupInfo.leaderId)
        self._textInputName:setString(self._groupInfo.groupName)
        self._textInputScore:setString(self._groupInfo.minWinScore)
    end
end

function UIClubGroupCreate:_initInputInfo()
    self._textInputName:setString("")
    self._textInputId:setString("")
    self._textInputScore:setString("")
    self._textInputId:setTouchEnabled(false)
end

-- 修改信息
function UIClubGroupCreate:_onClickOk()
    game.service.club.ClubService.getInstance():getClubGroupService():sendCCLModifyClubGroupREQ(
        self._parent:getClubId(),
        self._groupInfo.groupId,
        self._textInputName:getString(),
        tonumber(self._textInputScore:getString()) or 0
    )
end

-- 删除
function UIClubGroupCreate:_onClickDelete()
    local text = string.format("解除搭档后，搭档及所属成员将成为%s内的普通成员，是否继续执行解除操作？", config.STRING.COMMON)
    game.ui.UIMessageBoxMgr.getInstance():show(
        text,
        {"确定", "取消"},
        function()
            game.service.club.ClubService.getInstance():getClubGroupService():sendCCLDeleteClubGroupREQ(
                self._parent:getClubId(),
                self._groupInfo.groupId
            )
        end,
        function()
        end
    )    
end

-- 创建
function UIClubGroupCreate:_onClickCreate()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Create_Group_Btn)

    if self._textInputName:getString() == "" or tonumber(self._textInputId:getString()) == nil or tonumber(self._textInputScore:getString()) == nil then
        game.ui.UIMessageTipsMgr.getInstance():showTips("完善信息后可添加搭档")
        return
    end

    game.service.club.ClubService.getInstance():getClubGroupService():sendCCLCheckCreateGroupREQ(
        self._parent:getClubId(),
        self._textInputName:getString(),
        tonumber(self._textInputId:getString()),
        tonumber(self._textInputScore:getString()) or 0
    )
end

-- 选择搭档
function UIClubGroupCreate:_onClickChoice()
    UIManager:getInstance():show("UIClubGroupChoice", self._parent:getClubId(), "create", "", "", function(playerId)
        self._textInputId:setString(playerId or "")
    end)
end

function UIClubGroupCreate:_initLeaderInfo(event)
    UIManager:getInstance():show("UIClubGroupLeaderInfo", event.playerInfo)
end

function UIClubGroupCreate:_updataClubGroupInfo()
    self._parent:updataBookMark(self._parent:getGroupType()[1])
end

function UIClubGroupCreate:hide()
    game.service.club.ClubService.getInstance():getClubGroupService():removeEventListenersByTag(self)
    
    self:setVisible(false)
end

-- 判断是不是输入的数字
function UIClubGroupCreate:_onChangedNumber(sender, eventType)
    if eventType== 2 or eventType==3 then
        local str = sender:getString()
        str=string.trim(str)
        local sTable = kod.util.String.stringToTable(str)
        local number = ""
        for i=1,#sTable do
            if tonumber(sTable[i]) ~= nil then
                number = number .. sTable[i]
            else
                game.ui.UIMessageTipsMgr.getInstance():showTips('只能输入数字')
            end
        end
        if sender:getName() == "TextField_score" and number ~= "" and tonumber(number) >= 200 then
            number = 200
        end
        sender:setString(number)
    end
end

return UIClubGroupCreate