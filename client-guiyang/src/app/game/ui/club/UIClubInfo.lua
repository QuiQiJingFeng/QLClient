local csbPath = "ui/csb/Club/UIClubInfo.csb"
local super = require("app.game.ui.UIBase")
local room = require("app.game.ui.RoomSettingHelper")
local ScrollText = require("app.game.util.ScrollText")
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local UIClubInfo = class("UIClubInfo", super, function() return kod.LoadCSBNode(csbPath) end)

--[[    亲友圈信息界面
        复制邀请码
]]
function UIClubInfo:ctor()
    self._textClubName            = nil
    self._textClubId                = nil
    self._tetxTime                = nil
    self._textInvitationCode        = nil
    self._btnCopy                = nil
    self._textManagerId            = nil
    self._textManagerName        = nil
    self._textClubGamePlay        = nil
    self._imgClubIcon            = nil
    self._invitationCode            = nil       -- 记录一下亲友圈邀请码
    self._bInitList                = false
end

function UIClubInfo:init()
    self._panelClub                = seekNodeByName(self, "Panel_Clubxx",                "ccui.Layout")          -- 编辑节点
    self._beginPosY_panelClub    = self._panelClub:getPositionY()
    self._textClubName            = seekNodeByName(self, "Text_name_Clubxx",            "ccui.Text")            -- 亲友圈名称
    self._textClubId                = seekNodeByName(self, "Text_ID_Clubxx",                "ccui.Text")            -- 亲友圈Id
    self._tetxTime                = seekNodeByName(self, "Text_ID_Clubxx_0",            "ccui.Text")            -- 亲友圈创建时间
    self._textInvitationCode        = seekNodeByName(self, "Text_1",                        "ccui.Text")            -- 亲友圈邀请码
    self._btnCopy                = seekNodeByName(self, "Btn_history_Clubxx",            "ccui.Button")          -- 复制按钮
    self._textManagerId            = seekNodeByName(self, "Text_lin3_Clubxx",            "ccui.Text")            -- 群主Id
    self._textManagerName        = seekNodeByName(self, "Text_lin2_Clubxx",            "ccui.Text")            -- 群主昵称
    self._imgClubIcon            = seekNodeByName(self, "Image_face_Clubxx",            "ccui.ImageView")       -- 亲友圈图标
    self._btnEdit                = seekNodeByName(self, "Btn_history_Clubxx_0",        "ccui.Button")          -- 复制按钮
    self._btnSave                = seekNodeByName(self, "Button_1_Clubinfo",            "ccui.Button")          -- 保存按钮
    self._panelMain                = seekNodeByName(self, "Panel_Clubxx",                "ccui.Layout")          -- 俱乐部信息节点
    self._panelEdit                = seekNodeByName(self, "Panel_10",                    "ccui.Layout")          -- 编辑节点
    self._beginPosY_panelEdit    = self._panelEdit:getPositionY()
    self._textFileName            = seekNodeByName(self, "TextField_1",                "ccui.TextField")       -- 编辑名称
    self._listClubIcon            = seekNodeByName(self, "ListView_list_Clubinfo",        "ccui.ListView")        -- 俱乐部头像框
    self._textPresetGameplays    = seekNodeByName(self, "Text_lin2_Clubxx_0",            "ccui.Text")            -- 一键开房的玩法

    self._textPresetGameplays = ScrollText.new(self._textPresetGameplays, 24, true)
    self:_registerCallBack()

end

-- 点击事件注册
function UIClubInfo:_registerCallBack()
    bindEventCallBack(self._btnCopy,        handler(self, self._onBtnCopyClick),        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEdit,        handler(self, self._onBtnEdit),            ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSave,        handler(self, self._onBtnSave),            ccui.TouchEventType.ended)
    self._textFileName:addEventListener(handler(self, self._onEventSearch))
end

function UIClubInfo:onShow(clubId)
    self._clubId = clubId

    local clubService = game.service.club.ClubService.getInstance()

    --self._textFileName:setPlaceHolderColor(config.ColorConfig.InputField.White.InputHolder)
    self._textFileName:setTextColor(cc.c4b(151, 86, 31, 255))

    -- 亲友圈信息
    self._textClubName:setString(clubService:getInterceptString(clubService:getClubName(clubId), 8))
    self._textClubId:setString(string.format(config.STRING.UICLUBINFO_STRING_100, tostring(clubId)))
    self._textInvitationCode:setString(string.format("邀请码:%s", clubService:getClubInvitationCode(clubId)))
    self._textManagerId:setString(string.format("群主ID:%s", clubService:getClubManagerRoleId(clubId)))
    self._textManagerName:setString(string.format("群主昵称:%s", clubService:getInterceptString(clubService:getClubManagerName(clubId), 8)))
    self._tetxTime:setString(string.format("创建于%s", os.date("%Y-%m-%d", clubService:getClubCreateTime(clubId) / 1000)))
    self._imgClubIcon:loadTexture(clubService:getClubIcon(clubService:getClubIconName(clubId)))

    self._invitationCode = clubService:getClubInvitationCode(clubId)

    self:_initClubIconList()
    self._panelEdit:setVisible(false)

    local presetGameplays = clubService:getPresetGameplays(clubId)
    if #presetGameplays > 0 then
        local roomSettingInfo = RoomSettingInfo.new(presetGameplays[1].gameplays, presetGameplays[1].roundType)
        local zhArray = roomSettingInfo:getZHArray()
        self._textPresetGameplays:setString(string.format("一键开房:%s", table.concat(zhArray, '、')))
    end
    self._textPresetGameplays:setVisible(#presetGameplays > 0)

    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    self._btnEdit:setVisible(clubService:playerIsPermissions(self._clubId, localRoleId))


    local clubManagerService = game.service.club.ClubService.getInstance():getClubManagerService()
    clubManagerService:addEventListener("EVENT_CLUB_INFO_CHANGED", handler(self, self._onClubInfoChanged), self)
end

-- 亲友圈信息变化
function UIClubInfo:_onClubInfoChanged(event)
    if event.clubId ~= self._clubId then
        return
    end
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    self._imgClubIcon:loadTexture(clubService:getClubIcon(clubService:getClubIconName(self._clubId)))
    self._textClubName:setString(clubService:getInterceptString(clubService:getClubName(self._clubId), 8))
    -- self._btnRedPacket:setVisible(club.hasActivity)
    self._panelEdit:setVisible(false)
end

function UIClubInfo:_onBtnCopyClick()
    if self._invitationCode ~= nil and game.plugin.Runtime.setClipboard(tostring(self._invitationCode)) == true then
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    end
end

function UIClubInfo:onHide()
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
end

function UIClubInfo:needBlackMask()
    return true
end

function UIClubInfo:closeWhenClickMask()
    return true
end

function UIClubInfo:_onBtnSave(sender)
    local clubService = game.service.club.ClubService.getInstance()
    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubInfoREQ(self._clubId, self._textFileName:getString(), self._selectIcon)
    clubService:tryQueryDirtyClubData(self._clubId)
    self._panelEdit:setVisible(false)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubInfo:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

function UIClubInfo:_onBtnEdit()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Edit_Click);
    self._panelEdit:setVisible(true)
end

--初始化俱乐部头像列表，只需要初始化一次即可，后面的刷新选中框就可以了
function UIClubInfo:_initClubIconList()
    if self._bInitList then
        self:_refreshIconAndName()
        return
    end
    local listItem = self._listClubIcon:getChildByTag(246)
    -- 清空列表
    self._btnCheckList = {}

    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)

    for i = 1, 5 do
        local node = listItem
        if i ~= 1 then
            node = listItem:clone()
            self._listClubIcon:pushBackCustomItem(node)
        end
        node:setVisible(true)
        node:setTag(i)


        local imageIcon = seekNodeByName(node, "Image_t_1_list_Clubinfo", "ccui.ImageView")
        local clubIconName = string.format("Club_Icon_%d", i)
        imageIcon:loadTexture(clubService:getClubIcon(clubIconName))

        local imageSelect = seekNodeByName(node, "Image_m_1_list_Clubinfo", "ccui.ImageView")
        imageSelect:setVisible(clubIconName == club.data.clubIcon)


        bindEventCallBack(node, handler(self, self._onClickIconItem), ccui.TouchEventType.ended)

        bindEventCallBack(node,
        function(sender)
            for _, item in pairs(self._listClubIcon:getChildren()) do
                item:getChildByName("Image_m_1_list_Clubinfo"):setVisible(false)
            end
            sender:getChildByName("Image_m_1_list_Clubinfo"):setVisible(true)
            self._selectIcon = string.format("Club_Icon_%d", i)
            self._imgClubIcon:loadTexture(clubService:getClubIcon(self._selectIcon))
        end,
        ccui.TouchEventType.ended)
    end
    self._bInitList = true
    self:_refreshIconAndName()
end

function UIClubInfo:_refreshIconAndName()
    local clubService = game.service.club.ClubService.getInstance()
    for _, item in pairs(self._listClubIcon:getChildren()) do
        local tag = item:getTag()
        local iconName = string.format("Club_Icon_%d", tag)
        item:getChildByName("Image_m_1_list_Clubinfo"):setVisible(iconName == clubService:getClubIconName(self._clubId))
    end
    self._selectIcon = clubService:getClubIconName(self._clubId)
    self._textFileName:setString(clubService:getClubName(self._clubId))
end


function UIClubInfo:_onClickIconItem(sender)
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    local tag = sender:getTag()
    for _, node in pairs(self._listClubIcon:getChildren()) do
        node:getChildByName("Image_m_1_list_Clubinfo"):setVisible(false)
    end
    sender:getChildByName("Image_m_1_list_Clubinfo"):setVisible(true)
    self._selectIcon = string.format("Club_Icon_%d", tag)
end

--改变输入框位置
function UIClubInfo:_onEventSearch(sender, event)
    local platForm = cc.Application:getInstance():getTargetPlatform()
    if platForm ~= cc.PLATFORM_OS_ANDROID then
        if event == ccui.TextFiledEventType.attach_with_ime then
            self._panelEdit:setPositionY(self._beginPosY_panelEdit + display.height * 0.15)
            self._panelClub:setPositionY(self._beginPosY_panelClub + display.height * 0.15)
        elseif event == ccui.TextFiledEventType.detach_with_ime then
            self._panelEdit:setPositionY(self._beginPosY_panelEdit)
            self._panelClub:setPositionY(self._beginPosY_panelClub)
        end
    end
end

return UIClubInfo