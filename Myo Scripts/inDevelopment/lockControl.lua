-- Unlock mechanism

Lock = {}

Lock.locked = true
Lock.unlockedSince = 0
Lock.UNLOCKED_TIMEOUT = 3200

function Lock.unlock()
    locked = false
    Lock.extendUnlock()
end

function Lock.extendUnlock()
    Lock.unlockedSince = myo.getTimeMilliseconds()
end

function Lock.lockOnInActivity()
	if Lock.unlocked then
        -- If we've been unlocked longer than the timeout period, lock.
        -- Activity will update unlockedSince, see extendUnlock() above.
        if myo.getTimeMilliseconds() - Lock.unlockedSince > Lock.UNLOCKED_TIMEOUT then
            myo.vibrate("short")
            Lock.unlocked = false
        end
    end
end

return Lock
