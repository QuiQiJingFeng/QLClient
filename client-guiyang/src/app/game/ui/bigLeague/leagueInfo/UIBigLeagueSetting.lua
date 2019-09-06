local csbPath = "ui/csb/BigLeague/UIBigLeagueSetting.csb"
local super = require("app.game.ui.UIBase")
local UIBigLeagueSetting = class("UIBigLeagueSetting", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    联盟管理界面
    	用于A对某个俱乐部管理
]]

local settings =
{
	{name = "团队概况", isVisible = true},
	{name = "调整分数", isVisible = false},
	{name = "设置活跃值赠送", isVisible = true},
	{name = "设置备注", isVisible = true},
	{name = "暂停比赛", isVisible = true},
	{name = "恢复比赛", isVisible = false},
	{name = "踢出赛事", isVisible = true},
}

function UIBigLeagueSetting:ctor()
end

function UIBigLeagueSetting:init()
	self._listviewSetting = seekNodeByName(self, "ListView_Member_Setting", "ccui.ListView") -- 玩家权限修改列表

	self._listviewSetting:setScrollBarEnabled(false)
	--self._listviewSetting:setTouchEnabled(false)
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listviewSetting, "Button_Member_Setting")
    self._listviewItemBig:removeFromParent(false)
    self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)

	self._img_bj = seekNodeByName(self, "Panel_Settings", "ccui.Layout")
end

function UIBigLeagueSetting:onShow(data, pos)
	self._data = data
	self._pos = pos
	self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()

	-- 暂停比赛、恢复比赛  只能显示一个
	settings[5].isVisible = self._data.status == self._bigLeagueService:getLeagueData():getLeagueClubStatus().NORMAL
	settings[6].isVisible = self._data.status == self._bigLeagueService:getLeagueData():getLeagueClubStatus().PAUSE


	self:_initListViewSetting()
end

function UIBigLeagueSetting:_initListViewSetting()
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
				UIManager:getInstance():hide("UIBigLeagueSetting")
			end, ccui.TouchEventType.ended)
		end
	end

	self:_initPosition()
end

function UIBigLeagueSetting:_initPosition()
	local isRotate = self._pos.y > display.height / 2
	self._pos = self._img_bj:getParent():convertToNodeSpace(self._pos)
	if isRotate then
		--self._img_bj:setBackGroundImage("art/img/img_xialabg.png")
		self._img_bj:setBackGroundImage("art/main/img_listdw_main.png")
		self._img_bj:setAnchorPoint(cc.p(0.5, 1))
		self._img_bj:setPosition(cc.p(self._pos.x - 60, self._pos.y))
	else
		--self._img_bj:setBackGroundImage("art/img/img_xialabg2.png")
		self._img_bj:setBackGroundImage("art/main/img_listdw2_main.png")
		self._img_bj:setAnchorPoint(cc.p(0.5, 0))
		self._img_bj:setPosition(cc.p(self._pos.x - 60, self._pos.y - 6))
	end
	self._img_bj:setBackGroundImageCapInsets(cc.rect(25, 38, 12, 9))
	
	-- 设置list位置
	local count = #self._listviewSetting:getItems()
	-- 起始位置 + 每个item的大小 * item的个数
	local y = (isRotate and 70 or 90) + 70 * (count >= 4 and 3.5 or count - 1)
	local y2 = 100 + 70 * (count >= 4 and 3.5 or count - 1)
	-- 由于只有一个item时，显示太小，由于九宫格原因图片会变形，临时处理一下只有一个item时增大一下panel的大小
	self._listviewSetting:setPosition(cc.p(123, y + (count == 1 and 5 or 0)))
	self._img_bj:setContentSize(cc.size(245, y2 + (count == 1 and 10 or 0)))

	self._listviewSetting:requestDoLayout()
	self._listviewSetting:doLayout()	
end

function UIBigLeagueSetting:_onClickSetting(name)
	if name == settings[1].name then
		self:_onClickTeamOverview()
	elseif name == settings[2].name then
		self:_onClickSetScore()
	elseif name == settings[3].name then
		self:_onClickSetFire()
	elseif name == settings[4].name then
		self:_onClickSetDesc()
	elseif name == settings[5].name then
		self:_onClickPause()
	elseif name == settings[6].name then
		self:_onClickRestore()
	elseif name == settings[7].name then
		self:_onClickKick()
	end
end

-- 团队概况
function UIBigLeagueSetting:_onClickTeamOverview()
	UIManager:getInstance():show("UIBigLeagueScoreMain", 2, self._data.clubId)
end

-- sendCCLModifyLeagueREQ   由于优化   只能在修改积分时传分数，其余操作都传0
function UIBigLeagueSetting:_onClickSetScore()
	UIManager:getInstance():show("UIKeyboard2", "积分修改", 6, "积分输入有误，请重新输入", "确定", function (score)
		self._bigLeagueService:sendCCLModifyLeagueREQ(
			self._bigLeagueService:getLeagueData():getLeagueId(),
			self._data.clubId,
			tonumber(score),
			self._data.fireScoreRate,
			self._data.remark
		)
	end)
end

function UIBigLeagueSetting:_onClickSetFire()
	UIManager:getInstance():show("UIBigLeagueFireGive",self._data.clubId)
end
function UIBigLeagueSetting:_onClickSetDesc()
	UIManager:getInstance():show("UIBigLeagueNameSetting", "备注", "请输出备注名（限定6个字）", 12, function (name)
		self._bigLeagueService:sendCCLModifyLeagueREQ(
				self._bigLeagueService:getLeagueData():getLeagueId(),
				self._data.clubId,
				0,
				self._data.fireScoreRate,
				name,
				true
		)
	end)
end

--暂停比赛
function UIBigLeagueSetting:_onClickPause()
	local str = string.format("暂停比赛后该团队无法进行对战，确定要暂停%s的比赛吗？", self._data.clubName)
	game.ui.UIMessageBoxMgr.getInstance():show(str, {"确定", "取消"}, function ()
		self._bigLeagueService:sendCCLPauseGameREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._data.clubId, self._data.clubName)
	end)
end

-- 恢复比赛
function UIBigLeagueSetting:_onClickRestore()
	self._bigLeagueService:sendCCLRestoreGameREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._data.clubId, self._data.clubName)
end

--强制提出
function UIBigLeagueSetting:_onClickKick()
	local str = string.format("确定要把%s强制退赛吗？", self._data.clubName)
	game.ui.UIMessageBoxMgr.getInstance():show(str, {"确定", "取消"}, function ()
		self._bigLeagueService:sendCCLForceQuitGameREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._data.clubId)
	end)
end

function UIBigLeagueSetting:needBlackMask()
	return true
end

function UIBigLeagueSetting:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIBigLeagueSetting:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueSetting