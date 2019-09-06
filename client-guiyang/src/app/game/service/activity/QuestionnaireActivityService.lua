local super = require("app.game.service.activity.ActivityServiceBase")
local QuestionnaireActivityService = class("QuestionnaireActivityService", super)

function QuestionnaireActivityService:initialize()
    self.questionnaireStatus = -1  -- 问卷调查状态（0：未完成，1：完成未领取，2：已领取）
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.ACCQueryQuestionnaireRES.OP_CODE, self, self._onACCQueryQuestionnaireRES);
    requestManager:registerResponseHandler(net.protocol.ACCQuestionnaireRewardRES.OP_CODE, self, self._onACCQuestionnaireRewardRES);
    requestManager:registerResponseHandler(net.protocol.ACCQuestionnaireResultSYN.OP_CODE, self, self._onACCQuestionnaireResultSYN)
end

function QuestionnaireActivityService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function QuestionnaireActivityService:getActivityType()
    return net.protocol.activityType.WEN_JUAN
end

function QuestionnaireActivityService:openActivityMainPage()
    if not self:isQuestionnaireDone() then
        self:sendCACQueryQuestionnaireREQ()
    end
end

function QuestionnaireActivityService:getActivityServerType()
    return net.protocol.activityServerType.WEN_JUAN
end



function QuestionnaireActivityService:checkAutoShow()
    if not self:isQuestionnaireDone() and storageTools.AutoShowStorage.isNeedShow(self.class.__cname, 2) then
        self:openActivityMainPage()
    end
end

function QuestionnaireActivityService:isQuestionnaireDone()
	return self.questionnaireStatus == 1 or self.questionnaireStatus == 2
end

function QuestionnaireActivityService:isQuestionnaireRewardReceived()
	return self.questionnaireStatus == 2
end

-- 请求问卷调查链接
function QuestionnaireActivityService:sendCACQueryQuestionnaireREQ()
	if not self:isActivityOpening() then
		game.ui.UIMessageTipsMgr.getInstance():showTips("不在活动时间内!")
		return
	end
	if self:isQuestionnaireRewardReceived() then
		game.ui.UIMessageTipsMgr.getInstance():showTips("您已经领取过了!")
		return
	end
    local request = net.NetworkRequest.new(net.protocol.CACQueryQuestionnaireREQ, self:getServerId())
    request:setWaitForResponse(false)
    request:execute()
end

--问卷按钮回复
function QuestionnaireActivityService:_onACCQueryQuestionnaireRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.ACC_QUERY_QUESTIONNAIRE_SUCCESS then
        -- UIManager.getInstance():show("UIQuestionnaire", protocol)
        -- 另外一个调查问卷的形式，先走这个，以后改需求再说吧
        UIManager.getInstance():show("UIDaTi", protocol)
	end
end

-- 请求问卷调查奖励
function QuestionnaireActivityService:sendCACQuestionnaireRewardREQ()
	net.NetworkRequest.new(net.protocol.CACQuestionnaireRewardREQ, self:getServerId()):execute()
end

--问卷奖品回复
function QuestionnaireActivityService:_onACCQuestionnaireRewardRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		game.ui.UIMessageTipsMgr.getInstance():showTips("领奖成功")
		self.questionnaireStatus = 2
	end
end

-- 调查问卷推送
function QuestionnaireActivityService:_onACCQuestionnaireResultSYN(response)
	self.questionnaireStatus = response:getBuffer().questionnaireStatus
end


return QuestionnaireActivityService