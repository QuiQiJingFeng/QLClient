local UIElemShareNode = class("UIElemShareNode")
local Version = require "app.kod.util.Version"
--[[
    1.此类是用来获取截图的node
    
    2.只用于此config.SHARE_TYPE.URL_IS_PIC_PATH分享类型
    
    3.shareType 分享类型  朋友  朋友圈  系统 比如以后的钉钉。。。
    
    4.data 是所需要的数据（每个类型所需要的数据不同 根据需求传参写方法）
    
    5.图片路径为字符串拼接的 比如art/guiyang/main/common.jpg
        art/guiyang 在地区文件中配置的
        main则是指大厅分享图片的文件夹名
        每个文件夹中必须要一个commom的图片
]]

-- 房间玩法分享的图片
local getShareRoomRule = function(shareType, tip, title, content, _local)
    local share = require("app.game.ui.UIShareRoomInfo").new()
    local filePath = string.format("%s/%s/%s.jpg", MultiArea.getShareImg(game.service.LocalPlayerService:getInstance():getArea()), _local, shareType)
    -- 如果没有就调用通用的图片
    if cc.FileUtils:getInstance():isFileExist(filePath) == false then
        ilePath = string.format("%s/%s/%s.jpg", MultiArea.getShareImg(game.service.LocalPlayerService:getInstance():getArea()), _local, "common")
    end

	share:onShow(tip, title, content, filePath)

    return share:getSharePannel()
end

-- 分享一个node中带一个更换的图片（可选的）的（比如：比赛分享奖状的图片）
local getShareCampaign = function(shareType, _local, panel, img)
    local filePath = string.format("%s/%s/%s.png", MultiArea.getShareImg(game.service.LocalPlayerService:getInstance():getArea()), _local, "common")
    if img then
        img:loadTexture(filePath)
    end

    return panel
end

-- 分享一张图片的（比如大厅分享图片）
local getShareMain = function(shareType, _local)
    local filePath = string.format("%s/%s/%s.jpg", MultiArea.getShareImg(game.service.LocalPlayerService:getInstance():getArea()), _local, "common")
    local sp = ccui.ImageView:create(filePath)

    return sp
end

-- 从哪里分享
function UIElemShareNode:getShare_local()
    local _local =
    {
        main = "main",
        campaign = "campaign",
        roomRule = "roomRule",
    }

    return _local
end

-- 获取截图的node
function UIElemShareNode:getShareNode(shareType, data)
    local node = ""
    if data._local == self:getShare_local().main then
        node = getShareMain(shareType, data._local)
    elseif data._local == self:getShare_local().campaign then
        node = getShareCampaign(shareType, data._local, data.panel, data.img)
    elseif data._local == self:getShare_local().roomRule then
        node = getShareRoomRule(shareType, data.tip, data.title, data.content, data._local)
    end

    return node
end


function UIElemShareNode:showShareUI( ... )
    -- 潮汕ios分享特殊处理一下
    if game.service.LocalPlayerService:getInstance():getArea() == 20001 then
        -- 有安全分享才调用这个UI界面
        local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
        if currentVersion:compare(Version.new("4.4.0.0")) >= 0 then
            UIManager:getInstance():show("UIShareSystemNew", ...)
            return
        end
    end
   
    UIManager:getInstance():show("UIShareSystem", ...)
end


return UIElemShareNode