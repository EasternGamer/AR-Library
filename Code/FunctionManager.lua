--[[
This is simply the "function manager". It handles some of the functions I frequently access. 
Optimally, I would have left this in the original projection code.
But for the sake of it being coherent I moved this to a seperate place.
This must go in one of the library.start() events.
]]
function getManager()
    local self = {}
    
    -- Misc function calls
    local solve = library.systemResolution3
    local getPlayerWorldPos = system.getPlayerWorldPos
    local sqrt = math.sqrt
    
    --- Core-based function calls
    local getConstructWorldPos = core.getConstructWorldPos
    local getConstructWorldOrientationRight = core.getConstructWorldOrientationRight
    local getConstructWorldOrientationForward = core.getConstructWorldOrientationForward
    local getConstructWorldOrientationUp = core.getConstructWorldOrientationUp
    local getElementPositionById = core.getElementPositionById
    
    local hp = core.getMaxHitPoints()
    local coreOffset = 16
    if hp > 10000 then
        coreOffset = 128
    elseif hp > 1000 then
        coreOffset = 64
    elseif hp > 150 then
        coreOffset = 32
    end

    function self.getLocalToWorldConverter()
        local vc1 = getConstructWorldOrientationRight()
        local vc2 = getConstructWorldOrientationForward()
        local vc3 = getConstructWorldOrientationUp()
        local vc1t = solve(vc1, vc2, vc3, {1,0,0})
        local vc2t = solve(vc1, vc2, vc3, {0,1,0})
        local vc3t = solve(vc1, vc2, vc3, {0,0,1})
        return function(cref)
            return solve(vc1t, vc2t, vc3t, cref)
        end
    end
    function self.getWorldToLocalConverter()
        local vc1 = getConstructWorldOrientationRight()
        local vc2 = getConstructWorldOrientationForward()
        local vc3 = getConstructWorldOrientationUp()
        return function(world)
            return solve(vc1, vc2, vc3, world)
        end
    end

    function self.getTrueWorldPos()
        local cal = self.getLocalToWorldConverter()
        local coreWorldPos = getConstructWorldPos()
        local position = getElementPositionById(1)
        local offsetPosition = {position[1] - coreOffset, position[2] - coreOffset, position[3] - coreOffset}
        local adjust = cal(offsetPosition)
        local adjustedPos = {coreWorldPos[1] - adjust[1], coreWorldPos[2] - adjust[2], coreWorldPos[3] - adjust[3]}
        return adjustedPos
    end

    function self.getPlayerLocalPos(playerId)
        local cal = self.getWorldToLocalConverter()
        local constructWorldPos = self.getTrueWorldPos()
        local playerWorldPos = getPlayerWorldPos(playerId)
        local adjustedPos = cal({playerWorldPos[1] - constructWorldPos[1], playerWorldPos[2] - constructWorldPos[2], playerWorldPos[3] - constructWorldPos[3]})
        adjustedPos = {-adjustedPos[1], adjustedPos[2], adjustedPos[3]}
        return adjustedPos
    end

    function self.rotationMatrixToQuaternion(rotM)
        local m11,m21,m31 = rotM[1],rotM[5],rotM[9]
        local m12,m22,m32 = rotM[2],rotM[6],rotM[10]
        local m13,m23,m33 = rotM[3],rotM[7],rotM[11]
        
        local sx,sy,sz,sw = 0,0,0,0
        
        local trace = m11 + m22 + m33
        if trace > 0 then
            local s = 0.5 / sqrt(trace + 1.0)
            sw = 0.25 / s
            sx = (m32 - m23) * s
            sy = (m13 - m31) * s
            sz = (m21 - m12) * s
        elseif m11 > m22 and m11 > m33 then
            local  s = 2.0 * sqrt(1.0 + m11 - m22 - m33)
            sw = (m32 - m23) / s
            sx = 0.25 * s
            sy = (m12 + m21) / s
            sz = (m13 + m31) / s
        elseif m22 > m33 then
            local  s = 2.0 * sqrt(1.0 + m22 - m11 - m33)
            sw = (m13 - m31) / s
            sx = (m12 + m21) / s
            sy = 0.25 * s
            sz = (m23 + m32) / s    
        else
            local s = 2.0 * sqrt(1.0 + m33 - m11 - m22)
            sw = (m21 - m12) / s
            sx = (m13 + m31) / s
            sy = (m23 + m32) / s
            sz = 0.25 * s
        end
        return sx, sy, sz, sw
    end
    
    function self.inverse(qX, qY, qZ, qW)
        local mag = qX*qX + qY*qY + qZ*qZ + qW*qW
        return -qX/mag, -qY/mag, -qZ/mag, qW/mag
    end
    
    function self.multiply(ax, ay, az, aw, bx, by, bz, bw)
        local x = ax*bw + aw*bx + ay*bz - az*by
        local y = ay*bw + aw*by + az*bx - ax*bz
        local z = az*bw + aw*bz + ax*by - ay*bx
        local w = aw*bw - ax*bx - ay*by - az*bz
        return x, y, z, w
    end
    
    function self.divide(ax, ay, az, aw, bx, by, bz, bw)
        local cx, cy, cz, cw = self.inverse(bx, by, bz, bw)
        return self.multiply(ax, ay, az, aw, cx, cy, cz, cw)
    end
    
    return self
end