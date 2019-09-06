local ns = namespace("game.service")

local HeadFrameService = class('HeadFrameService')
ns.HeadFrameService = HeadFrameService

function HeadFrameService.getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getHeadFrameService()
    end

    return nil
end
function HeadFrameService:ctor()
    -- 保存头像框列表
    self._frameList = {}
    self._privousSelect = 0
    self._currencyType = "0x0F000002"

    -- 绑定事件系统
	cc.bind(self, "event");
end

function HeadFrameService:initialize()
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.GCQueryHeadFrameRES.OP_CODE, self, self._onQueryHeadFrameRES);
    requestManager:registerResponseHandler(net.protocol.GCPurchaseHeadFrameRES.OP_CODE, self, self._onGCPurchaseHeadFrameRES);
    requestManager:registerResponseHandler(net.protocol.GCSwitchHeadFrameRES.OP_CODE, self, self._onSwitchHeadFrameRES);
end

function HeadFrameService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
    -- 解绑事件系统
	cc.unbind(self, "event")
end

-- Client向Game请求头像框商城信息
function HeadFrameService:queryHeadFrame()
	local request = net.NetworkRequest.new(net.protocol.CGQueryHeadFrameREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea())
	game.util.RequestHelper.request(request)
end

function HeadFrameService:_onQueryHeadFrameRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_QUERY_HEAD_FRAME_SUCCESS then
        dump(protocol.headFrame, "GCQueryHeadFrameRES headFrame = ")
        dump(protocol.roleHeadFrames, "GCQueryHeadFrameRES roleHeadFrames = ")
        -- 将传来的列表添加是否拥有的属性
        self._frameList = protocol.headFrame
        table.foreach(self._frameList, function ( k, v)
            v.isOwn = false
            table.foreach(protocol.roleHeadFrames,function (k2,v2)
                if v2.id == v.id then 
                    v.isOwn = true
                    v.startTime = v2.createTime
                    v.endTime = v2.destroyTime
                end
            end)
        end)

        dump(protocol.headFrame, "GCQueryHeadFrameRES headFrame = ")

        self._currencyType = protocol.currency

        -- 如果当前正在显示则刷数据，否则显示ui
        if UIManager:getInstance():getIsShowing("UIHeadMall") == true then
            game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_HEADLIST_REFRASH", data =self._frameList, select = self._privousSelect});
        else
            UIManager:getInstance():show("UIHeadMall", self._frameList)
            game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_HEADLIST_REFRASH", data =self._frameList, select = game.service.LocalPlayerService.getInstance():getHeadFrameId()});
        end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求购买头像
function HeadFrameService:queryBuyHeadframe(id, time)
    local request = net.NetworkRequest.new(net.protocol.CGPurchaseHeadFrameREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea(), id, time)
	game.util.RequestHelper.request(request)
end

-- 购买头像回复
function HeadFrameService:_onGCPurchaseHeadFrameRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local id = response:getRequest():getProtocol():getProtocolBuf().id
    if protocol.result == net.ProtocolCode.GC_PURCHASE_HEAD_FRAME_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("购买成功！")        
        UIManager:getInstance():destroy("UIBuyHeadSelect")  
        UIManager:getInstance():destroy("UIHeadConfirm")
        self._privousSelect = id

        self:queryHeadFrame()
        -- 请求切换头像
        if id ~= nil and id ~= 0 then
            self:querySwitchHeadFrame(id)
        end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))        
    end
end

-- 请求切换头像
function HeadFrameService:querySwitchHeadFrame(id)
    local request = net.NetworkRequest.new(net.protocol.CGSwitchHeadFrameREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(id)
	game.util.RequestHelper.request(request)
end

-- 切换头像回复
function HeadFrameService:_onSwitchHeadFrameRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local id = response:getRequest():getProtocol():getProtocolBuf().id
    if protocol.result == net.ProtocolCode.GC_SWITCH_HEAD_FRAME_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("切换成功！")   
        game.service.LocalPlayerService.getInstance():setHeadFrameId(id)
        -- 刷新头像
        game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_HEAD_CHANGE", data = id}) 
        -- 选中所切换的头像
        game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_USE_HEAD", data = id}); 
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))        
    end
end

function HeadFrameService:getCurrencyType()
    return self._currencyType
end

function HeadFrameService:loadLocalStorage()
end

return HeadFrameService