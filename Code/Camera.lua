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
    
    local rad=math.rad
    local ori = orientation or {0,0,0,1}
    local pos = position or {0,0,0}
    local rotM = getManager().getRotationManager(orientation,pos)
    local self = {
        cType = camType or CameraTypes.player,
        position = pos, 
        orientation = ori
    }
    rotM.assignFunctions(self)

    return self
end