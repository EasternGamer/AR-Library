positionTypes = {
    globalP=false,
    localP=true
}
orientationTypes = {
    globalO=false,
    localO=true 
}
local print = DUSystem.print
function ObjectGroup(objects, transX, transY)
    local objects=objects or {}
    local self={style='',gStyle='',class='default', objects=objects,transX=transX,transY=transY,enabled=true,glow=false,gRad=10,scale = false,isZSorting=true}
    function self.addObject(object, id)
        local id=id or #objects+1
        objects[id]=object
        return id
    end
    function self.removeObject(id) objects[id] = {} end

    function self.hide() self.enabled = false end
    function self.show() self.enabled = true end
    function self.isEnabled() return self.enabled end
    function self.setZSort(isZSorting) self.isZSorting = isZSorting end

    function self.setClass(class) self.class = class end
    function self.setStyle(style) self.style = style end
    function self.setGlowStyle(gStyle) self.gStyle = gStyle end
    function self.setGlow(enable,radius,scale) self.glow = enable; self.gRad = radius or self.gRad; self.scale = scale or false end 
    return self
end
ConstructReferential = getRotationManager({0,0,0,1},{0,0,0}, 'Construct')
ConstructReferential.assignFunctions(ConstructReferential)
ConstructOriReferential = getRotationManager({0,0,0,1},{0,0,0}, 'ConstructOri')
ConstructOriReferential.assignFunctions(ConstructOriReferential)
function Object(posType, oriType)

    local multiGroup,singleGroup,uiGroups={},{},{}
    local positionType=positionType
    local orientationType=orientationType
    local ori = {0,0,0,1}
    local position = {0,0,0}
    local objRotationHandler = getRotationManager(ori,position, 'Object Rotation Handler')
    
    local self = {
        true, -- 1
        multiGroup, -- 2
        singleGroup, -- 3
        uiGroups, -- 4
        ori, -- 5
        position, -- 6
        oriType, -- 7
        posType -- 8
    }
    objRotationHandler.assignFunctions(self)
    self.setPositionIsRelative(true)
    self.setPositionIsRelative = nil
    function self.hide() self[1] = false end
    function self.show() self[1] = true end

    local loadUIModule = LoadUIModule
    if loadUIModule == nil then
        print('No UI Module installed.')
        loadUIModule = function() end
    end
    local loadPureModule = LoadPureModule
    if loadPureModule == nil then
        print('No Pure Module installed.')
        loadPureModule = function() end
    end

    loadPureModule(self, multiGroup, singleGroup)
    loadUIModule(self, uiGroups, objRotationHandler)
    local function choose()
        objRotationHandler.remove()
        local oriType,posType = self[7],self[8]
        if oriType and posType then
            ConstructReferential.addSubRotation(objRotationHandler)
        elseif oriType then
            ConstructOriReferential.addSubRotation(objRotationHandler)
        end
        self.setDoRotateOri(oriType)
        self.setDoRotatePos(posType)
    end
    choose()
    function self.setOrientationType(orientationType)
        self[7] = orientationType
        choose()
    end
    function self.setPositionType(positionType)
        self[8] = positionType
        choose()
    end
    
    function self.getRotationManager()
        return objRotationHandler
    end
    function self.addSubObject(object)
        return objRotationHandler.addSubRotation(object.getRotationManager())
    end
    function self.removeSubObject(id)
        objRotationHandler.removeSubRotation(id)
    end

    return self
end

function ObjectBuilderLinear()
    local self = {}
    function self.setPositionType(positionType)
        local self = {}
        local positionType = positionType
        function self.setOrientationType(orientationType)
            local self = {}
            local orientationType = orientationType
            function self.build()
                return Object(positionType, orientationType)
            end
            return self
        end
        return self
    end
    return self
end