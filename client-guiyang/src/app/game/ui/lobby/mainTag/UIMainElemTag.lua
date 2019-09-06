--[[0
    主界面按钮标签管理工具，通过GMT发来的消息，控制主界面中几个按钮的tag显示与修改。
    目前直接的按钮有： 俱乐部，创建房间，金币场，比赛场
    tag的位置：左下角或者右上角，tag在同一时间段只会显示一个

    控件要求： 在主界面的对应的按钮中，会有两个特殊命名的控件
    命名要求： Tag_1 Tag_2 Tag_xx
]]
local UIMainElemTag = class("UIMainElemTag")
local UtilsFunctions = require("app.game.util.UtilsFunctions")

local mainTagData = require("app.game.ui.lobby.mainTag.MainTagData")
UIMainElemTag.ButtonId = mainTagData.ButtonId

function UIMainElemTag:ctor()
	self._tagsMap = {}
end

function UIMainElemTag:appendTag(node, buttonId)
    if Macro.assertFalse(buttonId, 'buttonId error! type is ' .. tostring(buttonId)) then
        local tags = {}
        for pos = 1, 999, 1 do
            local tag = seekNodeByName(node, "Tag_" .. pos, "ccui.ImageView")
            if tag then
                tag:hide()
                tags[pos] = tag
            else
                break
            end
        end
        self._tagsMap[buttonId] = tags
    end
end

function UIMainElemTag:show()
	game.service.ActivityService.getInstance():addEventListener("EVENT_MAIN_TAG_CHANGE", handler(self, self._tagChange), self)
	self:_tagChange()
end

function UIMainElemTag:hide()
	game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end

function UIMainElemTag:_tagChange()
    local showData = mainTagData:getShowData()
    
    -- 先隐藏
    for key, tags in ipairs(self._tagsMap) do
        for _, tag in ipairs(tags) do
            tag:hide()
        end
    end

    -- 在根据数据显示
    for _, tagData in ipairs(showData) do
        local tags = self._tagsMap[tagData.buttonId]
        if tags then
            local tag = tags[tagData.position]
            if tag then
                UtilsFunctions.loadTextureAsync(tag, tagData.image, "", function(isSuccess, tag, filePath)
                    if not tolua.isnull(tag) then
                        tag:setVisible(isSuccess or false)
                    end
                end)
            end
        end
    end
end



return UIMainElemTag 