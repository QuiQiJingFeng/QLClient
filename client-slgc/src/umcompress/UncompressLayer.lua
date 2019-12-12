--------------------------------------------
-- 资源解压场景
--------------------------------------------
local Util = require("Util")
local csbPath = "ui/uncompress/UIUcompress.csb"
local STATE = {
    UPDATE = "资源解压中，请稍后...",
    FINISH = "解压完毕",
    LOAD = "资源加载中...",
}

local UncompressLayer = class("UncompressLayer",function() 
    return Util:loadCSBNode(csbPath)
end)

function UncompressLayer:ctor(callFunc)
    self:registerScriptHandler(function(event)
        if "enter" == event then
            self:onEnter(callFunc)
        elseif "exit" == event then
            self:onExit()
        end
    end)
end

function UncompressLayer:onEnter(callFunc)
    self._loadingBar = Util:seekNodeByName(self, "loadingBar", "ccui.LoadingBar")
    self._imgLaunchMark = Util:seekNodeByName(self, "imgLaunchMark", "ccui.ImageView")
    self._txtBmfState = Util:seekNodeByName(self,"txtBmfState","ccui.TextBMFont")
    self._txtBmfValue = Util:seekNodeByName(self,"txtBmfValue","ccui.TextBMFont")
    self:setProgress(0)

    Util:scheduleOnce(function() 
        self:onShow(callFunc)
    end,0)
end

function UncompressLayer:onShow(callFunc)
    local writePath = cc.FileUtils:getInstance():getWritablePath()
    local projectPath = writePath .. "project.manifest"
    local content = cc.FileUtils:getInstance():getDataFromFile(projectPath)
    local assets = {}
    local iter = string.gmatch(content,'([%w_]+).zip')
    for name in iter do
        table.insert(assets,name .. ".zip")
    end

    --这几个zip包能保证解压过场动画能够顺利进行
    local skipAssets = {
        ["package/package_src.zip"] = true,
        ["package/package_src_uncompress.zip"] = true,
        ["package/package_res_ui_uncompress.zip"] = true,
    }
    local totalNum = #assets - #table.values(skipAssets)
    local index = 0
    for _, fileName in ipairs(assets) do
        local zipPath = "package/" .. fileName
        if not skipAssets[zipPath] then
            if self:unzipFile(zipPath,writePath) then
                Logger.debug("unzipFile [%s]",zipPath)
                index = index + 1
                self:setProgress(index/totalNum * 100)
            end
        end
    end
    if callFunc then
        callFunc()
    end
    self:removeFromParent()
end

function UncompressLayer:unzipFile(zipPath,storePath)
    return FYDC.excute("Utils","unzipFile",zipPath,storePath)
end

function UncompressLayer:setProgress(percent)
    percent = tonumber(string.format("%.1f",percent))
    if not self._percent or self._percent < percent and self._percent < 100 then
        self._percent = percent
    else
        return
    end
    Util:show(self._loadingBar,self._imgLaunchMark,self._txtBmfValue)
    if percent >= 100 then
        self._txtBmfState:setString(STATE.FINISH)
    else
        self._txtBmfState:setString(STATE.UPDATE)
    end
    self._loadingBar:setPercent(percent)
    self._txtBmfValue:setString(string.format("%.1f%%", percent))
    local box = self._loadingBar:getBoundingBox()
    local posX = box.x + box.width * percent * 0.01
    self._imgLaunchMark:setPositionX(posX)
end

function UncompressLayer:onExit()

end

return UncompressLayer
