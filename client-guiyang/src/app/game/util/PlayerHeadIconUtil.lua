local ns = namespace("game.util")
local UI_ANIM = require("app.manager.UIAnimManager")

---------------------
-- 玩家头像辅助类
---------------------
local PlayerHeadIconUtil = class("PlayerHeadIconUtil")
ns.PlayerHeadIconUtil = PlayerHeadIconUtil

local DEFAULT_ICON = "img/Icon_face.png"
local GIFT_DEFAULT_ICON = "clubDesc/icon_fkjl.png"
local FILE_TYPE = "playericon"

local DEFAULT_ICON = {
	DEFAULT_ICON = "img/Icon_face.png",
	GIFT_DEFAULT_ICON = "clubDesc/icon_fkjl.png",
	WORLD_CUP = "worldcup/2018.png"
}

-- isGift 因为实物奖励处图标也使用该接口下载,再未下载时默认图标改一下
function PlayerHeadIconUtil.setIcon(imageNode, iconUrl, type)	
	-- 兼容以前的代码
	if type == nil then
		type = "DEFAULT_ICON"
	elseif type == "gift" then
		type = "GIFT_DEFAULT_ICON"
	end
	
	-- 重置为默认头像
	if imageNode.loadTexture then
		imageNode:loadTexture(DEFAULT_ICON[type])
	elseif imageNode.setTexture then
		imageNode:setTexture(DEFAULT_ICON[type])
	end
	
	imageNode.iconUrl = nil
	
	-- 如果iconUrl有效,
	if iconUrl ~= nil and iconUrl ~= "" then
		-- 从远程获取图片
		-- 保存加载的地址, 下载之后对比是否需要社会中
		imageNode.iconUrl = iconUrl
		
		manager.RemoteFileManager.getInstance():getRemoteFile(FILE_TYPE, iconUrl, function(tf, fileType, fileName)
			if tf == true and not tolua.isnull(imageNode) and imageNode.iconUrl == iconUrl then
				-- 清除缓存的url标记
				imageNode.iconUrl = nil
				
				-- 获取成功之后设置图片				
				local filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
				if imageNode.loadTexture then
					-- ccimage					
					imageNode:loadTexture(filePath)
				elseif imageNode.setTexture then
					-- ccsprite
					imageNode:setTexture(filePath)
				end
			end
		end);
	end
end

-- 头像框接口， 创建一个sprite，根据node的大小会自动适配，需要配置出一套计算方法算出头像框应该的大小
-- 挂的节点一定不能有子节点！！！！！！！每次set会清空子节点
-- author heyi
function PlayerHeadIconUtil.setIconFrame(imgNode, url, scale)
	-- 清空子节点
	imgNode:removeAllChildren(true)
	-- 添加头像框
	local csb = cc.CSLoader:createNode(url)
	
	if csb == nil then
		return
	end
	local csbAnim = kod.LoadCSBNode(url)
	local action = cc.CSLoader:createTimeline(url)
	csbAnim:runAction(action)
	action:gotoFrameAndPlay(0, true)
	imgNode:addChild(csbAnim)
	
	local height = imgNode:getContentSize().height
	local width = imgNode:getContentSize().width
	csbAnim:setPosition(width / 2, height / 2)
	if scale == nil then
		csbAnim:setScale(1)
	else
		csbAnim:setScale(scale)
	end
	-- csbAnim:setContentSize(cc.size(height+50, width+50))
	return csbAnim
end 