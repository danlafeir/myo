scriptId = 'com.thalmic.scripts.spotify'

--Define the Spotify Controller

currentApp = ""

--Lock Module 
Lock = {}

Lock.unlocked = false
Lock.unlockedSince = 0
Lock.UNLOCKED_TIMEOUT = 3200

Lock.unlock = function()
    Lock.unlocked = true
    Lock.extendUnlock()
end

Lock.extendUnlock = function()
    Lock.unlockedSince = myo.getTimeMilliseconds()
end

Lock.lockOnInActivity = function()
    if Lock.unlocked then
        -- If we've been unlocked longer than the timeout period, lock.
        -- Activity will update unlockedSince, see extendUnlock() above.
        if myo.getTimeMilliseconds() - Lock.unlockedSince > Lock.UNLOCKED_TIMEOUT then
            myo.vibrate("short")
            Lock.unlocked = false
        end
    end
end

--Utility Module

Utility = {}

-- Makes use of myo.getArm() to swap wave out and wave in when the armband is being worn on
-- the left arm. This allows us to treat wave out as wave right and wave in as wave
-- left for consistent direction. The function has no effect on other poses
Utility.conditionallySwapWave = function(pose)
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

-- Spotify Controls

Spotify = {}

Spotify.nextSong = function()
    myo.keyboard("right_arrow", "press", "control")
end

Spotify.prevSong = function()
    myo.keyboard("left_arrow", "press", "control")
end

Spotify.playPause = function()
    myo.keyboard("space", "press")
end

Spotify.onPoseEdge = function(pose, edge)
    -- Unlock
    myo.debug("onPoseEdge: " .. pose .. ", " .. edge)

    if pose == "thumbToPinky" then
        if edge == "off" then
            -- Unlock when pose is released in case the user holds it for a while.
            Lock.unlock()
        elseif edge == "on" and not Lock.unlocked then
            -- Vibrate twice on unlock.
            -- We do this when the pose is made for better feedback.
            myo.vibrate("short")
            myo.vibrate("short")
            Lock.extendUnlock()
        end
    end

    if pose == "fingersSpread" then 
        if Lock.unlocked and edge == "on" then
            Spotify.playPause()
            Lock.extendUnlock()
        end
    end

    -- 
    if pose == "waveIn" or pose == "waveOut" then

        if Lock.unlocked and edge == "on" then
            -- Deal with direction and arm.
            pose = Utility.conditionallySwapWave(pose)

            -- Determine direction based on the pose.
            if pose == "waveOut" then
                Spotify.nextSong()
            else
                Spotify.prevSong()
            end

            Lock.extendUnlock()
        end
    end
end

-- Implement Callbacks

function onPoseEdge(pose, edge)
    if currentApp == "spotify" then
        Spotify.onPoseEdge(pose, edge)
    end
end

-- All timeouts in milliseconds.

function onPeriodic()
    -- Lock after inactivity
    Lock.lockOnInActivity()
end

function onForegroundWindowChange(app, title)
    -- Here we decide if we want to control the new active app.
    myo.debug("onForegroundWindowChange: " .. app .. ", " .. title)
    if title == string.match(title, '.*Spotify.*') then
        myo.debug("You are in control")
        currentApp = "spotify"
        return true
    end
    return false
end

function activeAppName()
    -- Return the active app name determined in onForegroundWindowChange
    return "spotiy"
end

function onActiveChange(isActive)
    myo.debug("onActiveChange")
    if not isActive then
        Lock.unlocked = false
    end
end