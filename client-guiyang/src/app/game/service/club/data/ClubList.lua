-- 亲友圈列表
local ClubList = class("ClubList")
local ClubData = require("app.game.service.club.data.ClubData")

function ClubList:ctor()
    self.clubs = {} -- 亲友圈列表
end

-- 当前是否有亲友圈
function ClubList:hasClub()
    return #self.clubs ~= 0
end

-- 获取指定Club所在的序号, 如果没有返回false
function ClubList:indexOfClub(clubId)
    for idx,club in ipairs(self.clubs) do
        if club.info.clubId == clubId then
            return idx;
        end
    end

    return false;
end

-- 添加一个亲友圈
function ClubList:addClub(clubInfo)
    Macro.assertFalse(clubInfo ~= nil)
    local club = ClubData.new()
    club.info = clubInfo
    table.insert(self.clubs, club)
    return club
end

-- 删除一个亲友圈
function ClubList:removeClub(clubId)
    for idx,club in ipairs(self.clubs) do
        if club.info.clubId == clubId then
            table.remove(self.clubs, idx)
            return club
        end
    end

    return false
end

-- 否改有亲友圈的邀请信息改变了
function ClubList:isApplicationChanged()
    for _,club in ipairs(self.clubs) do
        if club:isApplicationChanged() then
            return true;
        end
    end

    return false;
end

return ClubList