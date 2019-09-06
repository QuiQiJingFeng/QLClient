local super = require("app.game.service.activity.ActivityServiceBase")
local GuideActivityService = class("GuideActivityService", super)

local SELECT_ENUM = {
    NO = 0,
    YSE = 1,
}

function GuideActivityService:initialize()
    game.service.ActivityService.getInstance():addEventListener("NEWER_GUAIDE", handler(self, self._onNewer_Guaide), self);
    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.ACCNewPlayerInfoRES.OP_CODE, self, self._onACCNewPlayerInfoRES);
end

function GuideActivityService:dispose()
    game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end

function GuideActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

function GuideActivityService:_onNewer_Guaide()
    -- 开始新手引导的程序
    local UIAnswer = require("app.game.ui.UIAnswer")

    local finalAnwser = {}
    local config = {
        {
            type_ = UIAnswer.TYPE.YES_NO,
            title_ = "1.您是否玩过手机麻将？",
            titleTips_ = "（题目1/2）",
            index_ = {SELECT_ENUM.YSE, SELECT_ENUM.NO}
        },
        {
            type_ = UIAnswer.TYPE.GET,
            title_ = "2.选择以下您玩过的游戏",
            titleTips_ = "（题目2/2）",
            anwsers_ = {"弈乐","微乐",config.STRING.M_STRING_100,"闲来","其它"},
            index_ = {11,12,13,14,15}, -- bi定的
        },
        {
            type_ = UIAnswer.TYPE.YES_NO,
            title_ = "2.您是被人推荐来此游戏的吗？",
            titleTips_ = "（题目2/2）",
            index_ = {SELECT_ENUM.YSE, SELECT_ENUM.NO}
        },
    }
    UIManager:getInstance():show("UIAnswer", config[1],
        function(str)
            -- 上方配置的索引，因选择不同跳的分支index不同
            local nextIndex = 3
            if str == SELECT_ENUM.YSE then
                nextIndex = 2
            end
            table.insert(finalAnwser, str)
            UIManager:getInstance():show("UIAnswer", config[nextIndex],
                function(str)
                    table.insert(finalAnwser, str)
                    -- 上传TD
                    game.service.TDGameAnalyticsService.getInstance():onEvent("NEW_BEGINER_ANSWER", 
                    {
                        answer1 = finalAnwser[1],
                        answer2 = finalAnwser[2],
                    })
                    self:_queryCACNewPlayerInfo(finalAnwser, str)
                end
            )
        end
    )
end

function GuideActivityService:_queryCACNewPlayerInfo(answers, select)
    local request = net.NetworkRequest.new(net.protocol.CACNewPlayerInfoREQ, self:getServerId())
    request:getProtocol():setData(answers)
    request.select = select
    game.util.RequestHelper.request(request)
end

function GuideActivityService:_onACCNewPlayerInfoRES(response)
    local request = response:getRequest()
    game.service.ActivityService:getInstance():endActivity(net.protocol.activityType.NEWER_GUIADE)
    local ui = UIManager:getInstance():getUI("UIMain")
    if ui then
        game.ui.UIMessageBoxMgr.getInstance():show("恭喜您已经获得5元话费赛门票！", {"确认"},function()
            if request.select == SELECT_ENUM.NO then
                -- 提示进入比赛
                ui:showGuide("Competition")
            else
                -- 提示进入亲友圈
                ui:showGuide("Club")
            end
        end)
    end
end

return GuideActivityService
