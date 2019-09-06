---------------------------------
-- CampaignList
local CampaignList = class("CampaignList")

function CampaignList:ctor()
    self._campaigns = {}                                 --保存的当前比赛列表
    self._campaignTabs = {}                             --比赛tab对应的键值对
    self._mttStartTime = 0                              --当前报名的mtt开赛时间
    self._currentCampaignId = 0                         --所处于的比赛(在有值时玩家只能进行该比赛相关操作sng/mtt开赛状态后)
    self._signUpCampaignList = {}                       --当前报名的比赛Id列表
    self._campaignMap = {}                              --比赛maptag id 对应一堆比赛
end

function CampaignList:getMttStartTime() 				    return self._mttStartTime; end
function CampaignList:setMttStartTime(value) 			    self._mttStartTime = value; end
function CampaignList:getCurrentCampaignId() 				return self._currentCampaignId; end
function CampaignList:getCampaigns()                        return self._campaigns; end
function CampaignList:getCampaignMap()                      return self._campaignMap end
function CampaignList:getCampaignTabs()                     return self._campaignTabs end

function CampaignList:setCampaignTabs(value)                self._campaignTabs = value end -- 设置比赛tabs对应键值列表     

function CampaignList:setCurrentCampaignId(value) 
    -- 如果id为0，则是取消当前报名比赛
    if value == 0 then
        if campaign.CampaignFSM.getInstance():isState("CampaignState_SignUp") then
            campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")
        end
    end
    
    self._currentCampaignId = value;    
end

-- 添加到当前报名比赛的列表
function CampaignList:addToSignUpCampaignList(value)
    table.insert(self._signUpCampaignList,value)
    local campaign = self:getCampaignByConfigId(value)
    if campaign ~= nil then
        campaign.signUp = true
    end
end

-- 更新比赛列表数据 增 删 如果已有的比赛就更新数据即可
function CampaignList:updateCampaignList(list)
    local newList = {}
    -- 遍历新传来的同步列表，因为它除了id只传有变化的值，则若已有信息则将已有的比赛信息放入新的表中并更新信息，若没有则将服务器传来的添加进去
    table.foreach(list, function (key ,value)
        local existsData = self:getCampaignByConfigId(value.configId)
        if existsData == nil then
            -- 添加比赛的时候添加isMtt字段
            value.isMtt = value.type == 0
            value.signUp = false
            
            -- 如果元素大于10则说明是完整的数据，采用之
            if table.nums(value) > 10 then
                table.insert(newList, value)
            end
        else
            table.foreach(value, function (k,v)
                existsData[k] = v
            end)
            table.insert(newList, existsData)
        end
    end)

    self._campaigns = newList
end

-- 添加一个比赛
function CampaignList:addCampaign(campaignInfo)
    Macro.assertFalse(campaignInfo ~= nil)
    local campaign = campaignInfo
    -- 插入比赛是否为mtt字段
    campaign.isMtt = campaign.type == 0

    -- 插入玩家是否报名了的字段
    campaign.signUp = false

    table.insert(self._campaigns, campaign)
    if campaignInfo.tab ~= nil then
        if self._campaignMap[campaignInfo.tab] == nil then
            self._campaignMap[campaignInfo.tab] = {}            
        end
        table.insert(self._campaignMap[campaignInfo.tab], campaignInfo)
    end
    return campaign
end

function CampaignList:getCampaignsByTag( tag)
    return self._campaignMap[tag] or {}
end

-- 从当前报名比赛的列表删除
function CampaignList:removeFromSignUpCampaignList(value)
    table.foreach(self._signUpCampaignList, function(key,val)
        if val == value then
            table.remove(self._signUpCampaignList, key)
        end
    end)
    local campaign = self:getCampaignByConfigId(value)
    if campaign ~= nil then
        campaign.signUp = false
    end
end

function CampaignList:getSignUpCampaignList() 				return self._signUpCampaignList; end

-- 添加报名id(根据configid判断)
function CampaignList:setSignUpCampaignList(signUpInfoList) 
    -- 如果id为0，则是取消当前报名比赛 在列表syn/res时会传进来一个repeated此时处理方式与之前不同
    if #signUpInfoList ==0 then        
        if campaign.CampaignFSM.getInstance():isState("CampaignState_SignUp") then
            campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")
        end
    end
    table.foreach(self._campaigns, function(key, val)
        val.signUp = false
    end)
    local signupCampaigns = {}
    table.foreach(signUpInfoList, function(key, val)
        local config = self:getCampaignByConfigId(val.configId)
        if config ~= nil then
            config.signUp = true
        end
        -- 报名了的比赛configid列表
        table.insert(signupCampaigns, val.configId)
    end)

    self._signUpCampaignList = signupCampaigns
end

-- 获取比赛by configid
function CampaignList:getCampaignByConfigId( configId)
    for idx,campaign in ipairs(self._campaigns) do
        if campaign.configId == configId then
            return campaign;
        end
    end

    return nil;
end

-- 清除所有比赛
function CampaignList:removeAllCampaign()
    self._campaigns = {}
    self._signUpCampaignList = {}
    self._campaignMap = {}
    self._campaignTabs = {}
end

-- 是否有比赛列表信息改变了
function CampaignList:isCampaignChanged()
    for _,campaign in ipairs(self._campaigns) do
        if campaign:isNoticeChanged() then
            return true;
        end
    end

    return false;
end

function CampaignList:getFeeName(items)
    local result = ""

    if #items == 0 then
        return result
    end
    -- 取出优先级最高的
    table.sort(items, function (a,b)
        return a.key < b.key
    end)

    if #items ~= 0 then
        result = PropReader.generatePropTxt({items[1].item})
    end
    return result
end

function CampaignList:getCostName(items, key)
    local result = ""

    -- 取出所有道具信息
    local costInfo = {}
    table.foreach(items, function (k,v)
        if v.key == key then
            costInfo = v.item
        end
    end)

    if next(costInfo) then
        result = PropReader.generatePropTxtWithoutNums({costInfo})
    end
    return result
end

function CampaignList:getCostByKey(items, key)
    local result = ""

    -- 取出所有道具信息
    local costInfo = {}
    table.foreach(items, function (k,v)
        if v.key == key then
            costInfo = v.item
        end
    end)

    return costInfo
end

return CampaignList