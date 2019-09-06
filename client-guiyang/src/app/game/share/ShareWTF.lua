
local ns = namespace("share")

--[[    你想分享个啥？
]]
local ShareWTF = class("ShareWTF")
ns.ShareWTF = ShareWTF

-- 单例支持
local instance = nil

-- 打印调试log支持
local _print = function() end
local _dump = function() end

function ShareWTF.create(printDebugLog)
	if instance then return false end
	if printDebugLog then
		_print = release_print
		_dump = dump
	end
	
	instance = ShareWTF.new()
	return true
end

function ShareWTF.getInstance()
	return instance
end

--[[    @desc: 分享个啥
	author:{author}
	time:2018-05-24 13:51:32
	--@enter: 入口
	--@data: 每个按钮传入的数据
	--@finalCallback: 按钮最后的回调
	return
]]
function ShareWTF:share(enter, data, finalCallback, uiname)
	-- 获取入口的分享行为
	local behaviors = share.config.getBehavior(enter);
	if Macro.assertTrue(behaviors == nil, "分享配置错了！！！") then
		return
	end
	
	self:_share(behaviors, enter, data, finalCallback, uiname)
end

--[[    @desc: 走默认的分享
	author:{author}
	time:2018-06-09 15:36:53
	--@enter: 入口
	--@data: 每个按钮传入的数据
	--@finalCallback: 按钮最后的回调
	--@uiname: ui
	return
]]
function ShareWTF:shareDefault(enter, data, finalCallback, uiname)
	-- 获取入口的分享行为
	local behaviors = share.config.getBehavior(enter, true);
	if Macro.assertTrue(behaviors == nil, "分享配置错了！！！") then
		return
	end
	
	self:_share(behaviors, enter, data, finalCallback, uiname)
end

--单独的钉钉分享按钮用,传入相同的enter就行,自动换成钉钉用的
function ShareWTF:shareDing(enter, data, finalCallback, uiname)
	-- 获取入口的分享行为
	local behaviors = share.config.getBehavior(enter);
	if Macro.assertTrue(behaviors == nil, "分享配置错了！！！") then
		return
	end
	
	local list = string.split(behaviors[1], "|||") -- 分隔符拆分字符串
	local luaMethod = list[2] -- 第二个是形式，具体行为的名字
	
	behaviors = {
		"DINGDING|||" .. luaMethod
	}
	
	self:_share(behaviors, enter, data, finalCallback, uiname)
end

--[[    @desc: 具体分享
	author:{author}
	time:2018-06-09 15:37:39
	--@behaviors:
	--@enter:
	--@data:
	--@finalCallback:
	--@uiname: 
	return
]]
function ShareWTF:_share(behaviors, enter, data, finalCallback, uiname)
	data = data or {}
	uiname = uiname or "UIShareWTF"
	--统计打点用
	local statisticF = function(shareType)
		local key = "Share__" .. enter .. "-" .. shareType
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames[key])
		Logger.debug(key)
	end
	-- 如果当行为只有一个，我们默认为分析行为被转交给别的方式处理了
	if #behaviors == 1 then
		local closure, shareType = self:_getBehaviorFunc(behaviors[1]) -- 根据行为配置，获取分享回调的闭包
		local func = nil
		if self:_isBaseChannel(behaviors[1]) then
			func = function()
				statisticF(shareType)
				closure(data[1])() -- 如果是基础渠道就传入data
				if finalCallback then
					finalCallback()
				end
			end
		else
			func = function()
				statisticF(shareType)
				closure(enter, data, finalCallback, uiname)() -- 如果是自定义，给闭包传入所有数据
			end
		end
		return func() -- 执行
	end
	
	local funcs = {};
	for i, b in ipairs(behaviors) do
		local closure, shareType = self:_getBehaviorFunc(b) -- 根据行为配置，获取分享回调的闭包
		local func = function()
			local usedData = data[i]
			if not usedData then
				usedData = data[1]
			end
			statisticF(shareType)
			closure(usedData)() -- 给闭包传入数据
		end
		table.insert(funcs, func)
	end
	
	-- 构建分享ui，并传入各种数据
	UIManager:getInstance():show(uiname, enter, behaviors, funcs, finalCallback)
end

--[[    @desc: 根据行为配置，获取分享回调的闭包
	author:{author}
	time:2018-05-24 13:56:33
	--@behavior: 行为配置
	return 分享闭包,和分享方式(打点用)
]]
function ShareWTF:_getBehaviorFunc(behavior)
	local list = string.split(behavior, "|||") -- 分隔符拆分字符串
	local luaModule = list[1] -- 第一个是渠道，也是lua文件名的后半部分
	local luaMethod = list[2] -- 第二个是形式，具体行为的名字
	
	local channel = share.constants.getShareChannel(luaModule)
	-- print("_getBehaviorFunc", channel, luaModule)
	local _module = require("app.game.share.behavior.Share_" .. channel) -- 获取行为table(module)
	
	return _module[luaMethod], luaModule -- 获取分享回调闭包
end

--[[    @desc: 判断是否基础的channel
	author:{author}
	time:2018-06-22 10:54:38
	--@behavior: 行为
	return
]]
function ShareWTF:_isBaseChannel(behavior)
	local list = string.split(behavior, "|||") -- 分隔符拆分字符串
	local channel = list[1] -- 第一个是渠道，也是lua文件名的后半部分
	
	return share.constants.CHANNEL[channel] ~= nil
end 