local csbPath = "ui/csb/UILoginDingding.csb" --ui文件
local super = require("app.game.ui.UIBase")

local UIH5Login = class("UIH5Login", super, function () return kod.LoadCSBNode(csbPath) end)

--构造函数
function UIH5Login:ctor()
	--这里可以写成员的声明等
    self._callback = nil
    self._btnClose = nil
end

--析构函数
function UIH5Login:destroy()
	--释放内存
end

--初始化函数
function UIH5Login:init()
    --这里可以写成员的定义等
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

--显示函数
function UIH5Login:onShow(callback)
    --界面显示逻辑
    
    self._callback = callback
end

--隐藏函数
function UIH5Login:onHide()
	--界面隐藏逻辑
end

--返回界面层级
function UIH5Login:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIH5Login:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

--是否需要遮罩
function UIH5Login:needBlackMask()
	return true;
end

--关闭时操作
function UIH5Login:closeWhenClickMask()
	return false
end

-- 标记为Persistent的UI不会destroy
function UIH5Login:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIH5Login:isFullScreen()
	return false;
end

--自己的逻辑
--TODO:
function UIH5Login:_onBtnClose()
    if self._callback then
        self._callback()
    end
end

return UIH5Login;