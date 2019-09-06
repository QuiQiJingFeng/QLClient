local ns = namespace("manager")

local AudioManager = class("AudioManager")
ns.AudioManager = AudioManager

local _instance = nil
function AudioManager.getInstance()
	if not _instance then
		_instance = AudioManager.new()
	end
	return _instance
end

function AudioManager:ctor()
	self._audio = cc.SimpleAudioEngine:getInstance()
end

function AudioManager:init()
	local globalSetting = game.service.GlobalSetting.getInstance()
	local nobgmvolume = globalSetting.bgmVolume == -1.0
	local nosfxvolume = globalSetting.sfxVolume == -1.0	
	if nobgmvolume then
		globalSetting.bgmVolume = 0.5 --self:getMusicVolume()
	else
		self:setMusicVolume(globalSetting.bgmVolume)
	end
	if nosfxvolume then
		globalSetting.sfxVolume = 0.5 --self:getEffectVolume()
	else
		self:setEffectVolume(globalSetting.sfxVolume)		
	end
	if nobgmvolume or nosfxvolume then
		globalSetting:saveSetting()
	end	
end

function AudioManager:playMusic(filename, isLoop)
	if filename then	
		self._audio:playMusic(filename, isLoop or false)	
	end
end

function AudioManager:pauseMusic()
	self._audio:pauseMusic()
end

function AudioManager:resumeMusic()
	self._audio:resumeMusic()
end

function AudioManager:stopMusic(isReleaseData)
	self._audio:stopMusic(isReleaseData or false)
end

function AudioManager:playEffect(filename, isLoop)
	-- Logger.debug("PLAYEFFECT: %s VOL: %.2f", filename, cc.SimpleAudioEngine:getInstance():getEffectsVolume())
	if filename then
		if self._audio:getEffectsVolume() > 0 then
			return self._audio:playEffect(filename, isLoop or false)
		end
	end
end

function AudioManager:stopEffect(handle)
	self._audio:stopEffect(handle)	
end	

function AudioManager:setMusicVolume(value)
	value = cc.clampf(value, 0.0, 1.0)
	self._audio:setMusicVolume(value)
end	

function AudioManager:getMusicVolume()
	return self._audio:getMusicVolume()
end

function AudioManager:setEffectVolume(value)
	value = cc.clampf(value, 0.0, 1.0)
	self._audio:setEffectsVolume(value)
	if value == 0 then
		self._audio:stopAllEffects()
	end
end	

function AudioManager:getEffectVolume()
	return self._audio:getEffectsVolume()
end

function AudioManager:setMusicVolumeUser(value, persistent)
	value = cc.clampf(value, 0.0, 1.0)
	self:setMusicVolume(value)
	local globalSetting = game.service.GlobalSetting.getInstance()
	globalSetting.bgmVolume = value
	if persistent then globalSetting:saveSetting() end

	if value == 0.0 and device.platform == "windows" then
		self:stopMusic()
	end
end

function AudioManager:setEffectVolumeUser(value, persistent)
	value = cc.clampf(value, 0.0, 1.0)
	self:setEffectVolume(value)
	local globalSetting = game.service.GlobalSetting.getInstance()
	globalSetting.sfxVolume = value
	if persistent then globalSetting:saveSetting() end	
end

-- mute锁，防止连续调两次mute后声音再也不恢复了
local _muteDirty = false

function AudioManager:mute()
	if _muteDirty then return end
	_muteDirty = true
	self._savedEffectVolume = self:getEffectVolume()
	self._savedMusicVolume = self:getMusicVolume()
	self:setEffectVolume(0)
	self:setMusicVolume(0)
end

function AudioManager:unmute()
	if not _muteDirty then return end
	_muteDirty = false
	if self._savedEffectVolume and self._savedMusicVolume then
		self:setEffectVolume(self._savedEffectVolume)
		self:setMusicVolume(self._savedMusicVolume)
		self._savedEffectVolume = nil
		self._savedMusicVolume = nil
	end
end

function AudioManager:preloadMusic(filename)
    self._audio:preloadMusic(filename)
end

function AudioManager:preloadEffect(filename)
    self._audio:preloadEffect(filename)
end

function AudioManager:unloadEffect(filename)
    self._audio:unloadEffect(filename)
end

return AudioManager