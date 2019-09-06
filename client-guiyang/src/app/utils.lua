function scheduleOnce(callback, delay, optActionNode)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local node = optActionNode or cc.Director:getInstance():getRunningScene();
    node:runAction(sequence)
    return sequence
end

function unscheduleOnce(action, optActionNode)
    local node = optActionNode or cc.Director:getInstance():getRunningScene();
    node:stopAction(action)
end

-- 加入 scheduleId 是为了在外部使用的时候也只通过一个 id 来判断是否已经有 update 被注册了
-- return 一个 scheduleId 去解绑
-- example: (多次注册也没有问题， 只会第一个有效的在执行)
-- local sId
-- sId = scheduleUpdate(sId, function() print("test"), 1)
-- sId = scheduleUpdate(sId, function() print("test"), 1)
-- sId = unscheduleUpdate(sId)
function scheduleUpdate(scheduleId, callback, intervalSec)
    if scheduleId == nil and callback and type(intervalSec) == "number" and intervalSec > 0 then
        return cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, intervalSec, false)
    end
    return scheduleId
end

-- 通过 id 去解绑更新， id 为 scheduleUpdate 的返回值
function unscheduleUpdate(scheduleId)
    if scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
    end
    return nil
end

-- 全局事件
function listenGlobalEvent(name, callback)
    local listener = cc.EventListenerCustom:create(name, function(event)
        callback(event.userdata)
    end)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
    return listener
end

function unlistenGlobalEvent(listener)
    cc.Director:getInstance():getEventDispatcher():removeEventListener(listener)
end

function dispatchGlobalEvent(name, userdata)
    local event = cc.EventCustom:new(name)
    event.userdata = userdata
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end


function table.shuffle(array)
    local count = #array
    local times = count * 2
    local rand = math.random
    for n = 1, times do
        local j, k = rand(count), rand(count)
        array[j], array[k] = array[k], array[j]
    end
end

-- the DJB hash function
function string.hash(text)
    local hash = 5381
    for n = 1, #text do
        hash = hash + bit.lshift(hash, 5) + string.byte(text, n)
    end
    return bit.band(hash, 2147483647)
end

function table.bubbleSort(tb, compFunc)
    for i = 1, #tb do
        for j = 1, #tb - i do
            if tb[j + 1] and compFunc(tb[j + 1], tb[j]) == false then
                tb[j + 1], tb[j] = tb[j], tb[j + 1]
            end
        end
    end
end

--[[    @desc: 对某个node截图
    author:{machicheng}
    time:2017-10-30 14:58:48
    --@node: 需要截图的node
	--@callback: 回调
	--@name: 存储文件名
    return 存储文件路径 + 存储文件名
]]
function saveNodeToPng(node, callback, name)
    Macro.assetTrue(type(node) ~= "userdata")
    -- clone 一下node，防止对之前的node产生影响
    local localNode = node:clone()
    localNode:setVisible(true)
    localNode:retain()

    -- 如果储存的图片未定义名字，则设置默认名
    name = name or "saveNodeToPng.png"

    -- 可写路径，截图会存在这里
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local filePath = writablePath .. name
    -- 删除之前的
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        cc.FileUtils:getInstance():removeFile(filePath)
    end

    local size = node:getContentSize() -- 截图的图片大小

    -- 创建renderTexture
    local render = cc.RenderTexture:create(size.width, size.height)
    localNode:setPosition(cc.p(size.width / 2, size.height / 2))
    -- 绘制
    render:begin()
    localNode:visit()
    render:endToLua()
    localNode:release() -- release the retain
    -- 保存
    render:saveToFile(name, cc.IMAGE_FORMAT_PNG)

    -- 返回存好的文件，如果有callback则调用callback，否则返回文件路径
    if type(callback) == "function" then
        local a = 0
        -- 执行schedule检查文件，保存好就调用callback，可能会出问题，比如回调里的东西被释放了
        local checkTimer = nil
        checkTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            -- body
            a = a + 1
            if cc.FileUtils:getInstance():isFileExist(filePath) then
                print("检查了这么多次啊", a)
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(checkTimer)
                callback(filePath)

            end
        end, 0.01, false)
    end
    return filePath
end

--[[    @desc: 调用cocos提供的截屏接口，截一张有logo的图
            貌似cocos提供的接口是在多帧执行的，所以ui会在当前界面闪一下
    author:{马驰骋}
    time:2018-01-20 15:31:12
    --@callback: 截图完成时的回调
    return
]]
function captureScreenWithLogo(callback)
    local cb = function(success, file)
        -- 回调时关闭logoui
        UIManager:getInstance():hide("UIShareLogo", false)
        callback(success, file)
    end
    -- 先把logo的ui显示出来
    UIManager:getInstance():show("UIShareLogo")

    -- 分享截图
    cc.utils:captureScreen(cb, "ScreenShotWithLogo.jpg")
end

--[[    @desc: 利用renderTexture渲染当前scene，得到截图
            对当前场景的渲染貌似会有bug，有些图显示的有问题
    author:{马驰骋}
    time:2018-01-20 15:32:32
    --@callback: 截图完成时的回调
    return
]]
function captureScreenWithLogo2(callback)
    local cb = function(success, file)
        -- 回调时关闭logoui
        UIManager:getInstance():hide("UIShareLogo", false)
        callback(success, file)
    end
    -- 先把logo的ui显示出来
    UIManager:getInstance():show("UIShareLogo")

    -- 获取当前场景
    local scene = cc.Director:getInstance():getRunningScene()
    -- 当前场景大小
    local size = cc.Director:getInstance():getWinSize()
    -- 可写路径，截图会存在这里
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local name = "ScreenShotWithLogo2.png"

    -- 创建renderTexture
    local render = cc.RenderTexture:create(size.width, size.height)
    -- 绘制
    render:begin()
    scene:visit()
    render:endToLua()
    -- 保存
    render:saveToFile(name, cc.IMAGE_FORMAT_PNG)
    local filePath = writablePath .. name
    -- 调用回调
    cb(true, filePath)
end


--截取字符串
function getInterceptString(str, len)
	-- 如果没有传长度，默认为12个字符
	if len == nil then
		len = 12
	end

	-- 线上有报错为空的情况，先判断一下字符串是否为空
	if str == nil then
		return ""
	end
	
	if kod.util.String.getUTFLen(str) > len then
		return kod.util.String.getMaxLenString(str, len)
	end
	
	return str
end