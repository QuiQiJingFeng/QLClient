--[[    @desc: 游戏启动时读取PropConfig.lua，该lua配置由服务器生成。
           同时，根据物品id右移SHIFT_SIZE计算出物品类型
    author:{贺逸}
    time:2018-04-26
    return
]]
---------------------------------------------------------------------------------
local PropReader = namespace("PropReader")


local localConfig = {
	[1] = {
		id = "0x06000016",
		area = "10006",
		name = "游戏道具",
		desc = "魔法表情，可在牌桌内点击其他玩家头像向其发射",
		source = "",
		purpose = "",
		destroyTime = "",
		icon = "art/mall/icon_yxdj.png",
		storageFlag = "true",
		duration = "0",
	},
	[2] = {
		id = "0x04000004",
		area = "10006",
		name = "iPhone Xs",
		desc = "",
		source = "",
		purpose = "",
		destroyTime = "",
		icon = "art/mall/IconIPhoneX.png",
		storageFlag = "true",
		duration = "0",
	},
	[3] = {
		id = "0x04000005",
		area = "10006",
		name = "小米电视",
		desc = "",
		source = "",
		purpose = "",
		destroyTime = "",
		icon = "art/function/icon_tv.png",
		storageFlag = "true",
		duration = "0",
	},
}

local _config = {}

-- 登录后切换到地区配置
PropReader.loadAreaConfig = function(area)
	area = 10006
	local areaConfig = _config
	table.foreach(config.PropConfig, function(key, value)
		if value.area == tostring(area) then
			areaConfig[tostring(value.id)] = value
		end
	end)

	table.foreach(localConfig, function(key, value)
		if value.area == tostring(area) then
			areaConfig[tostring(value.id)] = value
		end
	end)

	_config = areaConfig
end

-- 根据id获取物品信息
PropReader.getPropById = function(v)
	local id = string.format("0x%08X", v)
	Macro.assertTrue(_config[id] == nil, "Error Propid" .. id)
	return _config[id]
end

-- 根据id获取物品名称
PropReader.getNameById = function(v)
	local id = string.format("0x%08X", v)
	if not _config[id] or not _config[id].name then
		return ""
	end
	return _config[id].name
end

-- 根据id获取物品Icon
PropReader.getIconById = function(v)
	local id = string.format("0x%08X", v)
	if not _config[id] or not _config[id].icon then
		return ""
	end
	return _config[id].icon
end


-- 生成奖品文字
PropReader.generatePropTxt = function(props, countSpliter, itemSpliter)
    local countSpliter = countSpliter or "X"
    local itemSpliter = itemSpliter or ""
    local strt = {}
    table.foreach(props, function(key, value)
        local id = rawget(value, "id") or rawget(value, "itemId")
        local time = rawget(value, "time")
        local count = rawget(value, "count") or 0
        local units = ""
        local desc = ""
		if PropReader.getTypeById(id) == "RedPackage" then
			units = "元"
        end
        desc = PropReader.getNameById(id) .. countSpliter .. count .. units
        if time ~= nil and time > 0 then
            desc = desc .. " (" .. time .. "天)"
        end
        table.insert(strt, desc)
	end)
	return table.concat(strt, itemSpliter)
end

-- 生成奖品文字自动换行(一个奖品一行)
PropReader.generatePropTxtAutoWrap = function(props)
	local result = ""
	local txtTbl = {}
	table.foreach(props, function(key, value)
		local units = ""
		if PropReader.getTypeById(value.id) == "RedPackage" then
			units = "元"
		end
		local text = PropReader.getNameById(value.id) .. "X" .. value.count .. units
		table.insert(txtTbl, text)
	end)
	result = table.concat(txtTbl, "\n")
	return result
end

-- 生成奖品文字(无个数)
PropReader.generatePropTxtWithoutNums = function(props)
	local result = ""
	table.foreach(props, function(key, value)
		local units = ""
		if PropReader.getTypeById(value.id) == "RedPackage" then
			units = "元"
		end
		result = result .. PropReader.getNameById(value.id)
	end)
	return result
end


-------------------------------------------------------------------------
-- 返回物品类型
--对物品类型进行解析
local INVALID_ID = 0
local SHIFT_SIZE = 24

local AssetType = {
	[0]	= "Unknow";     -- 非法类型
	[15]	= "Special";    -- 特殊类型 货币
	[1]	= "Ticket";     -- 门票
	[2]	= "Voucher";    -- 代金券
	[3]	= "HeadFrame";  -- 头像
	[4]	= "RealItem";   -- 实物
	[5]	= "GiftPackage";   -- 礼包
	[6] = "Consumable";		--消耗类道具 
	[7] = "ConsumableTimeLimite" --消耗类道具 时限
}
PropReader.AssetType = AssetType

local IconType = {
	--金豆
	GameMoney = {
		
	},
	--房卡
	NormalCard = {
		{1, "art/mall/icon_fk.png"},
	},
	--金币
	Gold = {
		{1, "art/mall/icon_gold.png"},
	},
	--红包
	RedPackage = {
		{1, "art/function/icon_xjhb.png"},
	},
	--礼券
	Ticket = {
		{1, "art/mall/icon_lq.png"},
	},
	--参赛券
	CompetitionVoucher = {
		{1, "art/mall/icon_sq.png"},
	}
}

local TypeName = {
	Unknow	= '非法类型',
	Special	= '货币',
	Ticket	= '门票',
	Voucher	= '代金券',
	HeadFrame	= '头像',
	RealItem	= '实物',
	GiftPackage = '礼包',
	Consumable = '效果类道具',
	ConsumableTimeLimite = '效果类道具-时限类'
}


local SpecialID = {
	-- 游戏币(金豆)
	[bit.bor(bit.lshift(15, SHIFT_SIZE), 1)]	= "GameMoney",
	-- 普通房卡
	[bit.bor(bit.lshift(15, SHIFT_SIZE), 2)]	= "NormalCard",
	-- 金币(金币场货币)
	[bit.bor(bit.lshift(15, SHIFT_SIZE), 3)]	= "Gold",
	-- 红包
	[bit.bor(bit.lshift(15, SHIFT_SIZE), 4)]	= "RedPackage",
	-- 礼券(商城积分)
	[bit.bor(bit.lshift(15, SHIFT_SIZE), 5)]	= "Ticket",
	-- 参赛券
	[bit.bor(bit.lshift(15, SHIFT_SIZE), 7)]	= "CompetitionVoucher",
	-- 话费
	[bit.bor(bit.lshift(15, SHIFT_SIZE), 8)]	= "Airtime"
}

-- 返回物品类型
PropReader.getTypeById = function(id)
	local id = tonumber(id)
	local type = bit.band(bit.rshift(id, SHIFT_SIZE), 255)
	Macro.assertTrue(AssetType[type] == nil, "ErrorType" .. id)
	
	if AssetType[type] == "Special" then
		Macro.assertTrue(SpecialID[id] == nil, "ErrorId" .. id)		
		return SpecialID[id]
	else
		return AssetType[type]
	end	
end
--获取货币图片(金币，房卡，参赛券，礼券，红包)
PropReader.getMoneyIcon = function(strType, count)
	local icons = IconType[strType]
	if icons == nil then
		return ""
	end
	if count == nil then
		return icons[1] [2]
	end
	local path = icons[1][2]
	for _, v in ipairs(icons) do
		if v[1] == count then
			return v[2]
		elseif v[1] > count then
			return path
		else
			path = v[2]
		end		
	end
	return path
end
--获取
PropReader.getFrameIcon = function(itemId)
	if FrameIcon[itemId] ~= nil then
		return FrameIcon[itemId]
	end
	return ""
end
--根据类型和图片返回
PropReader.getIconByIdAndCount = function(itemId, count)
	local id = tonumber(itemId)
	local type = bit.band(bit.rshift(id, SHIFT_SIZE), 255)
	if AssetType[type] == "Special" then
		-- return PropReader.getMoneyIcon(SpecialID[id], count)
		return PropReader.getIconById(itemId)
		-- elseif AssetType[type] == "HeadFrame" then
-- 	return PropReader.getFrameIcon(itemId)
	else
		return PropReader.getIconById(itemId)
	end
end

-- 返回物品类型的名称
PropReader.getTypeNameById = function(id)
	local id = tonumber(id)
	local type = bit.band(bit.rshift(id, SHIFT_SIZE), 255)
	Macro.assertTrue(AssetType[type] == nil, "ErrorType" .. id)
	
	return TypeName[AssetType[type]]
	
end

-- 返回物品类型
PropReader.getIdByType = function(type)
	for k, v in pairs(SpecialID) do
		if v == type then
			return k
		end
	end
	
end

local FILE_TYPE = "RealItem"
--[[为node添加图标
node为需要添加的父容器
imgSource:实物链接或者物品系统的id
scale:添加的图标对应于父容器的倍率
]]
PropReader.setIconForNode = function(node, imgSource, scale)
	local url = nil
	if tonumber(imgSource) == nil then
		url = imgSource
	else
		url = PropReader.getIconById(imgSource)
	end
	
	local autoScale = scale == nil
	local createNode = nil
	
	local getAutoScale = function(targetHeight, targetWidth)
		local _scale = 1
		local height = node:getContentSize().height
		local width = node:getContentSize().width
		
		if height / width > targetHeight / targetWidth then
			_scale = width / targetWidth
		else
			_scale = height / targetHeight
		end
		-- 解决如果放在 node 下， scale 会变成0 的问题
		if _scale <= 0 then
			_scale = 1
		end
		return _scale
	end

	local createImg = function(url)
		-- 清空子节点
		local image = ccui.ImageView:create(url)
		node:removeAllChildren(true)
		local height = node:getContentSize().height
		local width = node:getContentSize().width
		node:addChild(image)
		
		image:setPosition(width / 2, height / 2)
		
		local _scale = scale
		
		if autoScale then
			local size = image:getContentSize()
			_scale = getAutoScale(size.height, size.width)
		end
		image:setScale(_scale)
		
		return image
	end
	
	
	if string.find(url, "csb/") then
		local _scale = scale
		if autoScale then
			_scale = getAutoScale(160, 160)
		end
		createNode = game.util.PlayerHeadIconUtil.setIconFrame(node, url, _scale)
	else
		if string.find(url, "http") then
			--远程文件
			-- 保存加载的地址, 下载之后对比是否需要中
			node.iconUrl = url
			manager.RemoteFileManager.getInstance():getRemoteFile(FILE_TYPE, url, function(tf, fileType, fileName)
				if tf == true and not tolua.isnull(node) and node.iconUrl == url then
					-- 清除缓存的url标记
					node.iconUrl = nil
					
					-- 获取成功之后设置图片				
					local filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
					createNode = createImg(filePath)			

				end
			end);
		else
			createNode = createImg(url)
		end
	end
	return createNode
end

