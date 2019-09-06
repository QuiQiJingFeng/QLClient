local csbPath = "ui/csb/xxx.csb" --ui文件
local super = require("app.game.ui.UIBase")

local UITemplate = class("UITemplate",super,function () return cc.CSLoader:createNode(csbPath) end )

--构造函数
function UITemplate:ctor()
	--这里可以写成员的声明等
	--For example:
	self._root = nil;
end

--析构函数
function UITemplate:destroy()
	--释放内存
	--For example:
	self._root = nil;
end

--初始化函数
function UITemplate:init()
	--这里可以写成员的定义等
	--For example:
	self._root = seekNodeByName(self, "root", "ccui.LayerOut");
end

--显示函数
function UITemplate:onShow(...)
	--界面显示逻辑
end

--隐藏函数
function UITemplate:onHide()
	--界面隐藏逻辑
end

--返回界面层级
function UITemplate:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UITemplate:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

--是否需要遮罩
function UITemplate:needBlackMask()
	return false;
end

--关闭时操作
function UITemplate:closeWhenClickMask()
	return false
end

-- 标记为Persistent的UI不会destroy
function UITemplate:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UITemplate:isFullScreen()
	return false;
end

--自己的逻辑
--TODO:


return UITemplate;