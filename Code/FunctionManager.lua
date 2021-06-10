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
    local getPWorldPos = system.getPlayerWorldPos
    local sqrt = math.sqrt
    local atan = math.atan
    local asin = math.asin
    
    --- Core-based function calls
    local getCWorldPos = core.getConstructWorldPos
    local getCWorldOriR = core.getConstructWorldOrientationRight
    local getCWorldOriF = core.getConstructWorldOrientationForward
    local getCWorldOriU = core.getConstructWorldOrientationUp
    local getElementPositionById = core.getElementPositionById
    
    local hp = core.getMaxHitPoints()
    local cOff = 16
    if hp > 10000 then
        cOff = 128
    elseif hp > 1000 then
        cOff = 64
    elseif hp > 150 then
        cOff = 32
    end

    function self.getLocalToWorldConverter()
        local v1 = getCWorldOriR()
        local v2 = getCWorldOriF()
        local v3 = getCWorldOriU()
        local v1t = solve(v1, v2, v3, {1,0,0})
        local v2t = solve(v1, v2, v3, {0,1,0})
        local v3t = solve(v1, v2, v3, {0,0,1})
        return function(cref)
            return solve(v1t, v2t, v3t, cref)
        end
    end
    function self.getWorldToLocalConverter()
        local vc1 = getCWorldOriR()
        local vc2 = getCWorldOriF()
        local vc3 = getCWorldOriU()
        return function(world)
            return solve(vc1, vc2, vc3, world)
        end
    end

    function self.getTrueWorldPos()
        local cal = self.getLocalToWorldConverter()
        local cWorldPos = getCWorldPos()
        local pos = getElementPositionById(1)
        local offsetPosition = {pos[1] - cOff, pos[2] - cOff, pos[3] - cOff}
        local adj = cal(offsetPosition)
        local adjPos = {cWorldPos[1] - adj[1], cWorldPos[2] - adj[2], cWorldPos[3] - adj[3]}
        return adjPos
    end

    function self.getPlayerLocalPos(playerId)
        local c = self.getWorldToLocalConverter()
        local cWorldPos = self.getTrueWorldPos()
        local pWorldPos = getPWorldPos(playerId)
        local adjPos = c({pWorldPos[1] - cWorldPos[1], pWorldPos[2] - cWorldPos[2], pWorldPos[3] - cWorldPos[3]})
        adjPos = {-adjPos[1], adjPos[2], adjPos[3]}
        return adjPos
    end

    function self.rotationMatrixToQuaternion(rotM)
        local m11,m21,m31 = rotM[1],rotM[5],rotM[9]
        local m12,m22,m32 = rotM[2],rotM[6],rotM[10]
        local m13,m23,m33 = rotM[3],rotM[7],rotM[11]
        
        local t = m11 + m22 + m33
        if t > 0 then
            local s = 0.5 / sqrt(t + 1.0)
            return (m32 - m23) * s, (m13 - m31) * s, (m21 - m12) * s, 0.25 / s
        elseif m11 > m22 and m11 > m33 then
            local s = 2.0 * sqrt(1.0 + m11 - m22 - m33)
            return 0.25 * s, (m12 + m21) / s, (m13 + m31) / s, (m32 - m23) / s
        elseif m22 > m33 then
            local s = 2.0 * sqrt(1.0 + m22 - m11 - m33)
            return (m12 + m21) / s, 0.25 * s, (m23 + m32) / s, (m13 - m31) / s
        else
            local s = 2.0 * sqrt(1.0 + m33 - m11 - m22)
            return (m13 + m31) / s, (m23 + m32) / s, 0.25 * s, (m21 - m12) / s
        end
    end
    
    function self.rotationMatrixToEuler(rotM)
        local m11,m21,m31 = rotM[1],rotM[5],rotM[9]
        local m12,m22,m32 = rotM[2],rotM[6],rotM[10]
        local m13,m23,m33 = rotM[3],rotM[7],rotM[11]
        local y = 0
        
        if m13 >= 1 then
            y = asin(1)
        elseif m13 <=-1 then
            y = asin(-1)
        else
            y = asin(m13)
        end
        if abs(m13) < 0.9999999 then
            return {atan(-m23,m33), -y, -atan(-m12,m11)}
        else
            return {atan(m32, m22), -y, -0}
        end
    end
    
    function self.inverse(qX, qY, qZ, qW)
        local mag = qX*qX + qY*qY + qZ*qZ + qW*qW
        return -qX/mag, -qY/mag, -qZ/mag, qW/mag
    end
    
    function self.multiply(ax, ay, az, aw, bx, by, bz, bw)
        return ax*bw + aw*bx + ay*bz - az*by, ay*bw + aw*by + az*bx - ax*bz, az*bw + aw*bz + ax*by - ay*bx, aw*bw - ax*bx - ay*by - az*bz
    end
    
    function self.divide(ax, ay, az, aw, bx, by, bz, bw)
        local cx, cy, cz, cw = self.inverse(bx, by, bz, bw)
        return self.multiply(ax, ay, az, aw, cx, cy, cz, cw)
    end
    
    return self
end