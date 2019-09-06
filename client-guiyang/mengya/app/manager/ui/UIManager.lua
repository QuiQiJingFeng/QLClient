--[[界面管理器, 功能
1. UI加载|释放
	1. 显示界面的时候, 如果不存在, 加载界面
	2. 界面只有在需要销毁的手动调用销毁, 一般情况只隐藏
2. UI显示|隐藏
3. UI排序(强制层级)
	将UI分为3层,TopMost, Top, Normal, Bottom, BottomMost, 每一层有固定的层级范围, 每个UI都要自己定义所属的层级, 默认为Normal
	1. 显示的时候, 在本层级排序, 谁显示谁最高 
	2. 5个层,全屏层像clubMain，uimain，UILaunch 这种ui要把层级设成bottom，一般ui设成normal；tips,messageBox 设成top
	3. 显示某个大层的某个ui时，会把比该大层ZOrder更高级的ui都隐藏，而bottom一级的，也要把bottom一级的其他ui隐藏。
--]]
local UIManager = class("UIManager")
-------------------------
--层级范围
local UI_LEVEL    = { BottomMost = 1, Bottom = 2, Normal = 3, Top = 4, TopMost = 5 }

--不需要做行为统计的图层
local unRecordLayers = {
    ["UIReconnectTips"] = true,
}

local function checkUnRecordLayer(layerName)
    return unRecordLayers[layerName]
end
-- 单例支持
local _instance = nil
function UIManager:getInstance()
    if _instance then
        return _instance
    end
    _instance = UIManager:new()
    return _instance
end

-------------------------
-- 构造函数
function UIManager:ctor()
    -- 存放ui数组
    self._uiMap = {}
    -- 存放分层的大层layer节点,分别存放
    self._layers = {}

    -- 当前state里面创建UI的相关参数
    self._uiParamsLists = {}
    self._uiNameLists = {}
    -- 所有缓存的历史的创建UI缓存
    self._uiParamsCache = {}
    self._isNeedRestore = false

    --按层级顺序记录所有显示的UI, 初始化数量需要与UI_LEVEL数量一致
    self._uiLayerList = { {}, {}, {}, {}, {} }

    -- 有序存储应该显示的ui，用于对全屏弹窗覆盖下的ui进行隐藏，以减少drawcalls
    self._uiStack = {}
    self._uiNames = {}
    self._curUIName = ""

    self:_createLayers()
end

function UIManager:_createLayers()
    local scene = cc.Director:getInstance():getRunningScene()
    for i = 1, 5 do
        local layer = cc.Layer:create()
        scene:addChild(layer)
        table.insert(self._layers, layer)
    end
end

function UIManager:getTopMostLayer()
    return self._layers[UI_LEVEL.TopMost]
end

function UIManager:getUI(name)
    return self._uiMap[name]
end

-- @param state 要缓存的名称，为nil当前界面不缓存
function UIManager:clear(state, destoryUnusedUI)
    -- 把上把的UI创建缓存下来，如果有需要，恢复	
    if state and state ~= "" then
        self._uiParamsCache[state] = { uiLists = self._uiNameLists, uiParams = self._uiParamsLists }
    end
    self._uiNameLists = {}
    self._uiParamsLists = {}
    -- 隐藏所有界面
    local destroylist = {}
    for name, ui in pairs(self._uiMap) do
        self:_hideUI(ui)
        if not ui:isPersistent() then
            table.insert(destroylist, name)
        end
    end

    -- 销毁界面
    if destoryUnusedUI then
        for _, name in ipairs(destroylist) do
            self:destroy(name)
        end
    end
end

-- 设置下次恢复的state要不要打开上次离开时缓存的界面
function UIManager:setNeedRestore(isNeeded)
    self._isNeedRestore = isNeeded
end

-- 进入state的时候检查使用，如果需要加存上次的缓存，返回
function UIManager:needRestore()
    return self._isNeedRestore
end

-- @param state 要加载的缓存名字，需要在上次在state exit的时候clear("")传入对应的名字
-- 在本次缓存的时候传入用来加载
function UIManager:restoreUIs(state)
    local tb = self._uiParamsCache[state]
    if #tb.uiLists == #tb.uiParams then
        for i = 1, #tb.uiLists do
            self:show(tb.uiLists[i], unpack(tb.uiParams[i]))
        end
    end
end

-- 加载界面
function UIManager:_loadUI(name)
    print("loadUI =", name)
    -- 获取UI class
    local uiClass = app[name]
    assert(uiClass, "ERROR: name or path is invalid! name=" .. tostring(name))

    -- 初始化UI
    local ui = uiClass.new()
    --获取UI的层级
    local layerLevel = ui:getGradeLayerLevel()
    self._layers[layerLevel]:addChild(ui)
    ui:setName(name)
    ui:init()
    ui:setVisible(false)
    self._uiMap[name] = ui

    -- 构造Mask背景
    if ui:needBlackMask() then
        self:createMaskLayer(ui)
    end

    return ui
end

-- 创建模态层，抽出来
function UIManager:createMaskLayer(ui)
    local maskName = "dlg_mask"
    local maskUI = ui:getChildByName(maskName)
    local name = ui:getName()
    if maskUI then
        error("自动创建Mask出错，UI不能有名字为dlg_mask的控件")
    else
        local mask = ccui.Layout:create()
        mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        mask:setBackGroundColor(cc.c3b(0, 0, 0))
        mask:setContentSize(cc.size(display.width, display.height))
        mask:setBackGroundImageScale9Enabled(true)
        mask:setName(maskName)
        mask:setOpacity(178)
 

        local offset = cc.p(CC_DESIGN_RESOLUTION.screen.offsetPoint().x, CC_DESIGN_RESOLUTION.screen.offsetPoint().y)
        offset.x = offset.x - CC_DESIGN_RESOLUTION.screen._safeAreaOffset_x
        mask:setPosition(cc.p(0,0))
        local contentSize = mask:getContentSize()
        if contentSize.width / contentSize.height > display.width / display.height then
            mask:setScale(display.height / contentSize.height)
        else
            mask:setScale(display.width / contentSize.width)
        end

        -- 设置遮罩的点击事件
        mask:setTouchEnabled(true)
        if ui:closeWhenClickMask() then
            mask:addTouchEventListener(function()
                UIManager:getInstance():hide(name)
            end)
        end

        ui:addChild(mask, -1)
    end
end

-- 显示界面
function UIManager:show(name, ...)
    local param = { ... }
    print("Show UI : %s", name)
    local ui = self:getUI(name)
    if not ui then
        ui = self:_loadUI(name)
    end
    self:_addStackUI(ui)
    self:_addCache(name, unpack(param))
    --为显示的ui排序
    self:_addAndShowInUILayer(ui, unpack(param))
    self:_updateStackUIVisible()
    if checkUnRecordLayer(name) then
        return
    end

    table.insert(self._uiNames, name)
    self._curUIName = name
    return ui
end

-- 通过UI名字隐藏界面
function UIManager:hide(name)
    local ui = self:getUI(name)
    if ui == nil then
        return
    end

    --移除层级ui表中相应的记录
    self:_removeFromUILayer(ui)
    self:_hideUI(ui)
end

-- 获取当前UI名称
function UIManager:getCurUIName()
    return self._curUIName
end


-- 隐藏界面
function UIManager:_hideUI(ui)
    local index = table.indexof(self._uiStack, ui)
    --因为优化drawcarll的原因,所以不显示的UI也需要调用onHide,所以就意味着一次onShow 可能对应多次onHide
    if index or ui:isVisible() then
        -- 保证隐藏韩式只被调用一次
        ui:onHide()
        ui:setVisible(false)
    end
    self:_removeStackUI(ui)
    self:_removeCache(ui:getName())
    self:_updateStackUIVisible()

    if checkUnRecordLayer(ui:getName()) then
        return
    end
    if self._curUIName == ui:getName() then
        table.remove(self._uiNames, #self._uiNames)
        self._curUIName = #self._uiNames >= 1 and self._uiNames[#self._uiNames] or ""
    else
        for i, j in ipairs(self._uiNames) do
            if j == ui:getName() then
                table.remove(self._uiNames, i)
                break
            end
        end
    end
end

-- 加入UI栈
function UIManager:_addStackUI(ui)
    self:_removeStackUI(ui)
    table.insert(self._uiStack, ui)
end

-- 从UI栈中移除
function UIManager:_removeStackUI(ui)
    local index = table.indexof(self._uiStack, ui)
    if index then
        table.remove(self._uiStack, index)
    end
end

-- 优化drawcall,从当前栈顶UI往下查直到找到一个全屏的UI,全屏往下的UI全部隐藏
function UIManager:_updateStackUIVisible()
    local len = #self._uiStack
    local hideIndex = 0
    for i = len, 1, -1 do
        local ui = self._uiStack[i]
        ui:setVisible(true)
        if ui:isFullScreen() then
            hideIndex = i - 1
            break
        end
    end
    for i = 1, hideIndex do
        local ui = self._uiStack[i]
        ui:setVisible(false)
    end
end

--为显示的ui排序,默认UI都处在中间层
function UIManager:_addAndShowInUILayer(ui, ...)
    local layerLevel = ui:getGradeLayerLevel()
    assert(layerLevel >= UI_LEVEL.BottomMost and layerLevel <= UI_LEVEL.TopMost)
    --有连续show两次的情况,如UIReconnectTips
    self:_removeFromUILayer(ui)

    --设置默认的UI层级值 layerOrder从0开始往后排
    local layerOrder = #self._uiLayerList[layerLevel]
    ui:setLocalZOrder(layerOrder)

    -- 插入新的ui到层级ui记录
    table.insert(self._uiLayerList[layerLevel], ui)
    ui:setVisible(true)
    ui:onShow(...)

    --如果ui是弹窗,并且有panelContaner节点,那么播放动画
    if not ui:isFullScreen() then
        ui:playScaleAction()
    end
    return ui
end

--遍历删除记录的UI
function UIManager:_removeFromUILayer(ui)
    -- 直接遍历数组，清理该ui
    for i, v in ipairs(self._uiLayerList) do
        local index = table.indexof(self._uiLayerList[i], ui)
        if index then
            -- 删除UI
            table.remove(self._uiLayerList[i], index)
        end
    end
end

-- 将数据缓存，原本的写法有问题，没有考虑zorder的问题
function UIManager:_addCache(name, ...)
    local params = { ... }
    local index = table.indexof(self._uiNameLists, name)
    if index then
        -- 更新显示的顺序
        table.remove(self._uiNameLists, index)
        table.remove(self._uiParamsLists, index)
    end
    table.insert(self._uiNameLists, name)
    table.insert(self._uiParamsLists, params)
end

-- 如果界面在当前打开过后，并且关闭或者销毁了，从缓存中删除
function UIManager:_removeCache(name)
    local index = table.indexof(self._uiNameLists, name)
    if index then
        -- 更新显示的顺序
        table.remove(self._uiNameLists, index)
        table.remove(self._uiParamsLists, index)
    end
end

-- 查看界面是否显示
function UIManager:getIsShowing(name)
    local view = self:getUI(name)
    if nil ~= view then
        return view:isVisible()
    end
    return false
end

-- 查看界面是否在缓存
function UIManager:getIsInCache(name)
    local view = self:getUI(name)
    return view ~= nil
end

-- 销毁界面
function UIManager:destroy(name)
    local ui = self:getUI(name)
    if nil == ui then
        return
    end
    self:_removeStackUI(ui)
    self:_updateStackUIVisible()
    local index = table.indexof(self._uiStack, ui)
    -- 如果是由于优化drawcalls 而隐藏的，也要调一下onHide
    if index or ui:isVisible() then
        -- 如果没有隐藏, 先隐藏, 保证onHide的执行
        self:hide(name)
    else
        self:_removeFromUILayer(ui)
    end
    -- 销毁界面
    ui:onDestroy()
    ui:removeFromParent(false)
    self._uiMap[name] = nil
    self:_removeCache(name)
end

return UIManager