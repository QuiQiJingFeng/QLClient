local csbPath = "ui/csb/UIShare2_chaoshan.csb"
local super = require("app.game.ui.UIBase")
local MultiArea = require("app.gameMode.config.MultiArea")
local Version = require "app.kod.util.Version"

-- 保存改界面是否打开过
local LocalIsLoad = class("LocalIsLoad")
function LocalIsLoad:ctor()
    self._load = false
end

function LocalIsLoad:getIsLoad()
    return self._load
end

function LocalIsLoad:setIsLoad(load)
    self._load = load
end

local UIShareWTF_chaoshan = class("UIShareWTF_chaoshan", super, function () return kod.LoadCSBNode(csbPath) end)

function UIShareWTF_chaoshan:ctor()
	self._shareType = false;
	self._btnClose = nil
	self._shareUrl = nil
	self._extend = nil
end

function UIShareWTF_chaoshan:init()
	self._btnClose   = seekNodeByName(self,"Button_Close",   "ccui.Button")
	self._btnSystem  = seekNodeByName(self,"Button_Sys", 	 "ccui.Button")
	self._TextBtnShare = seekNodeByName(self, "BitmapFontLabel_2", "ccui.TextBMFont")

	self:_registerCallBack()
end

function UIShareWTF_chaoshan:_registerCallBack()
	bindEventCallBack(self._btnClose,   handler(self, self._onClose),ccui.TouchEventType.ended);
	bindEventCallBack(self._btnSystem,  handler(self, self._onShareToSystem),ccui.TouchEventType.ended);
end

--[[
	参数类型:
	1.分享类型:截图 链接...
	2.从哪里点击进来的:大厅 活动...
	3.分享的内容
]]
function UIShareWTF_chaoshan:onShow(enter, data, finalCallback)
	self._enter = enter

    self._data = data
    
    self._finalCallback = finalCallback
    
    -- 获取这里本来要忘system下分享的形式
    local behaviors = share.config.getBehavior(enter, true);

    self._share_to_system = nil
    for i, b in ipairs(behaviors) do
        if string.find( b,"SYSTEM" ) then
            local closure = self:getBehaviorFunc(b) -- 根据行为配置，获取分享回调的闭包
            self._share_to_system = closure(data[i]) -- 给闭包传入所有数据
        end
    end

	if self._enter == share.constants.ENTER.ROOM_INFO then
		self._TextBtnShare:setString("邀请");
	else
		self._TextBtnShare:setString("微信分享");
	end
	
	--ios手机上只显示一次提示界面，然后下次就直接拉分享功能
	local isLoad = self:_loadLocalStorageIsLoad()

	if device.platform == "android" then
		self:autoShareToSystem()
	elseif device.platform == "ios" then
		if isLoad:getIsLoad() then
			self:autoShareToSystem()
		else
			isLoad:setIsLoad(true);
			self:_saveLocalStorageIsLoad(isLoad);
		end
	end
end

--[[
    @desc: 根据行为配置，获取分享回调的闭包
    author:{author}
    time:2018-05-24 13:56:33
    --@behavior: 行为配置
    return
]]
function UIShareWTF_chaoshan:getBehaviorFunc( behavior )
    local list = string.split(behavior, "|||") -- 分隔符拆分字符串
    local luaModule = list[1] -- 第一个是渠道，也是lua文件名的后半部分
    local luaMethod = list[2] -- 第二个是形式，具体行为的名字

    local _module = require("app.game.share.behavior.Share_"..luaModule) -- 获取行为table(module)

    return _module[luaMethod] -- 获取分享回调闭包
end

function UIShareWTF_chaoshan:autoShareToSystem()
	UIManager:getInstance():hide("UIShareWTF_chaoshan")
	--直接调安全分享
	scheduleOnce(function()
		self:_onShareToSystem()
	end, 0.1)
end


function UIShareWTF_chaoshan:_loadLocalStorageIsLoad()
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    return manager.LocalStorage.getUserData(roleId, "LocalIsLoad", LocalIsLoad)
end

function UIShareWTF_chaoshan:_saveLocalStorageIsLoad(localIsLoad)
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    manager.LocalStorage.setUserData(roleId,"LocalIsLoad", localIsLoad)
end


function UIShareWTF_chaoshan:needBlackMask()
	return true;
end

function UIShareWTF_chaoshan:closeWhenClickMask()
	return true
end

function UIShareWTF_chaoshan:_onClose(...)
	self:_close()
end

function UIShareWTF_chaoshan:_close()
	UIManager:getInstance():destroy("UIShareWTF_chaoshan")
end


-- 拉起系统分享
function UIShareWTF_chaoshan:_onShareToSystem(...)
    -- 统计系统分享
    if self._share_to_system ~= nil then
        self._share_to_system()
    end

    self:_doFinalCallback(share.constants.CHANNEL.SYSTEM)
	self:_close()
end

function UIShareWTF_chaoshan:_doFinalCallback( channel )
	if self._finalCallback ~= nil then
		self._finalCallback()
	end
	game.service.DataEyeService.getInstance():onEvent(self._enter .. "_to_" .. channel);
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIShareWTF_chaoshan:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIShareWTF_chaoshan;
