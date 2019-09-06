local csbPath = "ui/csb/UISelectDistrict.csb"
local super = require("app.game.ui.UIBase")

local UISelectDistrict = class("UISelectDistrict", super, function () return kod.LoadCSBNode(csbPath) end)


function UISelectDistrict:ctor()
	self._btnClose = nil
	self._areaCheckBox = nil
	self._areaCheckRoot = nil
	self._btnConfirm = nil
	self._allCheckBox = {}
	self._district = {}					--服务器数据
	self._defaultArea = 0				--服务器发送的用户默认选择的服务器
	self._isFrist = false

	self._currentSelected = 0			--当前选择的服务器,0为未选择

	-- 绑定事件系统
	cc.bind(self, "event");
end

function UISelectDistrict:dispose()
    -- 解绑事件系统
	cc.unbind(self, "event");
end


function UISelectDistrict:init( ... )
    self._areaCheckBox = seekNodeByName(self,"CheckBox_1_STP",	"ccui.CheckBox")
	self._areaCheckRoot = seekNodeByName(self,"AreaList",		"ccui.Layout")
	self._btnConfirm = seekNodeByName(self,"Button_qd_STP",	"ccui.Button")
	self._btnClose = seekNodeByName(self,"Button_x_STP",		"ccui.Button")

	self._areaCheckBox:setVisible(false)

	self:addCallBack()
end

function UISelectDistrict:onShow( ... )
    local args = {...}
	self._district = args[1]
	self._defaultArea = args[2]	

	--用于判断用户是否首次登陆选区，首次登录时隐藏关闭按钮
	self._isFrist = args[3]

	self._btnClose:setVisible(false)
	if self._isFrist == false then
		self._btnClose:setVisible(true)
	end

	self:createSeverCheckboxList()
	self:onSelectCheckBox(self._defaultArea)
end

function UISelectDistrict:addCallBack()
	bindEventCallBack(self._btnClose,    handler(self, self.onBtnCloseClick),   ccui.TouchEventType.ended); 
	bindEventCallBack(self._btnConfirm,    handler(self, self.onBtnConfirm),    ccui.TouchEventType.ended);
end

function UISelectDistrict:needBlackMask()
	return true;
end

function UISelectDistrict:closeWhenClickMask()
	return false
end


-- 创建选择服务器checkbox列表
function UISelectDistrict:createSeverCheckboxList()
	self._areaCheckRoot:removeAllChildren()
	local idx = 1
	table.foreach(self._district, function( key, val)
		local row = math.ceil(idx / 2) - 1
		local column = 1 - idx % 2

		local node = self._areaCheckBox:clone()
		node:setSelected(false)
		self._areaCheckRoot:addChild(node)
		node:setVisible(true)
		local text = ccui.Helper:seekNodeByName(node ,"Text_z_1_STP")
		text:setString(val.name)
		cc.Node.setPosition( node, cc.p( column* 220,-row * 50))		

		if val.area ~= nil then
			self._allCheckBox[val.area] = node	
		--添加点击事件
			node:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then						
                    elseif eventType == ccui.TouchEventType.moved then
                    elseif eventType == ccui.TouchEventType.ended then  
						self:onSelectCheckBox(val.area)             
                    elseif eventType == ccui.TouchEventType.canceled then
						self:onSelectCheckBox(val.area)
                    end
            end )
		end		

		idx = idx +1
	end)
end

-- checkbox点击事件
function UISelectDistrict:onSelectCheckBox(area)
	if self._allCheckBox[area] ~= nil then
		table.foreach(self._allCheckBox, function ( key, val)
			val:setSelected(false)
		end)
		self._allCheckBox[area]:setSelected(true)
		self._currentSelected=area
	end
end

function UISelectDistrict:onBtnCloseClick()
	UIManager:getInstance():hide("UISelectDistrict")
end

function UISelectDistrict:onBtnConfirm()
	if self._currentSelected == 0 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("您必须先选择一个地区");
		return
	end
	if self._isFrist == true then
		local request = net.NetworkRequest.new(net.protocol.CGSelectAreaREQ, game.service.LocalPlayerService:getInstance():getGameServerId())

		-- 因服务器需要 只有测试渠道时发送appcode和name
		if  game.plugin.Runtime.isEnabled() then
			request:getProtocol():setData(self._currentSelected);			
		else
			request:getProtocol():setData(self._currentSelected,  tonumber(game.plugin.Runtime.getChannelId()), game.service.LocalPlayerService:getName());
		end
   	 	game.util.RequestHelper.request(request)
	else
		game.service.LoginService.getInstance():switchArea(self._currentSelected)
	end
end

return UISelectDistrict;