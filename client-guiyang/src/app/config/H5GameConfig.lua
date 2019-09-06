--[[
H5游戏加载的方式：
1、通过H5AppKey去向服务器请求Url
2、WebView加载Url后就自动跑了
3、充值的方式也在服务器的对应响应中。

目前的局限：
1、H5游戏的图片是客户端开发每次手动更新去添加
2、H5游戏的添加或者删除都需要客户端开发手动去修改。

优化后的方案， H5游戏远程配置方案：
1、添加一个消息对，用来请求当前H5游戏的配置
2、客户端根据这些配置来动态的获得H5游戏图片与AppKey

获得的数据结构类似于：
[
  {
    imgUrl: "xxx.png",
    appKey: "xxxx",
    h5name: "xxxx",
  },
]

基于目前客户端UI展现形式
H5游戏顺序：先从上到下。再从左至右（例外：第一页的第一排永远是金币场合比赛场）

如下所示：

金币场 比赛场 游戏C
游戏A  游戏B 游戏D
]]

local Version = require("app.kod.util.Version")
local function isNewVersion()
    if game.plugin.Runtime.isEnabled() == false then
        -- 支持模拟器测试
        return true;
    end
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    local supportVersion = Version.new("4.9.0")
    return currentVersion:compare(supportVersion) >= 0;
end

-- 是否为浏览器打开的链接
local linkTbl = { "http://", "https://" }
local function isLink(appKey)
    appKey = string.trim(appKey)
    for _, str in ipairs(linkTbl) do
        if str == appKey:sub(1, #str) then
            return true
        end
    end
    return false
end

local UtilsFunctions = require("app.game.util.UtilsFunctions")
local H5GameConfig = wrap_class_namespace("config", class("H5GameConfig"))

local t_existed = {} -- csb 中原本就存在的， 会以第一个为复制模板
local t_copied = {} -- 通过配置复制而来的

function H5GameConfig:setH5GameConfig(data)
    self._data = data
    event.EventCenter:dispatchEvent({ name = "H5_GAME_CONFIG_REFRESHED" })

    local mainUI = UIManager:getInstance():getUI("UIMain")
    if mainUI and mainUI:isVisible() then
        self:refresh(mainUI)
    end
end

function H5GameConfig:getH5GameConfig()
    return self._data
end

-- 每次进入主界面 和 每次刷新的时候调用
function H5GameConfig:refresh(mainUI)
    if self._data then
        self:initGameItems(mainUI)
    end
end

function H5GameConfig:initGameItems(mainUI)
    local view = seekNodeByName(mainUI, "H5Game_ScrollView")
    Macro.assertFalse(view, "not found scroll view in main UI")

    self:deleteAllCopied()
    self:findExisted(view)
    self:loadConfig()

    local viewSize = view:getContentSize()
    local itemSize = t_existed[1]:getChildByName("Image"):getContentSize()
    viewSize.width = #t_copied * itemSize.width
    view:setInnerContainerSize(viewSize)
end

function H5GameConfig:deleteAllCopied()
    for _, item in ipairs(t_copied) do
        if not tolua.isnull(item) then
            item:removeFromParent()
        end
    end
    t_copied = {}
end

function H5GameConfig:findExisted(view)
    t_existed = {}
    for _, item in ipairs(view:getChildren()) do
        if not item.isCopied then
            --Logger.debug(self.__cname .. " findExisted " .. item:getName())
            table.insert(t_existed, item)
        end
    end
end

function H5GameConfig:loadConfig()
    if self._data then
        --Logger.dump(self._data, "H5GameConfig:loadConfig")
        for _, cfg in ipairs(self._data) do
            local item = self:cloneItem()
            table.insert(t_copied, item)
            --Logger.debug(self.__cname .. " loadConfig " .. cfg.h5name)
            item.isCopied = true
            item.name = cfg.h5name
            item.imgUrl = cfg.imgUrl
            self:bindItem(item, cfg)
        end

        self:reposition()
    end
end

function H5GameConfig:cloneItem()
    local template = t_existed[1]
    local ret = template:clone()
    template:getParent():addChild(ret)

    return ret
end


--[[
 c1   c2

|[1G] [3C]| 5   7  -- row 1
| 2     4 | 6   8  -- row 2

AP (0, 0)
size (230, 165)
container_size (460, 340)
高 间隙 5px
宽 间隙 0px
]]

-- 重新排序
function H5GameConfig:reposition()
    local size = t_existed[1]:getChildByName("Image"):getContentSize()
    local ap = t_existed[1]:getAnchorPoint()
    -- 锚点非0的偏移
    local apOffset = cc.p(ap.x * size.width, ap.y * size.height)
    local count = #t_existed + #t_copied
    local t_pos = {}
    local rowCount = 1
    -- 根据两行N列的方式， 先列好所有的位置
    for i = 1, count do
        local row = (rowCount - i % rowCount)
        local column = math.ceil(i / rowCount)
        t_pos[i] = {
            x = (column - 1) * size.width + apOffset.x,
            y = (rowCount - row) * size.height + apOffset.y + (row - 1) * 5 -- 5 为间隙
        }
    end

    -- 默认已存在的第一项与第二项 是在 1　3 的位置
    local t = {
        --t_existed[1],
        t_copied[1],
        --t_existed[2],
    }

    for i = 2, #t_copied do
        table.insert(t, t_copied[i])
    end

    for idx, item in ipairs(t) do
        local p = t_pos[idx]
        item:setPosition(p)
        --printf("name %s, p (%s, %s), imgUrl %s", item.name or "btn", p.x, p.y, item.imgUrl or "")
    end
end

function H5GameConfig:bindItem(node, value)
    local image = seekNodeByName(node, "Image")
    UtilsFunctions.loadTextureAsync(image, value.imgUrl, "")
    bindTouchEventWithEffect(node, function()
        self:openH5Game(value)
        game.service.DataEyeService.getInstance():onEvent(value.h5name)
    end, 1.03)
end

function H5GameConfig:openH5GameByName(h5Name, openScene)
    if h5Name and h5Name ~= "" and self._data then
        for _, item in ipairs(self._data) do
            if item.h5name == h5Name or item.h5name:sub(1, #h5Name) == h5Name then
                self:openH5Game(item)
                local key = h5Name
                if openScene then
                    key = key .. "_" .. openScene
                end
                game.service.DataEyeService.getInstance():onEvent(key)
                return true
            end
        end
    end
    return false
end

function H5GameConfig:openH5Game(value)
    if isLink(value.appKey) then
        cc.Application:getInstance():openURL(value.appKey)
    elseif device.platform == "windows" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("windows 不支持" .. value.h5name)
    elseif not isNewVersion() and device.platform == "android" then
        game.ui.UIMessageBoxMgr.getInstance():show("更新到最新版本即可体验！" .. value.h5name, { "立即更新", "取消" },
                function()
                    local downloadUrl = config.GlobalConfig.getDownloadUrl();
                    cc.Application:getInstance():openURL(config.GlobalConfig.SHARE_HOSTNAME .. downloadUrl)
                    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_Setting_Update)
                end, function()
                end, false, true)
    else
        h5sdk.getInstance():login(value.appKey)
    end
end