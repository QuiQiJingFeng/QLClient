-----------------------------------------------------------------------------------
-- 单个文件记录，用来判断是否指定显示一个界面
local UIClubElemRecommendSave = class("UIClubElemRecommendSave")

function UIClubElemRecommendSave:ctor()
    self._filepath = cc.FileUtils:getInstance():getAppDataPath().."/TMP_CONFIG"
    self._key = "NoticeLastSelect"
end

local _noticeSaver = nil
function UIClubElemRecommendSave:getInstance()
    if not _noticeSaver then
        _noticeSaver = UIClubElemRecommendSave.new()
    end
    return _noticeSaver
end

function UIClubElemRecommendSave:getLastSelected()
    -- 默认显示第一页
    local index = nil
    if cc.FileUtils:getInstance():isFileExist(self._filepath) then
        local file = io.open(self._filepath, "rb")
        local buffer = file:read "*a"
        file:close()
        -- 线上解码的时候，有报错的情况，添加一下保护
        local succ, __json = pcall(json.decode, buffer)
        if succ then
            __json = type(__json) == "table" and __json or {}
            index = tonumber(__json[self._key])
        end
    end
    if not index then
        index = 1
    end
    -- 用完之后立马删除，一次性使用
    -- self:saveLastSelected(nil)
    return index
end

function UIClubElemRecommendSave:saveLastSelected(index)
    local __json = nil
    local buffer = nil
    if cc.FileUtils:getInstance():isFileExist(self._filepath) then
        local file = io.open(self._filepath, "rb")
        local buffer = file:read "*a"
        file:close()
        local succ = false
        succ, __json = pcall(json.decode, buffer)
    end

    __json = type(__json) == "table" and __json or {}
    __json[self._key] = index
    buffer = json.encode(__json)
    local file = io.open(self._filepath, "wb")
    file:write(buffer)
    file:close()
end

-----------------------------------------------------------------------------------
-- 按钮控件支持
-- 扩展可以显示的点击按钮
local UIElemButton = class("UIElemButton", function(normalImage, selectedImage, disableImage, texType)
    return ccui.Button:create(normalImage, selectedImage, disableImage, texType or ccui.TextureResType.localType)
end)

-- 构造，最后全部不要为空
--[[
    @param normalImage 正常图片
    @param selectedImage 选中图片
    @param disableImage 禁用图片
    @param texType 图片的类型 ccui.TextureResType.localType, ccui.TextureResType.plistType
    @param callback 点击的回调
]]
function UIElemButton:ctor(normalImage, selectedImage, disableImage, texType, callback)
    self._callback = callback
    if self._callback then
        bindEventCallBack(self, self._callback, ccui.TouchEventType.ended)
    end
end

-----------------------------------------------------------------------------------
-- 图片控件支持
-- 公告内的一个图片控件
local UIElemImage = class("UIElemImage", function() return ccui.Layout:create() end)

-- 先加载一个本地图片，如果有远程图片，下载完成后，加载
--[[
    @param size 当前组件的大小
    @param conf 当前的配置，对于图来说 content是本地图片，cntent_ext是远程图片
    @param button 当前组件是不是使用button
    @param selfCallback 本身是否支持点击，如果有回调就是支持
]]
function UIElemImage:ctor(size, conf, button, selfCallback)
    -- 先设置自身大小
    self:setContentSize(size)
    self._conf = conf
    -- 加载图片，必须有
    self._image = ccui.ImageView:create(self._conf.content)
    self._image:setPosition(cc.p(size.width/2, size.height/2))
    self._image:ignoreContentAdaptWithSize(false)
    self._image:setContentSize(size)
    self:addChild(self._image)
    -- 如果有GMT配置图片，下载完成后替换
    if self._conf.content_ext then
        -- tolua.isnull()
        game.util.PlayerHeadIconUtil.setIcon(self._image, self._conf.content_ext)
    end

    -- 如果有按钮，可以上中下显示？
    self._button = button
    if self._button then
        self._button:setAnchorPoint(cc.p(0.5, 0.5))
        self._button:setPosition(cc.p(size.width/2, size.height))
        self:addChild(self._button)
    end

    -- 本身是否支持点击
    self._selfCallback = selfCallback
    if self._selfCallback then
        self:setTouchEnabled(true)
        bindEventCallBack(self, self._selfCallback, ccui.TouchEventType.ended)
    end
end

-----------------------------------------------------------------------------------
-- 可滑动文本控件支持
local UIElemTextScroll = class("UIElemTextScroll", function() return ccui.Layout:create() end)

--[[
    @param size 当前组件的大小
    @param conf 当前的配置，对于当前来说 content是要显示的文本内容, content_ext字号
    @param button 当前组件是不是使用button
    @param selfCallback 本身是否支持点击，如果有回调就是支持
]]
function UIElemTextScroll:ctor(size, conf, button, selfCallback)
    -- 先设置自身大小
    self:setContentSize(size)
    self._conf = conf
    -- 滑动框初始化
    self._scrollView = ccui.ScrollView:create()
    self._scrollView:setContentSize(size)
    self:addChild(self._scrollView)

    -- 加载文本，必须有
    self._text = ccui.Text:create()
    self._text:setContentSize(size)
    self._text:setPosition(cc.p(size.width/2, size.height/2))
    self._text:setFontSize(self._conf.content_ext)
    self._scrollView:addChild(self._text)

    self._text:setString(self._conf.content)
	self._text:ignoreContentAdaptWithSize(false)
    self._text:setTextAreaSize(cc.size(size.width, 0))
    self._text:setAnchorPoint(cc.p(0.5, 1))
	local realSize = self._text:getVirtualRendererSize()
	self._text:setContentSize(cc.size(size.width, realSize.height))

	self._scrollView:setInnerContainerSize(cc.size(size.width, realSize.height))
	if self._scrollView:getContentSize().height < realSize.height then
		self._text:setPositionY(realSize.height)
	else
		self._text:setPositionY(size.height)
	end	
    -- 如果有按钮，可以上中下显示？
    self._button = button
    if self._button then
        self._button:setAnchorPoint(cc.p(0.5, 0.5))
        self._button:setPosition(cc.p(size.width/2, size.height))
        self:addChild(self._button)
    end

    -- 本身是否支持点击
    self._selfCallback = selfCallback
    if self._selfCallback then
        self:setTouchEnabled(true)
        bindEventCallBack(self, self._selfCallback, ccui.TouchEventType.ended)
    end
end

-----------------------------------------------------------------------------------
-- 文本控件支持
local UIElemText = class("UIElemText", function() return ccui.Layout:create() end)

--[[
    @param size 当前组件的大小
    @param conf 当前的配置，对于当前来说 content是要显示的文本内容, content_ext字号
    @param button 当前组件是不是使用button
    @param selfCallback 本身是否支持点击，如果有回调就是支持
]]
function UIElemText:ctor(size, conf, button, selfCallback)
    -- 先设置自身大小
    self:setContentSize(size)
    self._conf = conf
    -- 加载文本，必须有
    self._text = ccui.Text:create()
    self._text:setContentSize(size)
    self._text:setPosition(cc.p(size.width/2, size.height/2))
    self._text:setFontSize(self._conf.content_ext)
    self:addChild(self._text)

    self._text:setString(self._conf.content)
	self._text:ignoreContentAdaptWithSize(false)
	self._text:setTextAreaSize(cc.size(size.width, size.height))
	local s = self._text:getVirtualRendererSize()
	self._text:setContentSize(cc.size(size.width, s.height))

    -- 如果有按钮，可以上中下显示？
    self._button = button
    if self._button then
        self._button:setAnchorPoint(cc.p(0.5, 0.5))
        self._button:setPosition(cc.p(size.width/2, size.height))
        self:addChild(self._button)
    end

    -- 本身是否支持点击
    self._selfCallback = selfCallback
    if self._selfCallback then
        self:setTouchEnabled(true)
        bindEventCallBack(self, self._selfCallback, ccui.TouchEventType.ended)
    end
end

-----------------------------------------------------------------------------------
-- 现在来说，这里写死了三个标签页，UI上也是这样做的
-- 标签控件支持
local UIElemTab = class("UIElemTab")

-- 关联控件
function UIElemTab.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemTab)
	self:_initialize(tabs)
    return self
end

-- 初始化相关控件
function UIElemTab:_initialize()
    self._items = {}
    self._names = {}
    for i = 1, 3 do 
        self._items[i] = seekNodeByName(self, "checkNotice" .. i, "ccui.CheckBox")
        self._items[i]:setVisible(false)
        self._names[i] = seekNodeByName(self._items[i], "BitmapFontLabel", "ccui.TextBMFont")
    end 
    Macro.assertTrue(#self._items == 0, "UIElemTab inited failed")
end

-- 激活一个控件
-- 当前来说，就是显示一个控件来，并处理相关事件
function UIElemTab:active(index, name, callback)
    if index < 1 or index > 3 then
        Macro.assertTrue(true, "UIElemTab:active index error is "..torstirng(index))
    end

    self._items[index]:setVisible(true)
    self._names[index]:setString(name)
    local isSelected = false
    self._items[index]:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = self._items[index]:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            self._items[index]:setSelected(true)
            callback()
        elseif eventType == ccui.TouchEventType.canceled then
            self._items[index]:setSelected(isSelected)
        end
    end)
end

-- 选中一个标签
function UIElemTab:select(index)
    if index < 1 or index > 3 then
        Macro.assertTrue(true, "UIElemTab:select index error is "..torstirng(index))
    end

    for i,v in ipairs(self._items) do
        v:setSelected(false)
    end
    self._items[index]:setSelected(true)
    self._currIndex = index
end

-----------------------------------------------------------------------------------
-- 指示器控件支持
local UIElemIndicator = class("UIElemIndicator")

-- 关联控件
function UIElemIndicator.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemIndicator)
	self:_initialize(tabs)
    return self
end

-- 初始化，本控件基础是listview，图省事
-- 子控件是checkbox，用以标记选中状态
function UIElemIndicator:_initialize()
    self._listItem = seekNodeByName(self, "checkbox_Indicator", "ccui.CheckBox")
    if self._listItem then
        self._listItem:removeFromParent()
        self:getParent():addChild(self._listItem)
        self._listItem:setVisible(false)
    else
        self._listItem = seekNodeByName(self:getParent(), "checkbox_Indicator", "ccui.CheckBox")
        Macro.assertTrue(self._listItem == nil, "ERROR[Cannot find \"checkbox_Indicator\"]")
    end
    self:clear()
end

-- 洗加一个指示器，根据pageview的个数相应add
function UIElemIndicator:addOne()
    local item = self._listItem:clone()
    item:setTouchEnabled(false)
    item:setVisible(true)
    self:addChild(item)
    table.insert(self._items, item)

    local size = self:getContentSize()
    local itemsize = item:getContentSize()
    local space = 5
    self:setItemsMargin(space)
    local num = #self._items
    size.width = num*itemsize.width + (num > 1 and (num-1)*space or 0)
    self:setContentSize(size)
end

function UIElemIndicator:clear()
    self._items = {}
    self._currIndex = nil
    self:removeAllItems()
end

-- 选中一个指示器
function UIElemIndicator:select(index)
    if self._currIndex ~= index then
        if index < 1 or index > #self._items then
            Macro.assertTrue(true, "UIElemIndicator index error is "..torstirng(index))
        end

        for _,v in ipairs(self._items) do
            v:setSelected(false)
        end
        self._items[index]:setSelected(true)
        self._currIndex = index
    end
end

-----------------------------------------------------------------------------------
--[[
    @param tp 当前的配置类型，详见 ELEM_TYPE
    @param content 要显示的内容，如果是image，就是image的图片 路径，如果是文字，就是显示的文字内容
    @param content_ext 扩展显示内空，现在只有image类型有用，是用来处理，远程图片的
]]
local function MAKE_CONF(tp, title, content, content_ext)
    return {type= tp, title=title, content=content, content_ext=content_ext}
end

-- 支持的类型，未必全部都用到
local NOTICE_CONFS = {
    ELEM_TYPE = {
        IMAGE = 1,
        TEXT = 2,
        IMAGE_WITH_BUTTON = 3,
        TEXT_WITH_BUTTON = 4,
    },
    data = {}
}

-- 通过gmt配置来处理显示，现在未完成
function NOTICE_CONFS.fromProtocol(data)
    NOTICE_CONFS.data = {}
    for k, v in ipairs(data) do
        table.insert(NOTICE_CONFS.data, MAKE_CONF(v.tp, v.title, v.content, v.content_ext))
    end
    return NOTICE_CONFS.data
end
 
-- 客户端本地配置
function NOTICE_CONFS.fromConfig()
    NOTICE_CONFS.data = {
        MAKE_CONF(NOTICE_CONFS.ELEM_TYPE.IMAGE, "", "club/img_tc1.png", nil),
        MAKE_CONF(NOTICE_CONFS.ELEM_TYPE.IMAGE, "", "club/img_tc2.png", nil),
        MAKE_CONF(NOTICE_CONFS.ELEM_TYPE.IMAGE_WITH_BUTTON, "", "club/img_tc3.png", nil),
    }
    return NOTICE_CONFS.data
end

-----------------------------------------------------------------------------------
--[[
    本lua的主类，实现一个pageview，并关联相关标签，已经指示器
]]
local UIClubElemRecommend = class("UIClubElemRecommend")

--[[
-- 关联控件,需要一并关联其上的标签页
    @param self 要关联的pageview，注意类型不要错了
    @param tabs 要关联的标签页，现在固定名字的3个控件，不是动态创建的
    @param indicator 要关联的指示器，动态创建的
]]
function UIClubElemRecommend.extend(self, tabs, indicator)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIClubElemRecommend)
	self:_initialize(tabs, indicator)
    return self
end

-- 初始化子组件，相关参数看上面
function UIClubElemRecommend:_initialize(tabs, indicator)
    -- 上方的扩展标签页，因为两者是息息相关的，所以放在了一块，如果以后不同的需求，可以扩展其它的
    self._currIndex = nil
    self._maxIndex = nil
    self._tabs = tabs and UIElemTab.extend(tabs) or nil
    self._indicator = indicator and UIElemIndicator.extend(indicator) or nil
    self:removeAllItems()

    -- 初始设置
    self:setDirection(ccui.PageViewDirection.HORIZONTAL)

    if self._indicator then
        -- 如果使用了自定义的指示器
        self:setIndicatorEnabled(false)
    else
        self:setIndicatorEnabled(true)
        -- self:setIndicatorSpaceBetweenIndexNodes(5)
        self:setIndicatorIndexNodesTexture("img/green_edit.png")
        self:setIndicatorIndexNodesScale(1)
        self:setIndicatorIndexNodesColor(cc.WHITE)
        self:setIndicatorSelectedIndexColor(cc.WHITE)
    end
end

function UIClubElemRecommend:_clear()
    if self._indicator then
        self._indicator:clear()
    end
    self:removeAllPages()
    self._currIndex = nil
    self:setCurrentPageIndex(-1)
end

--[[
    为了配合统计，修改了部分事件，点击正在展示的标签页，可以重复触发
    TD数据结构：
    index 当前的标签页
    title 当前的标签页名
    userid 当前的上报人id
]]
function UIClubElemRecommend:_makeTDData(index)
    return {
        index = index,
        title = self._conf[index].title,
        userid = game.service.LocalPlayerService:getInstance():getRoleId()
    },game.service.LocalPlayerService:getInstance():getIsNewPlayer()
end

-- 根据配置加载界面
function UIClubElemRecommend:load(conf, callbacks)
    -- #conf or max 3?
    self:_clear()
    callbacks = callbacks or {}
    local size = self:getContentSize()
    self._conf = conf
    self._maxIndex = #conf
    for i=1,#conf do
        local item = nil
        -- 统计 数据结构
        local callbackall = function()
            local data, isnewer = self:_makeTDData(i)
            -- 素材点击事件
            -- game.service.TDGameAnalyticsService.getInstance():onEvent("EVENT_CLICKED_MATERIAL_" .. tostring(i) .. (isnewer and "_NEW" or ""), data)
            if callbacks[i] then
                callbacks[i]()
            end
        end
        if conf[i].type == NOTICE_CONFS.ELEM_TYPE.IMAGE then
            item = UIElemImage.new(size, conf[i], nil, callbackall)
        elseif conf[i].type == NOTICE_CONFS.ELEM_TYPE.TEXT then
            item = UIElemText.new(size, conf[i], nil, callbackall)
        elseif conf[i].type == NOTICE_CONFS.ELEM_TYPE.IMAGE_WITH_BUTTON then
            item = UIElemImage.new(size, conf[i], UIElemButton.new("img/Btn_yellow01.png", "img/Btn_yellow0.png", "img/Btn_yellow0x.png"), callbackall)
        elseif conf[i].type == NOTICE_CONFS.ELEM_TYPE.TEXT_WITH_BUTTON then
            item = UIElemText.new(size, conf[i], UIElemButton.new("img/Btn_yellow01.png", "img/Btn_yellow0.png", "img/Btn_yellow0x.png"), callbackall)
        end

        -- 添加标签页，点击关联事件
        if self._tabs then
            self._tabs:active(i, conf[i].title, function()
                if self:getCurrentPageIndex() + 1 ~= i then
                    self:scrollToPage(i-1)
                    -- self._tabs:select(i)
                    self:select(i)
                    local data, isnewer = self:_makeTDData(i)
                    -- tab点击事件
                    -- game.service.TDGameAnalyticsService.getInstance():onEvent("EVENT_CLICKED_TAB" .. (isnewer and "_NEW" or ""), data)
                end
            end)
        end
        if self._indicator then
            self._indicator:addOne()
        end
        self:addChild(item)
    end

    self:addEventListener(function(sender, event)
        local index = sender:getCurrentPageIndex()+1
        self:select(index)
    end)

    -- 添加pageview的实时监听
	self:getInnerContainer():scheduleUpdateWithPriorityLua(function(dt)
        local size = self:getInnerContainer():getContentSize()
        local x,y = self:getInnerContainer():getPosition()
        local width = size.width / self._maxIndex
        local index = (-x/width+1)+((-x%width >= width/2 and 1 or 0))
        index = math.floor( index )
        self:_connectComponent(index)
	end, 0)

    -- 默认选中第一个
    local last = UIClubElemRecommendSave:getInstance():getLastSelected()
    self:select(last <= #conf and last or 1)
    scheduleOnce(function()
        self:setCurrentPageIndex(last-1)
    end, 0)
end

function UIClubElemRecommend:show()
    if self._tabs then
        self._tabs:setVisible(true)
    else
        self:setVisible(true)
        if self._indicator then
            self._indicator:setVisible(true)
        end
    end
end

function UIClubElemRecommend:hide()
    if self._tabs then
        self._tabs:setVisible(false)
    else
        self:setVisible(false)
        if self._indicator then
            self._indicator:setVisible(false)
        end
    end
end

-- 选中事件
function UIClubElemRecommend:select(index)
    if self._currIndex == index then return end
    local data, isnewer = self:_makeTDData(index)
    -- 展示的事件
    -- game.service.TDGameAnalyticsService.getInstance():onEvent("EVENT_SHOW_MATERIAL" .. (isnewer and "_NEW" or ""), data)
    self._currIndex = index

    self:_connectComponent(index)

    -- 保存一下临时值，从其它界面恢复回来的时候，回复
    UIClubElemRecommendSave:getInstance():saveLastSelected(index)

    -- 每切换一页后，开启一个5秒的倒计时
    self:stopAllActions()
	local delayAction = cc.DelayTime:create(5)
    local callFuncAction = cc.CallFunc:create(function()
        local next = self._currIndex + 1
        next = next > self._maxIndex and 1 or next
        self:scrollToPage(next-1)
        self:select(next)
        local data, isnewer = self:_makeTDData(next)
        -- 滑动事件
        -- game.service.TDGameAnalyticsService.getInstance():onEvent("EVENT_AUTOSCROLL_MATERIAL" .. (isnewer and "_NEW" or ""), data)
    end)
    local seq = cc.Sequence:create(delayAction, callFuncAction)
	self:runAction(seq)
end

function UIClubElemRecommend:_connectComponent(index)
    -- 同步指示器
    if self._indicator then
        self._indicator:select(index)
    end
    if self._tabs then
        self._tabs:select(index)
    end
end

-- 配置文件当做孩子传入
UIClubElemRecommend.NOTICE_CONFS = NOTICE_CONFS

return UIClubElemRecommend