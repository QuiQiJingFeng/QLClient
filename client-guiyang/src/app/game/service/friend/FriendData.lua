-- 好友数据处理
local FriendData = class("FriendData")



function FriendData:ctor()
    self.friendList = {} -- 好友列表
    self.friendRecommendList = {} -- 好友推荐列表
    self.friendApplicantList = {} -- 申请列表
    self.roomInvitedList = {} -- 房间邀请列表

    self._friendIds = {}
end

function FriendData:deleteRecommend(roleId)
    for k, v in ipairs(self.friendRecommendList) do
        if v.roleId == roleId then
            table.remove(self.friendRecommendList, k)
            return true
        end
    end

    return false
end

function FriendData:deleteFriend(roleId)
    for k, v in ipairs(self.friendList) do
        if v.roleId == roleId then
            table.remove(self.friendList, k)
            return true
        end
    end

    return false
end

-- 保存一下好友id
function FriendData:getFriendIds()
    return self._friendIds
end

function FriendData:setFriendIds(friendIds)
    self._friendIds = friendIds
end

return FriendData