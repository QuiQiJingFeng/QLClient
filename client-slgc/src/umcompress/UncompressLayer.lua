--------------------------------------------
-- 资源解压场景
--------------------------------------------
local Util = require("app.common.Util")
local csbPath = "ui/UIUcompress.csb"
local STATE = {
    UPDATE = "资源解压中，请稍后...",
    FINISH = "解压完毕",
    LOAD = "资源加载中...",
}
local UncompressLayer = class("UncompressLayer",function() return Util:loadCSBNode(csbPath) end)

function UncompressLayer:ctor()
    self:registerScriptHandler(function(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end)
end

function UncompressLayer:onEnter()
    self._loadingBar = Util:seekNodeByName(self, "loadingBar", "ccui.LoadingBar")
    self._imgLaunchMark = Util:seekNodeByName(self, "imgLaunchMark", "ccui.ImageView")
    self._txtBmfState = Util:seekNodeByName(self,"txtBmfState","ccui.TextBMFont")
    self._txtBmfValue = Util:seekNodeByName(self,"txtBmfValue","ccui.TextBMFont")
    self:setProgress(0)

    Util:scheduleOnce(function() 
        self:onShow()
    end,0)
end

function UncompressLayer:onShow()
    local writePath = cc.FileUtils:getInstance():getWritablePath()
    local projectPath = writePath .. "project.manifest"
    local content = cc.FileUtils:getInstance():getDataFromFile(projectPath)
    local projectInfo = json.decode(content)
    local assets = projectInfo.assets
    local skipAssets = {
        ["package/package_src.zip"] = true,
        ["package/package_res_ui_uncompress.zip"] = true
    }
    local totalNum = #table.values(assets) - #table.values(skipAssets)
    local index = 0
    for fileName, _ in pairs(assets) do
        local zipPath = "package/" .. fileName
        if not skipAssets[zipPath] then
            self:unzipFile(zipPath,writePath)
            index = index + 1
            self:setProgress(index/totalNum * 100)
        end
    end

    local testCase = require("test.init")
    require("app.GameMain").create(function() 
        testCase:run()
    end)
end

function UncompressLayer:unzipFile(zipPath,storePath)
    --call C
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
