--[[
    一个简单的combobox实现
    @WARNNING:
    1.如果是自定义控件，也不要带可以接收事件的东西，这只是一个简单的伪popup
]]
local UIElemCombobox = class("UIElemCombobox", function() return cc.Node:create() end)

-- 暂时只实现上，下
UIElemCombobox.DIR = {
    UP = 1,
    DOWN = 2,
    LEFT = 3,
    RIGHT = 4
}

-- 默认的最大显示高度，超过的滑动显示吧
local MAX_HEIGHT = 200
-- 背景图的横向偏移
local BG_OFFSET_X = 0
-- 背景图的纵向偏移
local BG_OFFSET_Y = 0
-- 默认间距
local ITEM_MARGIN = 3

--[[
    @param layer 要显示combo的 ui层
    @param button 关联事件的按钮
    @param selectFunc 选中后的回调
    @param createFunc 创建时的回调
    @param updateFunc 更新时的回调
    @param lisBg 每个list的背景
]]
function UIElemCombobox:ctor(button, selectFunc, createFunc, updateFunc, listBg)
    self:setVisible(false)

    self._layer= button:getParent()
    self._layer:addChild(self)
    self._button = button
    if listBg == nil then
        self._listBgImage = "img/img_black2.png"
    else
        self._listBgImage = listBg
    end

    -- 根据当前按钮的大小，创建listview跟background
    -- background
    local rt = self._button:getBoundingBox()
    local size = cc.size(rt.width, rt.height)
    self._background = ccui.ImageView:create(self._listBgImage)
    self:addChild(self._background)
    self._background:setAnchorPoint(cc.p(0,1))
    self._background:setPosition(cc.p(-BG_OFFSET_X,BG_OFFSET_Y))
    self._background:setScale9Enabled(true)
    self._background:retain()

    -- listview
    self._listview = ccui.ListView:create()
    self:addChild(self._listview)
    self._listview:setContentSize(cc.size(size.width, 0))
    self._listview:setAnchorPoint(cc.p(0, 1))
    self._listview:setItemsMargin(ITEM_MARGIN)

    -- 保存相关回调
    self._selectFunc = selectFunc
    self._createFunc = createFunc
    self._updateFunc = updateFunc
    self._autoHideFunc = nil 

    -- 最大值，如果是完全的自定义控件时起作用
    self._maxNum = 0
    -- 当前选中的item索引
    self._selectIndex = 1
    -- 如果只是简单的文本，那么直接处理这个玩意就好了
    self._textArray = {}
    -- 默认向下展开
    self._dir = UIElemCombobox.DIR.DOWN

    -- 绑定相关事件
    bindEventCallBack(self._button, handler(self, self._onClickButton), ccui.TouchEventType.ended)
end

-- 初始化，如果是自定义控件显示，用这个初始化
function UIElemCombobox:initialize(max)
    self._maxNum = max
end

function UIElemCombobox:dispose()
    self._background:release()
    self:removeFromParent()
end

-- 更新背景图
function UIElemCombobox:setBackground(imgName)
    self._button:loadTexture(imgName)
end

-- 简单的文件处理，按数组插入对应的选项
function UIElemCombobox:setTextArray(array)
    self._textArray = array
    self._maxNum = #self._textArray
end

function UIElemCombobox:getText(index)
    return self._textArray[index]
end

-- 当前选中那一个了
function UIElemCombobox:getSelectIndex()
    return self._selectIndex
end

-- 方向相关
function UIElemCombobox:setDir(dir)
    if self._dir ~= dir then
        if dir == UIElemCombobox.DIR.UP then
            self._background:setAnchorPoint(cc.p(0, 0))
            self._listview:setAnchorPoint(cc.p(0, 0))
            self._background:setPosition(cc.p(-BG_OFFSET_X,-BG_OFFSET_Y))
        elseif dir == UIElemCombobox.DIR.DOWN then
            self._background:setAnchorPoint(cc.p(0, 1))
            self._listview:setAnchorPoint(cc.p(0, 1))
            self._background:setPosition(cc.p(-BG_OFFSET_X,BG_OFFSET_Y))
        end
        self._dir = dir
    end
end

function UIElemCombobox:getDir()
    return self._dir
end

function UIElemCombobox:_onClickButton()
    self:_regisiterTouch()

    self._listview:removeAllItems()
    self._listview:setScrollBarEnabled(false)

    -- 默认创建函数
    local defaultCreate = function(index)
        local item = ccui.Text:create()
        item:setFontSize(24)
        return item
    end
    -- 默认更新函数
    local defaultUpdate = function(wdt, index)
        if self._textArray[index] then
            wdt:setString(self._textArray[index])
        end
    end

    -- 根据简单文本或者最大数来创建相关item，并注册点击等相关事件
    local createFunc = self._createFunc or defaultCreate
    local updateFunc = self._updateFunc or defaultUpdate
    local size = self._listview:getContentSize()
    for i=1,(#self._textArray or self._maxNum) do
        local item = createFunc(i)
        -- 选中事件处理，整行选中的
        item:setTouchEnabled(true)
        -- item:setTextAreaSize(cc.size(size.width, 0))
        bindEventCallBack(item, function()
            if tolua.isnull(self) then return end
            if self._selectFunc then
                -- 如果是简单的纯文本，会自带着选中的文本
                -- 如果是自定控件的，请不要处理第二个参数
                self._selectFunc(i, self._textArray[i])
            end
            self._selectIndex = i
            -- 选中了，也应该隐藏掉了
            self:setVisible(false)
            -- 移除点击事件
            self._dispatcher:removeEventListener(self._listener)
        end, ccui.TouchEventType.ended)
        -- 更新显示的内容
        updateFunc(item, i)
        self._listview:addChild(item)
    end
    -- 更新listview
    self._listview:requestDoLayout()
    self._listview:doLayout()
    -- 同步listview跟背景的大小
    local size = self._listview:getInnerContainer():getContentSize()
    size.height = size.height <= MAX_HEIGHT and size.height or MAX_HEIGHT
    self._listview:setContentSize(size)
    self._background:setContentSize(cc.size(size.width+BG_OFFSET_X*2, size.height+BG_OFFSET_Y*2 +6))

    -- 计算显示的坐标点
    local pos = cc.p(self._button:getPosition())
    local anchor = self._button:getAnchorPoint()
    local rect = self._button:getBoundingBox()
    if self._dir == UIElemCombobox.DIR.UP then
        pos.x = pos.x - rect.width * anchor.x
        pos.y = pos.y + rect.height * (1-anchor.y)
    elseif self._dir == UIElemCombobox.DIR.DOWN then
        pos.x = pos.x - rect.width * anchor.x
        pos.y = pos.y - rect.height * anchor.y
    end
    self:setPosition(pos)
    self:setVisible(true)
end

-- 注册点击事件，只要点击的不是本身，那么只直接就隐藏掉本身
function UIElemCombobox:_regisiterTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    local dispatcher = self:getEventDispatcher()
    self._listener = listener
    self._dispatcher = dispatcher
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch)
        local location = touch:getLocation()
        location = self:convertToNodeSpace(location)
        if not cc.rectContainsPoint(self:getBoundingBox(), location) then
            return true
        end
        listener:setSwallowTouches(false)
        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch)
        local location = touch:getLocation()
        location = self:convertToNodeSpace(location)
        if not cc.rectContainsPoint(self:getBoundingBox(), location) then
            -- 点击到空白处的时候，应该要隐藏掉
            self:setVisible(false)
            dispatcher:removeEventListener(listener)
            if self._autoHideFunc then
                self._autoHideFunc()
            end
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function UIElemCombobox:setAutoHideCallback(callback)
    self._autoHideFunc = callback
end

return UIElemCombobox