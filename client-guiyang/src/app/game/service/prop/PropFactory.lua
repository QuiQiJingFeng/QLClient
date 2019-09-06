--[[
    @desc: PropFactory 主要根据配置创建道具对象
    author:{贺逸}
    time:2018-04-26
]]
---------------------------------------------------------------------------------------------------
-- 对道具实例所在的类进行require(如果是默认处理可以不require)
local PropConfig = {}
PropConfig["Ticket"] = require("app.game.service.prop.propObj.TicketObject")
PropConfig["Voucher"] = require("app.game.service.prop.propObj.VoucherObject")
PropConfig["GiftPackage"] = require("app.game.service.prop.propObj.GiftObject") -- 礼包
PropConfig["ConsumableTimeLimite"] = require("app.game.service.prop.propObj.ConsumableObject") -- 消耗类道具

cc.exports.PropFactory = class("PropFactory")
local PropObject = require("app.game.service.prop.PropObject")

local _instance = nil;
function PropFactory:ctor()
    self:init()
end

function PropFactory:init()
end

function PropFactory:getInstance()
	if nil == _instance then
		_instance = PropFactory:new()
	end
	return _instance;
end

-- 根据id创建出标准的道具,iteminfo是道具的可变属性
function PropFactory:createProp(id, itemInfo)    
    local info = PropReader.getPropById(id)    
	Logger.dump(info)

    -- 获取道具类型，如果没配置则按照通用object进行创建
    local type = PropReader.getTypeById(id)

    local obj = nil
    if PropConfig[type] ~= nil then
        obj = PropConfig[type].new()
        obj:reset(info,itemInfo)
    else
        obj = PropObject.new()
        obj:reset(info,itemInfo)
    end

    return obj
end