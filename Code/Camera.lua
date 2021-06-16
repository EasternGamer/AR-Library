--[[
There are two main types of cameras, "fixed" and "player". 
The camera object object controls how you want the camera to behave.
 - For a "fixed" camera, you can think of the position as "fixed" unless you change the parameters yourself.
 - For a "player" camera, all rotations and positions are automatically handled and linked directly to your character
 
 This goes in a library.start() method.
]]
--[[
There are two main types of cameras, "fixed" and "player". 
The camera object object controls how you want the camera to behave.
 - For a "fixed" camera, you can think of the position as "fixed" unless you change the parameters yourself.
 - For a "player" camera, all rotations and positions are automatically handled and linked directly to your character
]]--
local rad = math.rad
cameraTypes = {
    fixed = {
        fLocal = {
            name = "fLocal",
            pitchPos = nil,
            pitchNeg = nil,
            headingPos = nil,
            headingNeg = nil,
            shift = {0.0, 0.0, 0.0}
        },
        fGlobal = {
            name = "fGlobal",
            pitchPos = nil,
            pitchNeg = nil,
            headingPos = nil,
            headingNeg = nil,
            shift = {0.0, 0.0, 0.0}
        }
    },
    player = {
        jetpack = {
            name = "jetpack",
            pitchPos = nil,
            pitchNeg = nil,
            headingPos = nil,
            headingNeg = nil,
            shift = {0.0, 0.0, 0.9}
        },
        planet = {
            name = "planet",
            pitchPos = rad(75),
            pitchNeg = rad(-75),
            headingPos = nil,
            headingNeg = nil,
            shift = {0.0, 0.0, 0.85}
        },
        construct = {
            name = "construct",
            pitchPos = rad(75),
            pitchNeg = rad(-75),
            headingPos = nil,
            headingNeg = nil,
            shift = {0.0, 0.0, 0.85}
        },
        chair = {
            firstPerson = {
                mouseControlled = {
                    name = "chairfp_mouse",
                    pitchPos = nil,
                    pitchNeg = nil,
                    headingPos = nil,
                    headingNeg = nil,
                    shift = {-0.1, 0.0, 0.65}
                },
                freelook = {
                    name = "chairfp_free",
                    pitchPos = rad(75),
                    pitchNeg = rad(-75),
                    headingPos = rad(95),
                    headingNeg = rad(-95),
                    shift = {-0.1, 0.0, 0.65}
                }
            },
            secondPerson = {
                name = "chairsp",
                pitchPos = 0,
                pitchNeg = 0,
                headingPos = 0,
                headingNeg = 0,
                shift = {0.0, 0.0, 0.0}
            },
            thirdPerson = {
                name = "chairtp",
                pitchPos = rad(84),
                pitchNeg = rad(-89),
                headingPos = nil,
                headingNeg = nil,
                shift = {0.0, 0.0, 0.0}
            }
        }
    }
}

local hp = core.getHitPoints()
local coreOffset = 16
if hp > 10000 then
    coreOffset = 128
elseif hp > 1000 then
    coreOffset = 64
elseif hp > 150 then
    coreOffset = 32
end

local function getChairPositions()
    local elementList = core.getElementIdList()
    local elementType = core.getElementTypeById
    local elementPos = core.getElementPositionById
    local coreOffset = coreOffset
    local positionList = {}
    local c = 1
    for i = 1, #elementList do
        local element = elementType(elementList[i])
        if element == "Gunner Module" then
            local elementP = elementPos(elementList[i])
            positionList[c] = {-(elementP[1] - coreOffset), elementP[2] - coreOffset, elementP[3] - coreOffset}
            c = c + 1
        end
        if element == "Command Seat Controller" then
            local elementP = elementPos(elementList[i])
            positionList[c] = {-(elementP[1] - coreOffset), elementP[2] - coreOffset, elementP[3] - coreOffset}
            c = c + 1
        end
        if element == "Wooden Chair" then
            local elementP = elementPos(elementList[i])
            positionList[c] = {-(elementP[1] - coreOffset), elementP[2] - coreOffset, elementP[3] - coreOffset}
            c = c + 1
        end
        if element == "Hovercraft Seat Controller" then
            local elementP = elementPos(elementList[i])
            positionList[c] = {-(elementP[1] - coreOffset), elementP[2] - coreOffset, elementP[3] - coreOffset}
            c = c + 1
        end
        -- Need to add more seat types here.
    end
    return positionList
end

function Camera(camType, position, orientation)
    local core = core
    local system = system
    local unit = unit
    local planetaryInfluence = unit.getClosestPlanetInfluence
    
    local isViewLocked = false
    
    local print = system.print
    local chairs = getChairPositions()
    local types = cameraTypes
    local rad = math.rad
    local abs = math.abs
    local position = {-position[1], position[2], position[3]}
    local self = {
        cType = camType,
        position = position, 
        orientation = {rad(orientation[1]), rad(orientation[2]), rad(orientation[3])},
        isViewLocked = isViewLocked,
        cameraShift
    }
    
    
    function self.rotateHeading(heading)
        self.orientation[2] = self.orientation[2] + rad(heading)
    end
    
    function self.rotatePitch(pitch)
        self.orientation[1] = self.orientation[1] + rad(pitch)
    end
    
    function self.rotateRoll(roll)
        self.orientation[3] = self.orientation[3] + rad(roll)
    end
    
    function self.setAlignmentType(alignmentType)
        self.cType = alignmentType
    end
    
    function self.setPosition(pos)
        self.position = {-pos[1], pos[2], pos[3]}
    end
    
    function self.setViewLock(isViewLocked)
        self.isViewLocked = isViewLocked
    end
    
    function self.getAlignmentType(ax, ay, az, aw, bodyX, bodyY, bodyZ)
        local playerType = types.player
        local alignmentType = playerType.construct
        if self.cType.name == "fLocal" then
            alignmentType = types.fixed.fLocal
            return alignmentType
        elseif self.cType.name == "fGlobal" then
            alignmentType = types.fixed.fGlobal
            return alignmentType
        end
        if ax ~= nil then
            if ax > 0.001 or ax < -0.001 or ay > 0.001 or ay < -0.001 then
                alignmentType = playerType.jetpack
            end
            if planetaryInfluence() > 0.85 then
                alignmentType = playerType.planet
            end
        
            local chairs = chairs
            local bodyX = bodyX
            local bodyY = bodyY
            local bodyZ = bodyZ
            local abs = abs
            for i = 1, #chairs do
                local chairPos = chairs[i]
                local difX = abs(chairPos[1] - bodyX)
                local difY = abs(chairPos[2] - bodyY)
                local difZ = abs(chairPos[3] - bodyZ)

                if difX < 0.4 and difY < 0.4 and difZ < 0.4 then
                    local switch = switched % 3
                    if switch == 0 then
                        local fp = playerType.chair.firstPerson
                        if self.isViewLocked then
                            alignmentType = fp.mouseControlled
                        else
                            alignmentType = fp.freelook
                        end
                        return alignmentType
                    elseif switch == 1 then
                        alignmentType = playerType.chair.thirdPerson
                        return alignmentType
                    elseif switch == 2 then
                        alignmentType = playerType.chair.secondPerson
                        return alignmentType
                    end
                end
            end
        end
        switched = 0
        return alignmentType
    end
    return self
end