--[[
        --------------------------------------/实时语音系统--------------------------------------------
        private voiceQueue: Array<{ pos: number, path: string }> = new Array<{ pos: number, path: string }>();;

        --添加实时语音到队列并播放
        private addVoice(pos: number, path: string) {
            if (pos != 0) {
                self.voiceQueue.push({ pos: pos, path: path });
                self.playVoice();
            }
        }

        --
         尝试播放语音,如果语音队列不为空则改变状态播放,否则置回状态
        
        private playVoice() {
            local service = battle.BattleService.getInstance();
            local ui = UIManager.Instance.GetUI(battle.BattlePage);
            if (ui != null) {
                if (self.voiceQueue.length > 0) {
                    if (!service.isVoicing()) {
                        service.setSlice();
                        local voice = self.voiceQueue.shift();
                        self.showOrHideVoiceUi(true, voice.pos.toString());
                        self.currentVoice = voice;
                        RunTime.playVoiceRecord(true, voice.path, voice.pos.toString())
                        console.log("开始播放语音1");

                    }
                }
                else {
                    service.recoverMusic();
                }
            }
        }

        --
         对处于语音状态时进行语音,主要播放sdk播放回调调用,用于继续下条语音的播放
        
        function ChatService:playNextVoice(pos: string) {
            local ui = UIManager.Instance.GetUI<battle.BattlePage>(battle.BattlePage);
            local service = battle.BattleService.getInstance();
            self.isAutoStopCallBack = true;
            if (ui != null) {
                local service = battle.BattleService.getInstance();
                if (pos != "")
                    self.showOrHideVoiceUi(false, pos);
                console.log("播放下条语音=========================");
                if (self.voiceQueue.length <= 0) {
                    console.log("语音队列空,改回非语音状态");
                    service.recoverMusic();
                }
                else {
                    local voice = self.voiceQueue.shift();
                    self.showOrHideVoiceUi(true, voice.pos.toString());
                    self.currentVoice = voice;
                    RunTime.playVoiceRecord(true, voice.path, voice.pos.toString());
                    console.log("开始播放语音2");
                }
            }
            --如果退出了打牌界面则重置语音状态,并清空语音队列
            else {
                service.recoverMusic();
                self.voiceQueue = new Array();
            }

        }

        --
         设置生成语音的文件名
        
        private _fileName: string;
        private currentVoice: { pos: number, path: string };
        private reSetVoiceName() {
            self._fileName = new Date().getTime().toString();
        }

        function ChatService:getVoiceName() {
            return self._fileName;
        }
        --------------------------------------------------------------------------

        --记录是否是自动播放完还是手动结束语音
        function ChatService:isAutoStopCallBack = true;
        --
         开始录音,并停止所有声音,如果有其他语音正在播放则停止并加入队列头以便重新播放
        
        function ChatService:startToRecordVoice() {
            self.reSetVoiceName();
            local battleService = battle.BattleService.getInstance();
            console.log("开始录音开始================================");

            if (battleService.isVoicing()) {
                console.log("正在播放语音,取消后重新添加队列");
                self.isAutoStopCallBack = false;
                RunTime.stopPlayVoiceRecord();
                if (self.currentVoice != null) {
                    self.voiceQueue.unshift(self.currentVoice);
                    self.showOrHideVoiceUi(false, self.currentVoice.pos.toString());
                    self.currentVoice = null;
                }
            }
            else {
                console.log("没有播放语音,改变语音状态");
                battleService.setSlice();
            }

            RunTime.startVoiceRecord(self.getVoiceName(), self.getVoiceName());
        }
        --记录此次录音是否有效
        function ChatService:isEffectiveVoice: boolean;

        --停止录音,并设置是否上传,如果语音列表不为空则播放
        function ChatService:stopRecordVoice(isEffective: boolean) {
            console.log("============停止录音");

            local service = battle.BattleService.getInstance();
            self.isEffectiveVoice = isEffective;
            RunTime.stopVoiceRecord();
            self.playNextVoice("");
        }

        --
         显示或者隐藏说话动画
        
        private showOrHideVoiceUi(flag: boolean, pos: string) {
            local ui = UIManager.Instance.GetUI(battle.BattlePage);
            local ani = ui["aniVoice" + pos] as Laya.FrameClip;
            local voiceBox = ui["boxVoice" + pos] as Laya.Box;

            if (ani == null || voiceBox == null) {
                console.warn("语音参数错误");
                return;
            }
            --true为显示
            if (flag) {
                ani.loop = true;
                ani.play();
                voiceBox.visible = true;
            }
            else {
                ani.stop();
                voiceBox.visible = false;
            }
        }

        -- private errorMsg = "实时语音发送失败，请重试~";
        -- private timeLimit = 8000;
        -- private timerMap:kodUtil.Map<string,laya.utils.Timer> = new kodUtil.Map<string,laya.utils.Timer>();
        -- --处理语音超时错误
        -- function ChatService:setErrorTimer(fileName:string){
        --     local timer = new laya.utils.Timer() 
        --     self.timerMap.put(fileName,timer);
        --     timer.once(self.timeLimit,self,self.showErrorMsg);
        -- }

        -- function ChatService:cancelErrorTimer(fileName:string){
        --     self.timerMap.get(fileName).clearAll(self);
        --     self.timerMap.delete(fileName);
        -- }

        -- private showErrorMsg(){
        --     game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
        -- }
    }--]]