local csbPath = "ui/csb/Club/UIClubMemberSetting.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local UIClubMemberSetting = class("UIClubMemberSetting", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    修改亲友圈玩家职位
]]

local settings =
{
	{name = "设为管理", isVisible = false},
	{name = "撤职", isVisible = false},
	{name = "设为准成员", isVisible = false},
	{name = "设为正式成员", isVisible = false},
	{name = "设置备注", isVisible = true},
	{name = config.STRING.UICLUBMEMBERSETTING_STRING_100, isVisible = false},
	{name = config.STRING.UICLUBMEMBERSETTING_STRING_101, isVisible = false},
}

function UIClubMemberSetting:ctor()
end

function UIClubMemberSetting:init()
	self._listviewSetting = seekNodeByName(self, "ListView_Member_Setting", "ccui.ListView") -- 玩家权限修改列表

	self._listviewSetting:setScrollBarEnabled(false)
    self._listviewSetting:setTouchEnabled(false)
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listviewSetting, "Button_Member_Setting")
    self._listviewItemBig:removeFromParent(false)
    self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)

	self._img_bj = seekNodeByName(self, "Panel_Settings", "ccui.Layout")
end

function UIClubMemberSetting:onShow(data, pos)
	self._data = data
	self._pos = pos

	local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
	local club = game.service.club.ClubService.getInstance():getClub(data.clubId)
	if club:isManager(localRoleId) then
		-- -- 群主的踢出：该玩家不是自己
		settings[7].isVisible = data.roleId ~= localRoleId
	else
		-- 管理的踢出：该玩家不是群主管理，自己也是管理所以不用判断是不是可以踢自己
		settings[7].isVisible = data.title ~= ClubConstant:getClubPosition().MANAFER and data.title ~= ClubConstant:getClubPosition().ASSISTANT
	end
	-- 退出亲友圈按钮显示条件:只有自己能看见，并且群主不能显示
	settings[6].isVisible = data.roleId == localRoleId and data.title ~= ClubConstant:getClubPosition().MANAFER
	-- 撤职按钮显示条件：该玩家是管理并且自己是群主
	settings[2].isVisible = club:isManager(localRoleId) and data.title == ClubConstant:getClubPosition().ASSISTANT
	-- 设置管理按钮显示条件：该玩家是正式成员，并且该玩家是群主
    settings[1].isVisible = club:isManager(localRoleId) and data.title == ClubConstant:getClubPosition().MEMBER

	-- 准成员按钮显示条件:该玩家是成员
	settings[3].isVisible = data.title == ClubConstant:getClubPosition().MEMBER
	-- 正式成员按钮显示条件:该玩家是准成员
	settings[4].isVisible = data.title == ClubConstant:getClubPosition().OBSERVER

	-- 备注按钮显示条件：该玩家不是自己，自己是管理时，该玩家不能是管理
	if club:isManager(localRoleId) then
		settings[5].isVisible = true
	else
		settings[5].isVisible = data.roleId ~= localRoleId and (not club:isManager(localRoleId) and data.title ~= ClubConstant:getClubPosition().ASSISTANT)
	end
	self:_initListViewSetting()
end

function UIClubMemberSetting:_initListViewSetting()
	self._listviewSetting:removeAllChildren()

	for _, v in ipairs(settings) do
		if v.isVisible then
			local node = self._listviewItemBig:clone()
			self._listviewSetting:addChild(node)
			node:setVisible(true)

			local name = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_szgly")
			name:setString(v.name)

			bindEventCallBack(node, function()
				self:_onClickSetting(v.name)
			end, ccui.TouchEventType.ended)
		end
	end

	self:_initPosition()
end

function UIClubMemberSetting:_initPosition()
	local isRotate = self._pos.y > display.height / 2
	self._pos = self._img_bj:getParent():convertToNodeSpace(self._pos)
	if isRotate then
		self._img_bj:setBackGroundImage("art/img/img_xialabg.png")
		self._img_bj:setAnchorPoint(cc.p(0.5, 1))
		self._img_bj:setPosition(cc.p(self._pos.x - 30, self._pos.y - 18))
	else
		self._img_bj:setBackGroundImage("art/img/img_xialabg2.png")
		self._img_bj:setAnchorPoint(cc.p(0.5, 0))
		self._img_bj:setPosition(cc.p(self._pos.x - 30, self._pos.y + 12))
	end
	self._img_bj:setBackGroundImageCapInsets(cc.rect(25, 38, 12, 9))
	
	-- 设置list位置
	local count = #self._listviewSetting:getItems()
	-- 起始位置 + 每个item的大小 * item的个数
	local y = (isRotate and 70 or 90) + 70 * (count >= 4 and 3 or count - 1)
	local y2 = 100 + 70 * (count >= 4 and 3 or count - 1)
	-- 由于只有一个item时，显示太小，由于九宫格原因图片会变形，临时处理一下只有一个item时增大一下panel的大小
	self._listviewSetting:setPosition(cc.p(123, y + (count == 1 and 5 or 0)))
	self._img_bj:setContentSize(cc.size(245, y2 + (count == 1 and 10 or 0)))

	self._listviewSetting:requestDoLayout()
	self._listviewSetting:doLayout()	
end

function UIClubMemberSetting:_onClickSetting(name)
	if name == settings[1].name then
		self:_onClickManager()
	elseif name == settings[2].name then
		self:_onClickDismissal()
	elseif name == settings[3].name then
		self:_onClickTrainee()
	elseif name == settings[4].name then
		self:_onClickFormal()
	elseif name == settings[5].name then
		self:_onClickNote()
	elseif name == settings[6].name then
		self:_onClickQuit()
	elseif name == settings[7].name then
		self:_onClickReject()
	end
end

-- 正式成员降级为准成员
function UIClubMemberSetting:_onClickTrainee()
    -- 统计亲友圈变为准成员的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.club_change_into_associated_member);

    game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBMEMBERSETTING_STRING_102, {"确定", "取消"}, function()
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyMemberTitleREQ(self._data.clubId, self._data.roleId, ClubConstant:getClubPosition().OBSERVER)
        UIManager:getInstance():hide("UIClubMemberSetting")
    end)
end

-- 准成员升职为正式成员
function UIClubMemberSetting:_onClickFormal()
    -- 统计亲友圈变为正式成员的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.club_change_into_full_member);

    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyMemberTitleREQ(self._data.clubId, self._data.roleId, ClubConstant:getClubPosition().MEMBER)
    UIManager:getInstance():hide("UIClubMemberSetting")
end

-- 撤职
function UIClubMemberSetting:_onClickDismissal()
     game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyMemberTitleREQ(self._data.clubId, self._data.roleId, ClubConstant:getClubPosition().MEMBER)
     UIManager:getInstance():hide("UIClubMemberSetting")
end

-- 设置为管理
function UIClubMemberSetting:_onClickManager()
	local text = string.format(config.STRING.UICLUBMEMBERSETTING_STRING_103, game.service.club.ClubService.getInstance():getInterceptString(self._data.roleName, 8), self._data.roleId)
	game.ui.UIMessageBoxMgr.getInstance():show(text, {"确定", "取消"}, function()
		game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyMemberTitleREQ(self._data.clubId, self._data.roleId, ClubConstant:getClubPosition().ASSISTANT)
    	UIManager:getInstance():hide("UIClubMemberSetting")
	end)
end

-- 踢出玩家
function UIClubMemberSetting:_onClickReject()
	game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBMEMBERSETTING_STRING_104 , {"确定","取消"}, function()
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLKickOffMemberREQ(self._data.clubId, self._data.roleId, 0, 0)
        UIManager:getInstance():hide("UIClubMemberSetting")
    end)
end

-- 玩家自己退出
function UIClubMemberSetting:_onClickQuit()
	game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBMEMBERSETTING_STRING_105 , {"确定","取消"}, function()
        game.service.club.ClubService.getInstance():getClubMemberService():sendCCLQuitClubREQ(self._data.clubId)
        UIManager:getInstance():hide("UIClubMemberSetting")
    end)
end

function UIClubMemberSetting:_onClickNote()
	UIManager:getInstance():show("UIClubMember_Remark", self._data)
	UIManager:getInstance():hide("UIClubMemberSetting")
end

function UIClubMemberSetting:onHide()
	self._listviewSetting:removeAllChildren()
end

function UIClubMemberSetting:needBlackMask()
	return true
end

function UIClubMemberSetting:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubMemberSetting:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubMemberSetting