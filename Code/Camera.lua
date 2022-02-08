local rad = math.rad
CameraTypes={
    fixed={
        fLocal={
            name="fLocal",
            id = 0
        },
        fGlobal={
            name="fGlobal",
            id = 1
        }
    },
    player={
        name="player",
        id = 2
    }
}

function Camera(camType, position, orientation)
    
    local isViewLocked = false
    
    local rad=math.rad
    local ori = orientation or {0,0,0}
    local self = {
        cType = camType or CameraTypes.player,
        position = (position or {0,0,0}), 
        orientation = ori,
        isViewLocked = false
    }
    
    function self.rotateHeading(heading) self.orientation[2]=self.orientation[2]+rad(heading) end
    function self.rotatePitch(pitch) self.orientation[1]=self.orientation[1]+rad(pitch) end
    function self.rotateRoll(roll) self.orientation[3]=self.orientation[3]+rad(roll) end
    function self.setAlignmentType(alignmentType) self.cType = alignmentType end
    function self.setPosition(pos) self.position={pos[1],pos[2],pos[3]} end

    return self
end