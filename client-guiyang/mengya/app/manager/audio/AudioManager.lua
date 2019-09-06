local AudioManager = class("AudioManager",audio)

local _instance = nil
function AudioManager:getInstance()
	if not _instance then
		_instance = AudioManager.new()
	end
	return _instance
end

function AudioManager:getMusicVolume()
    return self.super.getMusicVolume()
end

function AudioManager:setMusicVolume(volume)
    return self.super.setMusicVolume(volume)
end

function AudioManager:preloadMusic(filename)
    return self.super.preloadMusic(filename)
end

function AudioManager:playMusic(filename, isLoop)
    return self.super.playMusic(filename, isLoop)
end

function AudioManager:stopMusic(isReleaseData)
    return self.super.stopMusic(isReleaseData)
end

function AudioManager:pauseMusic()
    return self.super.pauseMusic()
end

function AudioManager:resumeMusic()
    return self.super.resumeMusic()
end

function AudioManager:rewindMusic()
    return self.super.rewindMusic()
end

function AudioManager:isMusicPlaying()
    return self.super.isMusicPlaying()
end

function AudioManager:getSoundsVolume()
    return self.super.getSoundsVolume()
end

function AudioManager:setSoundsVolume(volume)
    return self.super.setSoundsVolume(volume)
end

function AudioManager:playSound(filename, isLoop)
    return self.super.playSound(filename, isLoop)
end

function AudioManager:pauseSound(handle)
    return self.super.pauseSound(handle)
end

function AudioManager:pauseAllSounds()
    return self.super.pauseAllSounds()
end

function AudioManager:resumeSound(handle)
    return self.super.resumeSound(handle)
end

function AudioManager:resumeAllSounds()
    return self.super.resumeAllSounds()
end

function AudioManager:stopSound(handle)
    return self.super.stopSound(handle)
end

function AudioManager:stopAllSounds()
    return self.super.stopAllSounds()
end

function AudioManager:preloadSound(filename)
    return self.super.preloadSound(filename)
end

function AudioManager:unloadSound(filename)
    return self.super.unloadSound(filename)
end


return AudioManager