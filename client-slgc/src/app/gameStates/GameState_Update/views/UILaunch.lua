local csbPath = "ui/csb/mengya/UILaunch.csb"
local super = game.UIBase
local Util = game.Util
-- 更新状态文本
local STATE = {
    CHECK = "获取版本更新中...",
    UPDATE = "正在更新，请稍后...",
    FINISH = "更新完毕，祝您游戏愉快",
    LOAD = "资源加载中...",
}
local EVENT_CODE = cc.EventAssetsManagerEx.EventCode
local UILaunch = class("UILaunch", super, function() return game.Util:loadCSBNode(csbPath) end)

local BAR_GLOW_MARGIN_X = 8
function UILaunch:ctor()
    self._loadingBar = Util:seekNodeByName(self, "loadingBar", "ccui.LoadingBar")
    self._imgLaunchMark = Util:seekNodeByName(self, "imgLaunchMark", "ccui.ImageView")
    self._txtBmfState = Util:seekNodeByName(self,"txtBmfState","ccui.TextBMFont")
    self._txtBmfValue = Util:seekNodeByName(self,"txtBmfValue","ccui.TextBMFont")
end

function UILaunch:getGradeLayerId()
    return 2
end

function UILaunch:isFullScreen()
    return true
end

function UILaunch:onHide()
end

--创建更新器
function UILaunch:createAssetsManager()
    local storePath = cc.FileUtils:getInstance():getWritablePath() .. "package/"
    release_print("storePath = ",storePath)
    local projectManifest = storePath.."project.manifest"
    local versionManifest = storePath.."version.manifest"
    self._assetsDownloader = game.AssetsDownloader.new(versionManifest,projectManifest,handler(self,self._onUpdateProcess),handler(self,self._onFinish))
end

function UILaunch:onShow()
    Util:hide(self._loadingBar,self._imgLaunchMark,self._txtBmfValue)
    self._txtBmfState:setString(STATE.CHECK)
    Util:hide(self._loadingBar,self._imgLaunchMark,self._txtBmfValue)
    if device.platform == "android" or device.platform == "ios" or device.platform == "mac" then
        self:createAssetsManager()
 
    else
        game.GameFSM.getInstance():enterState("GameState_Login")
    end
end

function UILaunch:_onFinish(greator)
    if greator then
        game.GameFSM.getInstance():enterState("GameState_Login")
        return
    end
    --完成更新
    game.UIMessageBoxMgr:getInstance():dispose()
    game.UITipManager:getInstance():dispose()
    local moduleNameList = game.loadedNames or {}
        local skipModle = {
            ["string"] = true,
            ["crypt"] = true,
            ["bit"] = true,
            ["socket.core"] = true,
            ["math"] = true,
            ["socket"] = true,
        }
        for moduleName,_ in pairs(moduleNameList) do
            --如果没有全路径的话可能是些C++导入的表
            if not skipModle[moduleName] then
                print("清理module=>",moduleName)
                package.loaded[moduleName] = nil
            end
        end
        package.loaded["app.GameMain"] = nil
        package.loaded["main"] = nil
        package.loaded["config"] = nil
        package.loaded["cocos.init"] = nil
        package.loaded["app.init"] = nil
        cc.Director:getInstance():getTextureCache():removeAllTextures()
        require("main")
end

function UILaunch:_onUpdateProcess(process)
    self:setProgress(process)
end

function UILaunch:setProgress(percent)
    percent = tonumber(percent)
    Util:show(self._loadingBar,self._imgLaunchMark,self._txtBmfValue)
    if percent >= 100 then
        self._txtBmfState:setString(STATE.FINISH)
    else
        self._txtBmfState:setString(STATE.UPDATE)
    end
    self._loadingBar:setPercent(percent)
    self._txtBmfValue:setString(tostring(percent))
    local box = self._loadingBar:getBoundingBox()
    local posX = box.x + box.width * percent * 0.01
    self._imgLaunchMark:setPositionX(posX)
end

return UILaunch