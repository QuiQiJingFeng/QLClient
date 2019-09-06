local csbPath = "ui/csb/UIShareRoomInfo.csb" --ui文件

local UIShareRoomInfo = class("UIShareRoomInfo", function () return cc.CSLoader:createNode(csbPath) end )

--构造函数
function UIShareRoomInfo:ctor()
	--这里可以写成员的声明等
	--For example:
	self._txtTip = seekNodeByName(self, "txtType", "ccui.Text")
	self._txtTitle = seekNodeByName(self, "txtTitle", "ccui.Text")
	self._txtContent = seekNodeByName(self, "txtContent", "ccui.Text")
	self._sharePannel = seekNodeByName(self, "panelMain", "ccui.Layout")
	self._imgErweima = seekNodeByName(self, "Image_1", "ccui.ImageView")
end

--析构函数
function UIShareRoomInfo:destroy()
	--释放内存
	--For example:
end

--初始化函数
function UIShareRoomInfo:init()
	--这里可以写成员的定义等
	--For example:
end

--显示函数
function UIShareRoomInfo:onShow(...)
	--界面显示逻辑
	local args = {...}
	local tip = args[1]
	local title = args[2]
	local content = args[3]
	local filePath = args[4]
	local erweimaUrl = args[5]
	self._txtTip:setString(tip)
	self._txtTitle:setString(title)
	self._txtContent:setString(content)
	self._sharePannel:setAnchorPoint(cc.p(0.5, 0.5))
	self._sharePannel:setBackGroundImage(filePath)
	game.util.PlayerHeadIconUtil.setIcon(self._imgErweima, erweimaUrl);
end

function UIShareRoomInfo:getSharePannel()
	return self._sharePannel
end

--隐藏函数
function UIShareRoomInfo:onHide()
	--界面隐藏逻辑
end

--返回界面层级
function UIShareRoomInfo:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIShareRoomInfo:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

--是否需要遮罩
function UIShareRoomInfo:needBlackMask()
	return false;
end

--关闭时操作
function UIShareRoomInfo:closeWhenClickMask()
	return false
end

-- 标记为Persistent的UI不会destroy
function UIShareRoomInfo:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIShareRoomInfo:isFullScreen()
	return false;
end

--自己的逻辑
--TODO:


return UIShareRoomInfo;