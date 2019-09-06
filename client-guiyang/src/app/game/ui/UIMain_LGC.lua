local UIMain_LGC = wrap_class_namespace("app.game.ui", class("UIMain_LGC"))
local UIMainElemTag = require("app.game.ui.lobby.mainTag.UIMainElemTag")
local IMAGEVIEW =
{
    {img = "art/main/Btn_lm_main.png", name = "League", tagAct = UIMainElemTag.ButtonId.League, isVisible = false},
    {img = "art/main/Btn_jbc_main.png", name = "Gold", tagAct = UIMainElemTag.ButtonId.Gold, isVisible = true},
    {img = "art/main/Btn_bsc_main.png", name = "Competition", tagAct = UIMainElemTag.ButtonId.Campaign, isVisible = true},
}

function UIMain_LGC:init(mainUI)
    self._listView = seekNodeByName(mainUI, "ListView_LGC", "ccui.ListView")
    Macro.assertFalse(self._listView, "not found scroll view in main UI")
    self._button = ccui.Helper:seekNodeByName(self._listView, "Button")
    self._button:removeFromParent(false)
    mainUI:addChild(self._button)
    self._button:setVisible(false)
end

function UIMain_LGC:initLGCItems()
    self._tagAct = UIMainElemTag.new()
    self._listView:removeAllChildren()
    self._btn = {}
    self._red = {}
    IMAGEVIEW[1].isVisible = game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeagueId()
    for _, data in ipairs(IMAGEVIEW) do
        if data.isVisible then
            local node = self._button:clone()
            self._listView:addChild(node)
            node:setVisible(true)
            node.name = data.name
            local image = ccui.Helper:seekNodeByName(node, "Image")
            image:loadTexture(data.img)
            local imgRed = ccui.Helper:seekNodeByName(node, "Image_Red")
            imgRed:setVisible(false)
            self._btn[data.name] = node
            self._tagAct:appendTag(node, data.tagAct)
            bindTouchEventWithEffect(node,	handler(self, self._onClick), 1.05)
        end
    end

    self._listView:forceDoLayout()
end

function UIMain_LGC:_onClick(sender)
    if sender.name == IMAGEVIEW[1].name then
        --FYD设置为大联盟盟主
        game.service.bigLeague.BigLeagueService:getInstance():setIsSuperLeague(true)
        game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setLeagueId(0)
        game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setClubId(0)
        GameFSM.getInstance():enterState("GameState_League")
    elseif sender.name == IMAGEVIEW[2].name then
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.gold)
    elseif sender.name == IMAGEVIEW[3].name then
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.campaign)
    end
end

function UIMain_LGC:getAagAct()
    return self._tagAct
end

function UIMain_LGC:getButton(btnName)
    for name, button in pairs(self._btn) do
        if name == btnName then
            return button
        end
    end

    return nil
end

return UIMain_LGC