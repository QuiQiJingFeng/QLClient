local Util = game.Util
local UIBattleHandleItemBase = import("items.UIBattleHandleItemBase")
local UIBattleHandleBottomItem = import("items.UIBattleHandleBottomItem")
local UIBattleHandleRightItem = import("items.UIBattleHandleRightItem")
local UIBattleHandleTopItem = import("items.UIBattleHandleTopItem")
local UIBattleHandleLeftItem = import("items.UIBattleHandleLeftItem")
local UISteeringWheel = import("component.UISteeringWheel")
local UISortListView = game.UISortListView
local UIPlayer = import("component.UIPlayer")
local super = game.UIBase
local UIManager = game.UIManager
local UIHandCardList = game.UIHandCardList
local UIBattleBase = class("UIBattleBase",super)

function UIBattleBase:ctor()
    super.ctor(self)
    --玩家信息相关
    local playerBottom = Util:seekNodeByName(self,"playerBottom","ccui.Layout")
    self._playerBottom = UIPlayer.extend(playerBottom)
    local playerRight = Util:seekNodeByName(self,"playerRight","ccui.Layout")
    self._playerRight = UIPlayer.extend(playerRight)
    local playerTop = Util:seekNodeByName(self,"playerTop","ccui.Layout")
    self._playerTop = UIPlayer.extend(playerTop)
    local playerLeft = Util:seekNodeByName(self,"playerLeft","ccui.Layout")
    self._playerLeft = UIPlayer.extend(playerLeft)

    --手牌相关
    local node = Util:seekNodeByName(self,"tableViewListBottom","ccui.ListView")
    self._handListBottom = UIHandCardList.extend(node,"Bottom")
    self._handListBottom:setLocalZOrder(1)
    local node = Util:seekNodeByName(self,"tableViewListRight","ccui.ListView")
    self._handListRight = UIHandCardList.extend(node,"Right")
    
    local node = Util:seekNodeByName(self,"tableViewListTop","ccui.ListView")
    self._handListTop = UIHandCardList.extend(node,"Top")

    local node = Util:seekNodeByName(self,"tableViewListLeft","ccui.ListView")
    self._handListLeft = UIHandCardList.extend(node,"Left")

    Util:hide(self._handListBottom,self._handListRight,self._handListTop,self._handListLeft)

    --计时器转盘节点
    local node = Util:seekNodeByName(self,"steeringWheel","cc.Node")
    self._steeringWheel = UISteeringWheel.extend(node)

    --房间基础信息相关
    --房间号
    self._txtRoomId = Util:seekNodeByName(self,"txtRoomNumber","ccui.Text")
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
        ["4G"] = self._panel4G
    }

    --房间规则
    self._txtRoomRules = Util:seekNodeByName(self,"txtRoomRules","ccui.Text")

    --开局前可以操作的列表
    self._listPreStartOption = UISortListView.extend(Util:seekNodeByName(self,"listPreStartOption","ccui.ListView"))
    --解散房间
    self._btnDestroyRoom = Util:seekNodeByName(self,"btnDestroyRoom","ccui.Button")
    --提前开局
    self._btnEarlyStart = Util:seekNodeByName(self,"btnEarlyStart","ccui.Button")
    --返回大厅
    self._btnBackHall = Util:seekNodeByName(self,"btnBackHall","ccui.Button")
    --微信邀请按钮
    self._btnWechatInvite = Util:seekNodeByName(self,"btnWechatInvite","ccui.Button")

    Util:hide(self._btnDestroyRoom,self._btnEarlyStart,self._btnBackHall,self._btnWechatInvite)

    --按钮相关节点
    self._battleBtns = Util:seekNodeByName(self,"battleBtns","cc.Node")
    self._btnSetting = Util:seekNodeByName(self,"btnSetting","ccui.Button")
    self._btnExit = Util:seekNodeByName(self,"btnExit","ccui.Button")
    self._btnChat = Util:seekNodeByName(self,"btnChat","ccui.Button")
    self._btnVoice = Util:seekNodeByName(self,"btnVoice","ccui.Button")

    Util:bindTouchEvent(self._btnSetting,handler(self,self._onBtnSettingClick))
end

--[[
    data:{
        roomId  房间Id
        descript 房间规则
        isCreator 是否是房间的创建者
    }
]]
function UIBattleBase:onShow(data)
    self:onUpdate()
    self._data = data
    --房间号显示
    local textRoomNumberDesc = string.format("房间号:%d",data.roomId)
    self._txtRoomId:setString(textRoomNumberDesc)
    --规则描述
    self._txtRoomRules:setString(data.descript)
    -- if data.isCreator then
    --     Util:show(self._btnDestroyRoom,self._btnEarlyStart)
    --     Util:hide(self._btnBackHall)
    --     self._listPreStartOption:sort()
    -- else
    --     Util:show(self._btnBackHall,self._btnEarlyStart)
    --     Util:hide(self._btnDestroyRoom)
    --     self._listPreStartOption:sort()
    -- end

    game.EventCenter:on("REFRESH_HANDLE_CARDS",handler(self,self._refreshHandleCards))
end

function UIBattleBase:_refreshHandleCards(direction,datas)
    for _, place in ipairs(self._places) do
        if place:getDirection() == direction then
            place:updateHandListDatas(datas)
            return
        end
    end
end

function UIBattleBase:onHide()
    self:offUpdate()
    game.EventCenter:off(self)
    self._steeringWheel:dispose()
end

function UIBattleBase:_onBtnSettingClick()
    UIManager:getInstance():show("UISetting")
end

--除了刚进来之外,每30秒检测一下电量
function UIBattleBase:_updateElectricInfo(dt)
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
function UIBattleBase:_updateCurrentTime(dt)
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
function UIBattleBase:_updateNetState(dt)
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

function UIBattleBase:onUpdate()
    self._scheduleId = Util:scheduleUpdate(function(dt)
        self:_updateElectricInfo(dt)
        self:_updateCurrentTime(dt)
        self:_updateNetState(dt)
    end, 0)
end

function UIBattleBase:offUpdate()
    self._scheduleId = Util:unscheduleUpdate(self._scheduleId)
end

return UIBattleBase