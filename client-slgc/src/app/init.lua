cc.exports.game = {}

local loadedNames = {}
local _require = require
require = function(path)
    loadedNames[path] = true
    return _require(path)
end
game.loadedNames = loadedNames

local UIConfig = require("app.configs.UIConfig")
cc.exports.__extendPath__ = function(filePath)
    --如果是绝对路径直接返回,否则拼接当前插件路径
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        return filePath
    end

    --通用UI存放处
    if UIConfig[filePath] then
        return UIConfig[filePath]
    end
    --非通用UI
    local statePath = game.GameFSM:getInstance():getCurrentStateDir()
    return string.format("%s.%s",statePath,filePath)
end

cc.exports.import = function(filePath)
    local path = __extendPath__(filePath)
    return require(path)
end



--输出类
game.Logger = require("app.common.Logger")
-- 工具类
game.Util = require("app.common.Util")
-- 事件中心
game.EventCenter = require("app.common.EventCenter")
-- 状态机
game.GameFSM = require("app.common.GameFSM")
-- 状态基类
game.GameStateBase = require("app.common.GameStateBase")
game.GameState_InGame = require("app.common.GameState_InGame")
-- 弹框管理
game.UIManager = require("app.common.UIManager")
-- 弹框基类
game.UIBase = require("app.common.UIBase")
-- 动画管理
game.UIAnimationManager = require("app.common.UIAnimationManager")
-- 提示框管理
game.UITipManager = require("app.common.UITipManager")
--音频管理
game.AudioManager = require("app.common.AudioManager")
-- 二维码生成工具
game.Qrencode = require("app.common.Qrencode")
-- 数据管理
game.ConfigManager = require("app.configs.ConfigManager")
--弹框管理
game.UIMessageBoxMgr = require("app.common.UIMessageBoxMgr")
--网络
game.NetWork = require("app.network.Connection").new()
game.HeartBeatPacketHandler = require("app.network.HeartBeatPacketHandler").new()

-- 通用UI组件
-- 重用列表(支持水平、竖直方向)
game.UITableView = require("app.common.UITableView")
-- 多行多列重用列表
game.UITableViewEx = require("app.common.UITableViewEx")
-- 多模板重用列表
game.UITableViewEx2 = require("app.common.UITableViewEx2")
--牌列表
game.UIHandCardList = require("app.common.UIHandCardList")

-- 重用列表单元格基类
game.UITableViewCell = require("app.common.UITableViewCell")
-- 散列表
game.UIFreeList = require("app.common.UIFreeList")
-- 散列表单元格基类
game.UIFreeListItem = require("app.common.UIFreeListItem")
-- 排序列表<动态更新元素的位置,隐藏的元素后移>
game.UISortListView = require("app.common.UISortListView")

game.UIXMLView = require("app.common.UIXMLView")
game.UIXMLText = require("app.common.UIXMLText")
game.UIXMLImageView = require("app.common.UIXMLImageView")
game.UIXMLCard = require("app.common.UIXMLCard")
game.UICheckBoxGroup = require("app.common.UICheckBoxGroup")

game.UIConstant = require("app.constants.UIConstant")


game.Languege = require("app.languege.zh_CN")


--公共服务类
game.BaiduLocationService = require("app.services.BaiduLocationService")
game.GVoiceService = require("app.services.GVoiceService")




--牌池
game.CardFactory = require("app.factory.CardFactory")