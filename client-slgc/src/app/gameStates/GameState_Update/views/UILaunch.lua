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
    if self._listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self._listener)
        self._listener = nil
        self._assetsManager:release()
    end
end

--创建更新器
function UILaunch:createAssetsManager()
    local storePath = cc.FileUtils:getInstance():getWritablePath() 
    self._storePath = storePath
    local manifestPath = storePath.."project.manifest"
    self._assetsManager = cc.AssetsManagerEx:create(manifestPath, storePath)
    self._assetsManager:retain()

    --获取本地manifest
    local manifest = self._assetsManager:getLocalManifest()
    self._listener = cc.EventListenerAssetsManagerEx:create(self._assetsManager, handler(self,self.onUpdateEvent))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self._listener, 1)
    
end

function UILaunch:onShow()
    Util:hide(self._loadingBar,self._imgLaunchMark,self._txtBmfValue)
    self._txtBmfState:setString(STATE.CHECK)
    self:setProgress(0)
    if device.platform == "android" or device.platform == "ios" then
        self:createAssetsManager()
        self._assetsManager:update()
    else
        game.GameFSM.getInstance():enterState("GameState_Login")
    end
end

function UILaunch:onUpdateEvent(event,code)
    local am = self.assets_manager
    local eventCode = code
    if event then
        eventCode = event:getEventCode()
    end

    if eventCode == EVENT_CODE.ERROR_NO_LOCAL_MANIFEST then
        Logger.debug("No local manifest file found, skip assets update.")
    elseif  eventCode == EVENT_CODE.UPDATE_PROGRESSION then
        local assetId = event:getAssetId()
        local percent = event:getPercent()
        local strInfo = ""

        if assetId == cc.AssetsManagerExStatic.VERSION_ID then
            Logger.debug('version 文件下载成功') 
        elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
            Logger.debug('manifest 文件下载成功')
        else
            Logger.debug('percent %f',percent)
            self:setProgress(percent)
        end
    elseif eventCode == EVENT_CODE.ERROR_DOWNLOAD_MANIFEST or 
           eventCode == EVENT_CODE.ERROR_PARSE_MANIFEST or 
           eventCode == EVENT_CODE.UPDATE_FAILED then
        self:processError(eventCode)

    elseif eventCode == EVENT_CODE.NEW_VERSION_FOUND then
        Logger.debug("NEW_VERSION_FOUND")
    elseif eventCode == EVENT_CODE.ERROR_UPDATING then
        Logger.debug("EVENT_CODE.ERROR_UPDATING ".. event:getAssetId())

    elseif eventCode == EVENT_CODE.ASSET_UPDATED then
        Logger.debug("EVENT_CODE.ASSET_UPDATED" .. event:getAssetId())

    elseif eventCode == EVENT_CODE.ERROR_DECOMPRESS then
        --解压失败  -->弹出提示解压失败  -->确定-->退出游戏
        game.ui.UIMessageBoxMgr.getInstance():show("解压失败", {"确定"},function()
		   os.exit(0)
        end)

    elseif eventCode == EVENT_CODE.ALREADY_UP_TO_DATE or eventCode == EVENT_CODE.UPDATE_FINISHED then
        --完成更新
        game.UIMessageBoxMgr:getInstance():dispose()
        game.UITipManager:getInstance():dispose()
        --之前所依赖的脚本都必须重新加载
        if eventCode == EVENT_CODE.UPDATE_FINISHED then
            Logger.debug("UPDATE_FINISHED")
            local moduleNameList = game.loadedNames or {}
            -- local skipModle = {
            --     ["string"] = true,
            --     ["crypt"] = true,
            --     ["bit"] = true,
            --     ["socket.core"] = true,
            --     ["math"] = true,
            --     ["socket"] = true,
            -- }
            for moduleName,_ in pairs(moduleNameList) do
                local fullPath = cc.FileUtils:getInstance():fullPathForFileName(moduleName)
                --如果没有全路径的话可能是些C++导入的表
                if fullPath then
                    print("清理module=>",moduleName)
                    package.loaded[moduleName] = nil
                end
            end
            package.loaded["main"] = nil
            package.loaded["config"] = nil
            package.loaded["cocos.init"] = nil
            package.loaded["app.init"] = nil
            cc.Director:getInstance():getTextureCache():removeAllTextures()
            require("main")
        else
            Logger.debug("ALREADY_UP_TO_DATE")
            game.GameFSM.getInstance():enterState("GameState_Login")
        end
    end

end

function UILaunch:setProgress(percent)
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

function UILaunch:processError(eventCode)
    if eventCode == EVENT_CODE.ERROR_DOWNLOAD_MANIFEST then
        self:onUpdateEvent(nil,EVENT_CODE.ALREADY_UP_TO_DATE)
    elseif eventCode == EVENT_CODE.UPDATE_FAILED then
        --部分文件下载成功
        
        game.ui.UIMessageBoxMgr.getInstance():show("下载失败,点击重新下载", { "确定" },
            function()
                self._assetsManager:downloadFailedAssets()
            end
        )
    else
        Logger.debug("processError code = " .. eventCode)
    end
end
--[[
        ERROR_NO_LOCAL_MANIFEST = 0, --本地manifest不存在
        ERROR_DOWNLOAD_MANIFEST = 1, --下载manifest失败
        ERROR_PARSE_MANIFEST = 2,    --解析manifest文件失败
        NEW_VERSION_FOUND = 3,  --当远端有新的版本时触发,触发两次(assert.manifest,version.manifest)
        ALREADY_UP_TO_DATE = 4, --当远端版本号小于等于当前版本号的时候触发
        UPDATE_PROGRESSION = 5, --更新中进度进行中
        ASSET_UPDATED = 6,      --新的zip开始下载的时候触发事件
        ERROR_UPDATING = 7,
        UPDATE_FINISHED = 8,    --更新完毕(解压也完毕)时调用 
        UPDATE_FAILED = 9,
        ERROR_DECOMPRESS = 10,  --解压失败 -->源码有修改:解压缩失败应该直接进入游戏，最起码能够保证下次热更可以接到
        NEW_PATCH_FOUND = 11,   --3.10 C++中已经没有这个事件了,但是lua表中并没有删掉
]]
return UILaunch