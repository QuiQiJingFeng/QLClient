-------------------------------------------------
-- 比赛场内开场动画控制类 false为关闭其唯一属性
local UNIQUE_ANIM = {
    ["PromotionReward"] = true
}

local CampaignAnimController = class("CampaignAnimController")
function CampaignAnimController:ctor()
    self._cacheAnim = {}
end

function CampaignAnimController:getCache()
    return self._cacheAnim
end

-- 添加一个动画进去 并进行排序,去重
function CampaignAnimController:addAnim(anim,sort,datas)
    local data = {
            name = anim,
            sort = sort,
            datas = datas
    }

    local dirt = false

    -- 如果有UNIQUE_ANIM中的动画，则只播放UNIQUE_ANIM。故如果新加是UNIQUE_ANIM中存在的，则删除原来的，同时如果本身有UNIQUE_ANIM中的项目则不再接受新成员
    if UNIQUE_ANIM[anim] ~= nil then
        self._cacheAnim = {}
    end
    
    table.foreach(self._cacheAnim, function (k,v)
        if v.name == anim or UNIQUE_ANIM[v.name] ~= nil then
            dirt = true
        end
    end)

    if dirt == true then
        return
    end

    table.insert(self._cacheAnim, data)

    table.sort(self._cacheAnim, function (a,b)
        return a.sort > b.sort
    end)
end

function CampaignAnimController:playCacheAnim()
    UIManager:getInstance():show("UICampaignAnimPanel")  
end

function CampaignAnimController:clear()
    self._cacheAnim = {}
end

return CampaignAnimController