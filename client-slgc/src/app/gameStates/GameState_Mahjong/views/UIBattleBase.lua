local Util = game.Util
local UITableViewEx2 = game.UITableViewEx2
local UIBattleHandleItemBase = import("items.UIBattleHandleItemBase")
local UIBattleHandleBottomItem = import("items.UIBattleHandleBottomItem")
local UIBattleHandleRightItem = import("items.UIBattleHandleRightItem")
local UIBattleHandleTopItem = import("items.UIBattleHandleTopItem")
local UIBattleHandleLeftItem = import("items.UIBattleHandleLeftItem")
local UISteeringWheel = import("component.UISteeringWheel")
local UISortListView = game.UISortListView
local UIPlayer = import("component.UIPlayer")
local super = game.UIBase
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
    Util:hide(playerBottom,playerRight,playerTop,playerLeft)
    --手牌相关
    local node = Util:seekNodeByName(self,"tableViewListBottom","ccui.ScrollView")
    self._handListBottom = UITableViewEx2.extend(node,UIBattleHandleBottomItem)

    local node = Util:seekNodeByName(self,"tableViewListRight","ccui.ScrollView")
    self._handListRight = UITableViewEx2.extend(node,UIBattleHandleRightItem)

    local node = Util:seekNodeByName(self,"tableViewListTop","ccui.ScrollView")
    self._handListTop = UITableViewEx2.extend(node,UIBattleHandleTopItem)

    local node = Util:seekNodeByName(self,"tableViewListLeft","ccui.ScrollView")
    self._handListLeft = UITableViewEx2.extend(node,UIBattleHandleLeftItem)
    
    Util:hide(self._handListBottom,self._handListRight,self._handListTop,self._handListLeft)

    --计时器转盘节点
    local node = Util:seekNodeByName(self,"steeringWheel","cc.Node")
    self._steeringWheel = UISteeringWheel.extend(node)

    --按钮相关节点
    self._battleBtns = Util:seekNodeByName(self,"battleBtns","cc.Node")
    Util:hide(self._battleBtns)

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
end

return UIBattleBase