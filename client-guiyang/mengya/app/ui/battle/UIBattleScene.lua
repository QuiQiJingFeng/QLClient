local csbPath = app.UIBattleSceneCsb
local super = app.UIBase
local Util = app.Util
local UITableViewEx2 = app.UITableViewEx2
local UITableViewEx = app.UITableViewEx
local UIManager = app.UIManager

local UIBattleScene = class("UIBattleScene", super, function() return app.Util:loadCSBNode(csbPath) end)
 
function UIBattleScene:init()
    local tableViewList = Util:seekNodeByName(self,"tableViewListBottom","ccui.ScrollView")
    local tableViewBottom = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleBottomItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListRight","ccui.ScrollView")
    local tableViewRight = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleRightItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListTop","ccui.ScrollView")
    local tableViewTop = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleTopItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListLeft","ccui.ScrollView")
    local tableViewLeft = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleLeftItem)


    local playerBottom = Util:seekNodeByName(self,"playerBottom","ccui.Layout")
    local playerRight = Util:seekNodeByName(self,"playerRight","ccui.Layout")
    local playerTop = Util:seekNodeByName(self,"playerTop","ccui.Layout")
    local playerLeft = Util:seekNodeByName(self,"playerLeft","ccui.Layout")

    self._players = {}
    self._players["LEFT"] = require("mengya.app.ui.battle.players.PlayerBase").new(playerLeft,tableViewLeft)
    self._players["BOTTOM"] = require("mengya.app.ui.battle.players.PlayerBase").new(playerBottom,tableViewBottom)
    self._players["RIGHT"] = require("mengya.app.ui.battle.players.PlayerBase").new(playerRight,tableViewRight)
    self._players["TOP"] = require("mengya.app.ui.battle.players.PlayerBase").new(playerTop,tableViewTop)

    self._steeringWheel = Util:seekNodeByName(self,"steeringWheel","cc.Node")
    bindLuaObjToNode(self._steeringWheel,"mengya.app.ui.component.UISteeringWheel")

    self._btnSetting = Util:seekNodeByName(self,"btnSetting","ccui.Button")
    self._btnExit = Util:seekNodeByName(self,"btnExit","ccui.Button")
    self._btnChat = Util:seekNodeByName(self,"btnChat","ccui.Button")
    self._btnVoice = Util:seekNodeByName(self,"btnVoice","ccui.Button")

    Util:bindTouchEvent(self._btnSetting,handler(self,self._onBtnSettingClick))


    --电池
    self._spElectricBg = Util:seekNodeByName(self,"spElectricBg","cc.Sprite")
    self._spElectric = Util:seekNodeByName(self,"spElectric","cc.Sprite")
    --时间
    self._txtTime = Util:seekNodeByName(self,"txtTime","ccui.Text")
    --网络状态
    self._panelWifi = Util:seekNodeByName(self,"panelWifi","ccui.Layout")
    self._imgNotNet = Util:seekNodeByName(self,"imgNotNet","ccui.ImageView")
    self._panel4G = Util:seekNodeByName(self,"panel4G","ccui.ImageView")
    self._mutextGroupNetState = {
        ["WIFI"] = self._panelWifi,
        ["NONE"] = self._imgNotNet,
        ["4G"] = self._panel4G}
end

function UIBattleScene:_onBtnSettingClick()
    UIManager:getInstance():show("UISetting")
end

--除了刚进来之外,每30秒检测一下电量
function UIBattleScene:_updateElectricInfo(dt)
    if not self._electricDt then
        self._electricDt = 0
    else
        self._electricDt = self._electricDt + dt
        if self._electricDt < 30 then
            return
        end
        self._electricDt = 0
    end

	local batteryLevel = math.random(0,100)  --FYD TODO CALL C++/JAVA
	self._spElectric:setScaleX(batteryLevel/100)
	if batteryLevel > 20 then
		self._spElectricBg:setColor(cc.c3b(255,255,255))
		self._spElectric:setColor(cc.c3b(255,255,255))
	elseif batteryLevel <= 20 then
		self._spElectricBg:setColor(cc.c3b(255,0,0))
		self._spElectric:setColor(cc.c3b(255,0,0))
	end
end

--除了刚进来之外每秒检测一下时间
function UIBattleScene:_updateCurrentTime(dt)
    if not self._currentTimeDt then
        self._currentTimeDt = 0
    else
        self._currentTimeDt = self._currentTimeDt + dt
        if self._currentTimeDt < 1 then
            return
        end
        self._currentTimeDt = 0
    end
    
	self._txtTime:setString(Util:getFormatDate("%H:%M"))
end

--除了刚进来之外每秒检测一WIFI
function UIBattleScene:_updateNetState(dt)
    if not self._wifiDt then
        self._wifiDt = 0
    else
        self._wifiDt = self._wifiDt + dt
        if self._wifiDt < 1 then
            return
        end
        self._wifiDt = 0
    end
    
    --更新网络状态
    local enumNet = {"NONE","WIFI","4G"}
    local netState = enumNet[math.random(1,3)]
    for k, node in pairs(self._mutextGroupNetState) do
        node:setVisible(k == netState)
    end
end

function UIBattleScene:onUpdate()
    self._scheduleId = Util:scheduleUpdate(function(dt)
        self:_updateElectricInfo(dt)
        self:_updateCurrentTime(dt)
        self:_updateNetState(dt)
    end, 0)
end

function UIBattleScene:offUpdate()
    self._scheduleId = Util:unscheduleUpdate(self._scheduleId)
end

function UIBattleScene:onShow()
    self:onUpdate()
    local datas = {
        {type = "gang",cardValue = 24,from = 1},
        {type = "angang",cardValue = 22,from = 2},
        {type = "peng",cardValue = 35,from = 3},
        {type = "handCard",cardValue = 2,output = true},
        {type = "handCard",cardValue = 3,output = true},
        {type = "handCard",cardValue = 4},
        {type = "handCard",cardValue = 9},
        {type = "handCard",cardValue = 255,isLastCard = true},
    }

    self._players["LEFT"]:setHandCardDatas(datas)
    self._players["BOTTOM"]:setHandCardDatas(datas)
    self._players["RIGHT"]:setHandCardDatas(datas)
    self._players["TOP"]:setHandCardDatas(datas)


    local datas = {
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
    }

    self._players["LEFT"]:setDisCardDatas(datas)
    self._players["BOTTOM"]:setDisCardDatas(datas)
    self._players["RIGHT"]:setDisCardDatas(datas)
    self._players["TOP"]:setDisCardDatas(datas)

    self._steeringWheel:setCurrentDirect("BOTTOM")
end

function UIBattleScene:onHide()
    self:offUpdate()
    self._steeringWheel:dispose()
end

function UIBattleScene:getGradeLayerId()
    return 2
end

function UIBattleScene:isFullScreen()
    return true
end
 
return UIBattleScene