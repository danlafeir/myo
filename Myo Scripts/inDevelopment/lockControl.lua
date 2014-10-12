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

return Lock
