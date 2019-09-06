--[[
    @desc: BackpackService，主要处理道具/背包相关/礼包协议以及保存玩家游戏物品
    author:{贺逸}
    time:2018-04-26

    事件
    - 刷新实物奖励列表 EVENT_BACKPACK_PRACTICAL
    - 
]]

local ns = namespace("game.service")
local BackpackItem = require("app.game.service.prop.BackpackItem");

local BackpackService = class("BackpackService")
ns.BackpackService = BackpackService

function BackpackService.getInstance()
    if game.service.LocalPlayerService.getInstance() == nil then
		return nil
	end
	return game.service.LocalPlayerService.getInstance():getBackpackService();
end

function BackpackService:ctor()
    cc.bind(self, "event");
    
    self.backpackList = {}
end

function BackpackService:initialize()
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.GCQueryRoleItemsRES.OP_CODE, self, self._onGCQueryRoleItemsRES);
    requestManager:registerResponseHandler(net.protocol.GCUseSpecialEffectRES.OP_CODE, self, self._onGCUseSpecialEffectRES);

    self:loadLocalStorage()
end

function BackpackService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);
    -- 解绑事件系统
	cc.unbind(self, "event");
end

-- 玩家查询背包道具请求
function BackpackService:queryBackpack()
    local request = net.NetworkRequest.new(net.protocol.CGQueryRoleItemsREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    game.util.RequestHelper.request(request)
end

function BackpackService:_onGCQueryRoleItemsRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local data = protocol.item
    self.backpackList = {}    

    if UIManager:getInstance():getIsShowing("UIBackpack") == false then
        UIManager:getInstance():show("UIBackpack")  
    end
    table.foreach(data, function(key, val)
        local obj = BackpackItem.new()
        -- 将物品另外的信息放进external里
        local external = {}
        external.uid = val.uid
        external.content = val.content
        external.createTime = val.createTime
        external.destroyTime = val.destroyTime
        external.status = val.status

        obj:setData( PropFactory:createProp(val.id , external), val.count)
        table.insert( self.backpackList,obj)        
    end)

    game.service.BackpackService.getInstance():dispatchEvent({name = "EVENT_BACKPACK_FICTITIOUS", data = self.backpackList});   
end

function BackpackService:_onGCUseSpecialEffectRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest():getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_USE_SPECIAL_EFFECT_SUCCESS then
        UIManager:getInstance():hide("UIBackpackConsumable")
        if request.operate == 1 then
            game.ui.UIMessageTipsMgr.getInstance():showTips("使用成功")
        else
            game.ui.UIMessageTipsMgr.getInstance():showTips("停用成功")
        end
        game.service.BackpackService.getInstance():queryBackpack()
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("使用失败")
    end
end

-- 使用打牌特效
function BackpackService:useSpecialEffect(itemId, operate)
    local request = net.NetworkRequest.new(net.protocol.CGUseSpecialEffectREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    request:getProtocol():setData(itemId , operate)
    game.util.RequestHelper.request(request)
end

function BackpackService:loadLocalStorage()
end

return BackpackService