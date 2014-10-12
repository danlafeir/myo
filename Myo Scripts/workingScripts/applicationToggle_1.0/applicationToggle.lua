scriptId = 'com.thalmic.scripts.applicationToggle'

-- Controls

function nextApplication()
    myo.keyboard("right_arrow", "press")
end

function prevApplication()
    myo.keyboard("left_arrow", "press", "shift")
end

function selectApplication()
    myo.keyboard("left_alt", "up")
end

function openApplicationToggle()
    myo.keyboard("left_alt", "down")
    myo.keyboard("tab", "press")
end

-- Helpers

-- Makes use of myo.getArm() to swap wave out and wave in when the armband is being worn on
-- the left arm. This allows us to treat wave out as wave right and wave in as wave
-- left for consistent direction. The function has no effect on other poses.
function conditionallySwapWave(pose)
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

-- Unlock mechanism

function unlock()
    unlocked = true
    extendUnlock()
end

function extendUnlock()
    unlockedSince = myo.getTimeMilliseconds()
end

-- Implement Callbacks

function onPoseEdge(pose, edge)
    -- Unlock
    myo.debug("onPoseEdge: " .. pose .. ", " .. edge)

    if pose == "thumbToPinky" then
        if edge == "off" then
            -- Unlock when pose is released in case the user holds it for a while.
            unlock()
        elseif edge == "on" and not unlocked then
            -- Vibrate twice on unlock.
            -- We do this when the pose is made for better feedback.
            myo.vibrate("short")
            myo.vibrate("short")
            extendUnlock()
        end
    end

    if pose == "fingersSpread" then 
        if unlocked and edge == "on" then
            openApplicationToggle()
        end
    end

    if pose == "fist" then 
        if unlocked and edge == "on" then
            selectApplication()
        end
    end

    -- 
    if pose == "waveIn" or pose == "waveOut" then

        if unlocked and edge == "on" then
            -- Deal with direction and arm.
            pose = conditionallySwapWave(pose)

            -- Determine direction based on the pose.
            if pose == "waveIn" then
                nextApplication()
            else
                prevApplication()
            end

            extendUnlock()
        end
    end
end

-- All timeouts in milliseconds.

-- Time since last activity before we lock
UNLOCKED_TIMEOUT = 3200

function onPeriodic()
    -- Lock after inactivity
    if unlocked then
        -- If we've been unlocked longer than the timeout period, lock.
        -- Activity will update unlockedSince, see extendUnlock() above.
        if myo.getTimeMilliseconds() - unlockedSince > UNLOCKED_TIMEOUT then
            myo.vibrate("short")
            unlocked = false
        end
    end
end

function onForegroundWindowChange(app, title)
    -- Here we want the process running for any application but have the lowest priority
    return true
end

function activeAppName()
    -- Return the active app name determined in onForegroundWindowChange
    return "applicationToggle"
end

function onActiveChange(isActive)
    --myo.debug("onActiveChange")
end