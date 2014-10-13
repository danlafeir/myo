-- Application Toggle Controller

ApplicationToggle = {}

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

-- Implement Callbacks

function ApplicationToggle.onPoseEdge(pose, edge, lock, utility)
    -- Unlock
    myo.debug("onPoseEdge: " .. pose .. ", " .. edge)

    if pose == "thumbToPinky" then
        if edge == "off" then
            -- Unlock when pose is released in case the user holds it for a while.
            lock.unlock()
        elseif edge == "on" and not lock.unlocked then
            -- Vibrate twice on unlock.
            -- We do this when the pose is made for better feedback.
            myo.vibrate("short")
            myo.vibrate("short")
            lock.extendUnlock()
        end
    end

    if pose == "fingersSpread" then 
        if lock.unlocked and edge == "on" then
            openApplicationToggle()
            lock.extendUnlock()
        end
    end

    if pose == "fist" then 
        if lock.unlocked and edge == "on" then
            selectApplication()
            lock.extendUnlock()
        end
    end

    -- 
    if pose == "waveIn" or pose == "waveOut" then

        if lock.unlocked and edge == "on" then
            -- Deal with direction and arm.
            pose = utility.conditionallySwapWave(pose)

            -- Determine direction based on the pose.
            if pose == "waveIn" then
                nextApplication()
            else
                prevApplication()
            end

            lock.extendUnlock()
        end
    end
end