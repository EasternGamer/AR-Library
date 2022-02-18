positionTypes = {
    globalP=1,
    localP=2
}
orientationTypes = {
    globalO=1,
    localO=2 
}

local print = system.print

local TEXT_ARRAY = {
    [10] = {{}, 16,'',10},--new line
    [32] = {{}, 10,'',32}, -- space
    [33] = {{4, 0, 3, 2, 5, 2, 4, 4, 4, 12}, 10, 'M%g %gL%g %gL%g %gZ M%g %gL%g %g',33}, -- !
    [34] = {{2, 10, 2, 6, 6, 10, 6, 6}, 6,'M%g %gL%g %g M%g %gL%g %g',34}, -- "
    [35] = {{0, 4, 8, 4, 6, 2, 6, 10, 8, 8, 0, 8, 2, 10, 2, 2},  10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',35}, -- #
    [36] = {{6, 2, 2, 6, 6, 10, 4, 12, 4, 0}, 6,'M%g %gL%g %gL%g %g M%g %gL%g %g',36}, --$
    [37] = {{0, 0, 8, 12, 2, 10, 2, 8, 6, 4, 6, 2}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',37}, -- %
    [38] = {{8, 0, 4, 12, 8, 8, 0, 4, 4, 0, 8, 4}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',38}, --&
    [39] = {{0, 8, 0, 12}, 2,'M%g %gL%g %g',39}, --'
    
    [40] = {{6, 0, 2, 4, 2, 8, 6, 12}, 8,'M%g %gL%g %gL%g %gL%g %g',40}, --(
    [41] = {{2, 0, 6, 4, 6, 8, 2, 12}, 8,'M%g %gL%g %gL%g %gL%g %g',41}, --)
    [42] = {{0, 0, 4, 12, 8, 0, 0, 8, 8, 8, 0, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',42}, --*
    [43] = {{1, 6, 7, 6, 4, 9, 4, 3}, 10,'M%g %gL%g %gM%g %gL%g %g',43}, -- +
    [44] = {{-1, -2, 1, 1}, 4,'M%g %gL%g %g',44}, -- ,
    [45] = {{2, 6, 6, 6}, 10,'M%g %gL%g %g',45}, -- -
    [46] = {{0, 0, 1, 0}, 3,'M%g %gL%g %g',46}, -- .
    [47] = {{0, 0, 8, 12}, 10,'M%g %gL%g %g',47}, -- /
    [48] = {{0, 0, 8, 0, 8, 12, 0, 12, 0, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',48}, -- 0
    [49] = {{5, 0, 5, 12, 3, 10}, 10,'M%g %gL%g %gL%g %g',49}, -- 1
    
    [50] = {{0, 12, 8, 12, 8, 7, 0, 5, 0, 0, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',50}, -- 2
    [51] = {{0, 12, 8, 12, 8, 0, 0, 0, 0, 6, 8, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',51}, -- 3
    [52] = {{0, 12, 0, 6, 8, 6, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',52}, -- 4
    [53] = {{0, 0, 8, 0, 8, 6, 0, 7, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',53}, -- 5
    [54] = {{0, 12, 0, 0, 8, 0, 8, 5, 0, 7}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',54}, -- 6
    [55] = {{0, 12, 8, 12, 8, 6, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %g',55}, -- 7
    [56] = {{0, 0, 8, 0, 8, 12, 0, 12, 0, 6, 8, 6}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',56}, -- 8
    [57] = {{8, 0, 8, 12, 0, 12, 0, 7, 8, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',57}, -- 9
    [58] = {{4, 9, 4, 7, 4, 5, 4, 3}, 2,'M%g %gL%g %g M%g %gL%g %g',58}, -- :
    [59] = {{4, 9, 4, 7, 4, 5, 1, 2}, 5,'M%g %gL%g %g M%g %gL%g %g',59}, -- ;
    
    [60] = {{6, 0, 2, 6, 6, 12}, 6,'M%g %gL%g %gL%g %g',60}, -- <
    [61] = {{1, 4, 7, 4, 1, 8, 7, 8}, 8,'M%g %gL%g %g M%g %gL%g %g',61}, -- =
    [62] = {{2, 0, 6, 6, 2, 12}, 6,'M%g %gL%g %gL%g %g',62}, -- >
    [63] = {{0, 8, 4, 12, 8, 8, 4, 4, 4, 1, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',63}, -- ?
    [64] = {{8, 4, 4, 0, 0, 4, 0, 8, 4, 12, 8, 8, 4, 4, 3, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',64}, -- @
    [65] = {{0, 0, 0, 8, 4, 12, 8, 8, 8, 0, 0, 4, 8, 4}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',65}, -- A
    [66] = {{0, 0, 0, 12, 4, 12, 8, 10, 4, 6, 8, 2, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gZ',66}, --B
    [67] = {{8, 0, 0, 0, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',67}, -- C
    [68] = {{0, 0, 0, 12, 4, 12, 8, 8, 8, 4, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gZ',68}, -- D 
    [69] = {{8, 0, 0, 0, 0, 12, 8, 12, 0, 6, 6, 6}, 10, 'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',69}, -- E
    
    [70] = {{0, 0, 0, 12, 8, 12, 0, 6, 6, 6}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',70}, -- F
    [71] = {{6, 6, 8, 4, 8, 0, 0, 0, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',71}, -- G
    [72] = {{0, 0, 0, 12, 0, 6, 8, 6, 8, 12, 8, 0}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',72}, -- H
    [73] = {{0, 0, 8, 0, 4, 0, 4, 12, 0, 12, 8, 12}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',73}, -- I
    [74] = {{0, 4, 4, 0, 8, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',74}, -- J
    [75] = {{0, 0, 0, 12, 8, 12, 0, 6, 6, 0}, 10,'M%g %gL%g %g M%g %gL%g %gL%g %g',75}, -- K
    [76] = {{8, 0, 0, 0, 0, 12}, 10,'M%g %gL%g %gL%g %g',76}, -- L
    [77] = {{0, 0, 0, 12, 4, 8, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',77}, -- M
    [78] = {{0, 0, 0, 12, 8, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',78}, -- N
    [79] = {{0, 0, 0, 12, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gZ',79}, -- O
    
    [80] = {{0, 0, 0, 12, 8, 12, 8, 6, 0, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',80}, -- P
    [81] = {{0, 0, 0, 12, 8, 12, 8, 4, 4, 4, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',81}, -- Q
    [82] = {{0, 0, 0, 12, 8, 12, 8, 6, 0, 5, 4, 5, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',82}, -- R
    [83] = {{0, 2, 2, 0, 8, 0, 8, 5, 0, 7, 0, 12, 6, 12, 8, 10}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',83}, -- S
    [84] = {{0, 12, 8, 12, 4, 12, 4, 0}, 10,'M%g %gL%g %g M%g %gL%g %g',84}, -- T
    [85] = {{0, 12, 0, 2, 4, 0, 8, 2, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',85}, -- U
    [86] = {{0, 12, 4, 0, 8, 12}, 10,'M%g %gL%g %gL%g %g',86}, -- V
    [87] = {{0, 12, 2, 0, 4, 4, 6, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',87}, -- W
    [88] = {{0, 0, 8, 12, 0, 12, 8, 0}, 10,'M%g %gL%g %g M%g %gL%g %g',88}, -- X
    [89] = {{0, 12, 4, 6, 8, 12, 4, 6, 4, 0}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',89}, -- Y
    
    [90] = {{0, 12, 8, 12, 0, 0, 8, 0, 2, 6, 6, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',90}, -- Z
    [91] = {{6, 0, 2, 0, 2, 12, 6, 12}, 6,'M%g %gL%g %gL%g %gL%g %g',91}, -- [
    [92] = {{0, 12, 8, 0}, 10,'M%g %gL%g %g',92}, -- \
    [93] = {{2, 0, 6, 0, 6, 12, 2, 12}, 6,'M%g %gL%g %gL%g %gL%g %g',93}, -- ]
    [94] = {{2, 6, 4, 12, 6, 6}, 6,'M%g %gL%g %gL%g %g',94}, -- ^
    [95] = {{0, 0, 8, 0}, 10,'M%g %gL%g %g',95}, -- _
    [96] = {{2, 12, 6, 8}, 6,'M%g %gL%g %g',96}, -- `
    
    [123] = {{6, 0, 4, 2, 4, 10, 6, 12, 2, 6, 4, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',123}, -- {
    [124] = {{4, 0, 4, 5, 4, 6, 4, 12}, 6,'M%g %gL%g %g M%g %gL%g %g',124}, -- |
    [125] = {{4, 0, 6, 2, 6, 10, 4, 12, 6, 6, 8, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',125}, -- }
    [126] = {{0, 4, 2, 8, 6, 4, 8, 8}, 10,'M%g %gL%g %gL%g %gL%g %g',126} -- ~
}

function ObjectGroup(objects, transX, transY)
    local objects=objects or {}
    local self={style='',gStyle='',objects=objects,transX=transX,transY=transY,enabled=true,glow=false,gRad=10,scale = false}
    function self.addObject(object, id)
        local id=id or #objects+1
        objects[id]=object
        return id
    end
    function self.removeObject(id) objects[id] = {} end
    
    function self.hide() self.enabled = false end
    function self.show() self.enabled = true end
    function self.isEnabled() return self.enabled end
    
    function self.setStyle(style) self.style = style end
    function self.setGlowStyle(gStyle) self.gStyle = gStyle end
    function self.setGlow(enable,radius,scale) self.glow = enable; self.gRad = radius or self.gRad; self.scale = scale or false end 
    return self
end

function Object(position, orientation, positionType, orientationType)
    local rad,print,rand,manager=math.rad,system.print,math.random,getManager()
    local RotationHandler = manager.getRotationManager
    
    local customGroups,uiGroups={},{}
    local positionType=positionType
    local orientationType=orientationType
    local ori = {0,0,0,1}
    local objRotationHandler = RotationHandler(ori,position)

    local defs = {}
    local self = {
        true, -- 1
        customGroups, -- 2
        uiGroups, -- 3
        positionType, -- 4
        orientationType, -- 5
        ori, -- 6
        position -- 7
    }
    function self.hide() self[1] = false end
    function self.show() self[1] = true end

    function self.setCustomSVGs(groupId)
        local multiPoint={}
        local singlePoint={}
        local group={multiPoint,singlePoint}
        local groupId = groupId or #customGroups+1
        customGroups[groupId]=group
        local mC,sC=1,1
        
        local self={}
        function self.addMultiPointSVG()
            local mp = {}
            local pointSetX,pointSetY,pointSetZ={},{},{}
            
            local mp = {false,pointSetX,pointSetY,pointSetZ,false,false}
            multiPoint[mC]=mp
            mC=mC+1
            local self={}
            local pC=1
            function self.show() mp[1] = true end
            function self.hide() mp[1] = false end
            function self.addPoint(point)
                pointSetX[pC]=point[1]
                pointSetY[pC]=point[2]
                pointSetZ[pC]=point[3]
                pC=pC+1
                return self
            end
            function self.setPoints(bulk)
                for i=1,#bulk do
                    local point = bulk[i]
                    pointSetX[i]=point[1]
                    pointSetY[i]=point[2]
                    pointSetZ[i]=point[3]
                end
                pC=#points+1
                return self
            end
            function self.setDrawFunction(draw)
                mp[5] = draw
                return self
            end
            function self.setData(dat)
                mp[6] = dat
                return self
            end
            function self.build()
                if pC > 1 then
                   mp[1] = true
                else print("WARNING! Malformed multi-point build operation, no points specified. Ignoring.")
                end
            end
            return self
        end
        function self.addSinglePointSVG()
            local self={}
            local outArr = {false,false,false,false,false,false}
            singlePoint[sC]= outArr
            sC=sC+1
            function self.setPosition(position)
                outArr[2],outArr[3],outArr[4]=position[1],position[2],position[3]
                return self
            end
            function self.setDrawFunction(draw)
                outArr[5] = draw
                return self
            end
            function self.setData(dat)
                outArr[6] = dat
                return self
            end
            function self.show() outArr[1] = true end
            function self.hide() outArr[1] = false end
            function self.build()
                outArr[1] = true
                return self
            end
            return self
        end
        return self
    end
    function self.setUIElements(groupId)
        groupId = groupId or 1
        local remove,unpack = table.remove,table.unpack

        local function createNormal(points, rx, ry, rz, rw)
            if #points < 3 then
                print("Invalid Point Set!")
                return false,false,false
            end
            return 2*(rx*ry-rz*rw),1-2*(rx*rx+rz*rz),2*(ry*rz+rx*rw)
        end
        local function createBounds(pointsX,pointsY)
            local size = #pointsX
            if size >= 60 then return false end
            return {{unpack(pointsX)},{unpack(pointsY)}}
        end
        
        local elements = {}
        local modelElements = {}
        local elementClasses = {}
        
        local group = {elements,modelElements}

        uiGroups[groupId] = group

        local self = {}
        local pC, eC = 0, 0

        local function createUITemplate(x,y,z)
            
            local user = {}
            local raw = {}
            
            local huge = math.huge
            local maxX,minX,maxY,minY = -huge,huge,-huge,huge
            
            local pointSetX,pointSetY = {},{}
            local actions = {false,false,false,false,false,false,false}
            local mainRotation = {0,0,0,1}
            local resultantPos = {x,y+rand()*0.000001,z}
            local mRot = RotationHandler(mainRotation,resultantPos)
            
            local elementData = {false, false, false, actions, 1, true, false, false, pointSetX, pointSetY, resultantPos, false,false,false,false, mainRotation,mRot}
            local subElements = {}
            local elementIndex = eC + 1
            elements[elementIndex] = elementData
            eC = elementIndex
           
            function user.addSubElement(element)
                local index = #subElements + 1
                if element then
                    subElements[index] = element
                    mRot.addSubRotation(element.getRotationManager())
                end
                return index
            end
            function user.removeSubElement(index)
                remove(subElements, index)
            end
            function user.getId()
                return elementIndex
            end
            function elementData.getId()
                return elementIndex
            end
            local function handleBound(x,y)
                if x > maxX then maxX = x end
                if x < minX then minX = x end
                if y > maxY then maxY = y end
                if y < minY then minY = y end
            end
            function user.addPoint(x,y)
                local pC = #pointSet+1
                if x and y then
                    handleBound(x,y)
                    pointSetX[pC],pointSetY[pC] = x,y
                else
                    if type(x) == 'table' and #x > 0 then
                        local x,y = x[1], x[2]
                        handleBound(x,y)
                        pointSetX[pC],pointSetY[pC] = x,y
                    else
                        print('Invalid format for point.')
                    end
                end
            end
            function user.addPoints(points,override)
                local pntsX,pntsY
                if override then
                    pntsX,pntsY = {},{}
                    elementData[9],elementData[10] = pntsX,pntsY
                    pointSetX,pointSetY = pntsX,pntsY
                else
                    pntsX,pntsY = pointSetX,pointSetY
                end
                if points then
                    local pointCount = #points
                    if pointCount > 0 then
                        local pType = type(points[1])
                        if pType == 'number' then
                            local startIndex = #pntsX
                            for i = 1, pointCount,2 do
                                local index = startIndex + i
                                
                                local x,y = points[i],points[i+1]
                                handleBound(x,y)
                                
                                pntsX[index],pntsY[index] = x,y
                            end
                        elseif pType == 'table' then
                            
                            local startIndex = #pntsX
                            for i = 1, pointCount do
                                local index = startIndex + i
                                
                                local point = points[i]
                                local x,y = point[1],point[2]
                                handleBound(x,y)
                                
                                pntsX[index],pntsY[index] = x,y
                            end
                        else
                            print('No compatible format found.')
                        end
                    end
                end
            end
                
            function user.getRotationManager()
                return mRot
            end
            
            local function updateNormal()
                if elementData[15] then
                    user.setNormal(createNormal(pointSetX, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4]))
                end
            end
            
            mRot.assignFunctions(user, updateNormal)

            local function drawChecks()
                local defaultDraw = elementData[2]
                if defaultDraw then
                    if not elementData[3] then
                        elementData[3] = elementData[2]
                    end
                    if not elementData[1] then
                        elementData[1] = elementData[2]
                    end
                end
            end
            local function actionCheck()
                actions[7] = true
            end
            
            function user.setHoverDraw(hDraw) elementData[1] = hDraw; drawChecks() end
            function user.setDefaultDraw(dDraw) elementData[2] = dDraw; drawChecks() end
            function user.setClickDraw(cDraw) elementData[3] = cDraw; drawChecks() end
            
            function user.setClickAction(action) actions[1] = action; actionCheck() end
            function user.setHoldAction(action) actions[2] = action; actionCheck() end
            function user.setEnterAction(action) actions[3] = action; actionCheck() end
            function user.setLeaveAction(action) actions[4] = action; actionCheck() end
            function user.setHoverAction(action) actions[5] = action; actionCheck() end
            function user.setIdentifier(identifier) actions[6] = identifier; end
            
            function user.setScale(scale) 
                elementData[5] = scale
            end
            
            function user.getMaxValues()
                return maxX,minX,maxY,minY
            end
            
            function user.hide() elementData[6] = false end
            function user.show() elementData[6] = true end
            function user.isShown() return elementData[6] end  
            
            function user.remove() 
                remove(elements,elementIndex)
                remove(elementClasses,elementIndex)
                for i = elementIndex, eC do
                    elementClasses[i].setElementIndex(i)
                end
            end
            local psX,psY = 0,0
            function user.move(sx,sy,indices,updateHitbox)
                if not indices then
                    for i = 1, #pointSet do
                        pointSetX[i] = pointSetX[i] - psX + sx
                        pointSetY[i] = pointSetY[i] - psY + sy
                    end
                    maxX,minX,maxY,minY = maxX+sx,minX+sx,maxY+sy,minY+sy
                else
                    for i=1,#indices do
                        local index = indices[i]
                        pointSetX[index] = pointSetX[index] - psX + sx
                        pointSetY[index] = pointSetY[index] - psY + sy
                    end
                    -- TODO: Check min-max values and update accordingly
                end
                psX = sx
                psY = sy
                
                if updateHitbox then
                    user.setBounds(createBounds(pointSetX))
                end
            end
            local ogPointSetX,ogPointSetY
            function user.moveTo(sx,sy,indices,updateHitbox,useOG)
                if not indices then
                    print('ERROR: No indices specified!')
                else
                    if not ogPointSetX then
                        ogPointSetX = {unpack(pointSetX)}
                        ogPointSetY = {unpack(pointSetY)}
                    end
                    for i=1,#indices do
                        local index = indices[i]
                        if not useOG then
                            pointSetX[index] = sx
                            pointSetY[index] = sy
                        else
                            pointSetX[index] = ogPointSetX[index] + sx
                            pointSetY[index] = ogPointSetY[index] + sy
                        end
                    end
                end
                if updateHitbox then
                    user.setBounds(createBounds(pointSetX,pointSetY))
                end
            end
            
            function user.setDrawOrder(indices)
                elementData[7] = indices
            end
            
            function user.setDrawData(drawData) elementData[8] = drawData end
            function user.getDrawData() return elementData[8] end
            function user.setSizes(sizes) 
                if not elementData[8] then
                     elementData[8] = {['sizes'] = sizes}
                else
                    elementData[8].sizes = sizes
                end
            end
            function user.getDrawOrder() return elementData[7] end
            
            function user.getPoints() return elementData[9],elementData[10] end
            
            function user.setPoints(pointsX,pointsY) 
                if not pointsY then 
                    user.addPoints(pointsX,true)
                else
                    pointSetX,pointSetY = pointsX,pointsY
                    elementData[9],elementData[10] = pointsX,pointsY
                end
            end
            
            function user.setElementIndex(eI) elementIndex = eI end
            function user.getElementIndex(eI) return elementIndex end
            
            function user.setNormal(nx,ny,nz)
                elementData[12],elementData[13],elementData[14] = nx,ny,nz
            end
            
            function user.setBounds(bounds)
                elementData[15] = bounds
            end
            
            function user.build(force, hasBounds)
                
                local nx, ny, nz = createNormal(pointSetX, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4])
                if nx then
                    if elementData[2] then
                        user.setNormal(nx,ny,nz)
                        if not force then
                            if hasBounds or hasBounds == nil then
                                user.setBounds(createBounds(pointSetX,pointSetY))
                            else
                                user.setBounds(false)
                            end
                        end
                    else
                        print("Element Malformed: No default draw.")
                    end
                else
                    print("Element Malformed: Insufficient points.")
                end
            end
            return user, elementData
        end

        function self.createText(tx, ty, tz)
            local concat,byte,upper = table.concat,string.byte,string.upper
            
            local userFunc, textArr = createUITemplate(tx, ty, tz)
            
            local textCache,offsetCacheX,offsetCacheY,txt = {},{},0,''
            local drawData = {['sizes']={0.08333333333},'white',1}
            local alignmentX,alignmentY = 'middle','middle'
            local wScale = 1
            local mx,my = 0,0
            local maxX,minX,maxY,minY = userFunc.getMaxValues()
            
            userFunc.setDrawData(drawData)
            
            function userFunc.getMaxValues()
                return maxX,minX,maxY,minY
            end
            function userFunc.getText()
                return txt
            end
            local function buildTextCache(text)
                txt = text
                local result = {byte(upper(text), 1, #text)}
                textCache = {}
                local text_array = TEXT_ARRAY
                for k = 1, #result do
                    local charCode = result[k]
                    textCache[k] = text_array[charCode]
                end
            end
            local function buildOffsetCache()
                offsetCacheX = {0}
                local offsetXCounter = 1
                local tmpX,tmpY = 0,0
                local fontSize = drawData.sizes[1] / wScale
                
                for k = 1, #textCache do
                    local char = textCache[k]
                    if char[4] == 10 then
                        tmpY = tmpY + char[2] * fontSize
                        if alignmentX == "middle" then
                            tmpX = -tmpX * 0.5
                        elseif alignmentX == "end" then
                            tmpX = -tmpX
                        elseif alignmentX == "start" then
                            tmpX = 0
                        end
                        offsetCacheX[offsetXCounter] = tmpX
                        offsetXCounter = offsetXCounter + 1
                        tmpX = 0
                    else
                        tmpX = tmpX + char[2] * fontSize
                    end
                end
                if alignmentX == "middle" then
                    tmpX = -tmpX * 0.5
                elseif alignmentX == "end" then
                    tmpX = -tmpX
                elseif alignmentX == "start" then
                    tmpX = 0
                end
                if alignmentY == 'middle' then
                    tmpY = tmpY + 12 * fontSize
                    offsetCacheY = -tmpY * 0.5
                elseif alignmentY == 'top' then
                    tmpY = tmpY + 12 * fontSize
                    offsetCacheY = -tmpY
                elseif alignmentY == 'bottom' then
                    offsetCacheY = 0
                end
                offsetCacheX[offsetXCounter] = tmpX
            end
            
            local function handleBound(x,y)
                if x > maxX then
                    maxX = x
                end
                if x < minX then
                    minX = x
                end
                if y > maxY then
                    maxY = y
                end
                if y < minY then
                    minY = y
                end
            end
            
            local function buildPoints()
                local offsetY = offsetCacheY
                local woffsetX,offsetXCounter = offsetCacheX[1],1
                local fontSize = drawData.sizes[1] / wScale

                local pointsX,pointsY,drawStrings = {},{},{'<path stroke-width="%gpx" stroke="%s" stroke-opacity="%g" fill="none" d="'}
                local count = 1
                
                local textCacheSize = #textCache
                
                for k = 1, textCacheSize do
                    local char = textCache[k]
                    drawStrings[k + 1] = char[3]
                    
                    local charPoints, charSize = char[1], char[2]
                    for m = 1, #charPoints, 2 do
                        local x,y = charPoints[m] * fontSize + woffsetX + mx, charPoints[m + 1] * fontSize + offsetY + my
                        
                        handleBound(x,y)
                        
                        pointsX[count] = x
                        pointsY[count] = y
                        count = count + 1
                    end
                    woffsetX = woffsetX + charSize * fontSize
                    if char[4] == 10 then
                        offsetXCounter = offsetXCounter + 1
                        woffsetX = offsetCacheX[offsetXCounter]
                        offsetY = offsetY - charSize * fontSize
                    end
                end

                drawStrings[textCacheSize+2] = '"/>'
                local d = concat(drawStrings)
                userFunc.setDefaultDraw(d)
                userFunc.setClickDraw(d)
                userFunc.setPoints(pointsX,pointsY)
            end
            
            function userFunc.setText(text)
                buildTextCache(text)
                buildOffsetCache()
                buildPoints()
            end
            
            function userFunc.setWeight(scale)
                local sizes = drawData.sizes
                sizes[1] = sizes[1] / wScale
                wScale = scale or wScale
                sizes[1] = sizes[1] * wScale
                if #textCache > 0 then
                    buildPoints()
                end
            end
            local oldUserFunc = userFunc.move
            function userFunc.move(x,y)
                mx = mx + x
                my = my + y
                oldUserFunc(x,y)
            end
            function userFunc.setFontSize(size)
                local sizes = drawData.sizes
                sizes[1] = size * 0.08333333333
                if #textCache > 0 then
                    buildOffsetCache()
                    buildPoints()
                end
            end
            function userFunc.setAlignmentX(alignX)
                alignmentX = alignX
                if #textCache > 0 then
                    buildOffsetCache()
                    buildPoints()
                end
            end
            function userFunc.setAlignmentY(alignY)
                alignmentY = alignY
                if #textCache > 0 then
                    buildOffsetCache()
                    buildPoints()
                end
            end
            function userFunc.setFontColor(color)
                drawData[1] = color
            end
            function userFunc.setOpacity(opacity)
                drawData[2] = opacity
            end
            
            return userFunc,textTemplate
        end

        function self.createButton(bx, by, bz)
            local userFunc,button = createUITemplate(bx, by, bz)
            local txtFuncs
            function userFunc.setText(text,rx, ry, rz)
                rx,ry,rz = rx or 0, ry or -0.01, rz or 0
                if not txtFuncs then
                    txtFuncs = self.createText(bx+rx, by+ry, bz+rz)
                    userFunc.addSubElement(txtFuncs)
                else
                    txtFuncs.setPosition(bx+rx, by+ry, bz+rz)
                end
                local maxX,minX,maxY,minY = userFunc.getMaxValues()
                local cheight = maxY-minY
                local cwidth = maxX-minX
                txtFuncs.setText(text)
                
                local tMaxX,tMinX,tMaxY,tMinY = txtFuncs.getMaxValues()
                local theight = tMaxY-tMinY
                local twidth = tMaxX-tMinX
                local r1,r2 = theight/cheight,twidth/cwidth
                if r1 < r2 then
                    local size = theight/r2
                    txtFuncs.setFontSize((size)*0.75)
                else
                    local size = theight/r1
                    txtFuncs.setFontSize((size)*0.75)
                end
                return txtFuncs
            end
            return userFunc
        end
        
        function self.createProgressBar(ex, ey, ez)
            
            local userFuncOut,outline = createUITemplate(ex, ey, ez)
            local userFuncFill,fill = createUITemplate(0, 0, 0)
            userFuncFill.setPositionIsRelative(true)
            userFuncOut.addSubElement(userFuncFill)

            local sPointIndices = {}
            local ePointIndices = {}
            local intervals = {}
            local progress = 100
            
            function userFuncOut.getIntervals()
                return intervals
            end
            
            function userFuncOut.getProgress(pX)
                local points = userFuncFill.getPoints()
                if pX then
                    local c = intervals[1]
                    local xC = c[1]
                    
                    local prog = (pX - points[sPointIndices[1]])/xC
                    if prog < 0 then 
                        return 0.001 
                    elseif prog > 100 then 
                        return 100 
                    else 
                        return prog 
                    end
                end
                return progress
            end
            
            local function makeIntervals()
                
                local sPCount = #sPointIndices
                local ePCount = #ePointIndices
                
                local pointsX,pointsY = userFuncFill.getPoints()
                if #pointsX > 0 then
                    if sPCount == ePCount and sPCount > 0 then
                        for i=1, sPCount do
                            local sPI = sPointIndices[i]
                            local ePI = ePointIndices[i]
                            local xChangePercent = (pointsX[ePI]-pointsX[sPI]) * 0.01
                            local yChangePercent = (pointsY[ePI]-pointsY[sPI]) * 0.01
                            intervals[i] = {xChangePercent,yChangePercent}
                        end
                    end
                end
            end
            
            function userFuncOut.setStartIndices(indices)
                sPointIndices = indices
                makeIntervals()
            end
            
            function userFuncOut.setEndIndices(indices)
                ePointIndices = indices
                makeIntervals()
            end
            
            local addPointsOld = userFuncOut.addPoints
            function userFuncOut.addPoints(points)
                addPointsOld(points)
                makeIntervals()
            end
            
            function userFuncOut.setProgress(prog)
                progress = prog or 0
                if progress < 0 then
                    progress = 0
                end
                if progress > 100 then
                    progress = 100
                end
                local pointsX,pointsY = userFuncFill.getPoints()
                for i=1, #ePointIndices do
                    local c = intervals[i]
                    local sPI = sPointIndices[i]
                    local ePI = ePointIndices[i]
                    pointsX[ePI] = pointsX[sPI] + c[1] * progress
                    pointsY[ePI] = pointsY[sPI] + c[2] * progress
                end
            end
            userFuncOut.setFillPoints = userFuncFill.addPoints
            userFuncOut.getFillDrawData = userFuncFill.getDrawData
            userFuncOut.setFillDrawData = userFuncFill.setDrawData
            userFuncOut.setFillDraw = userFuncFill.setDefaultDraw
            userFuncOut.setFillOffsetPosition = userFuncFill.setPosition
            
            return userFuncOut
        end
        self.createCustomDraw = createUITemplate
        
        local mElementIndex = 0
        function self.create3DObject(x,y,z)
            local userFunc = {}
            local pointSet = {{},{},{},{}}
            local drawStrings = {}
            local faces = {}
            
            local actions = {false,false,false,false,false,false}
            
            local elementData = {is3D = true, false, false, false, actions, 1, true, false, false, pointSet, x, y, z,faces}
            local eC = mElementIndex + 1
            mElementIndex = eC
            local mElementIndex = eC
            modelElements[eC] = elementData
            function userFunc.setScale(scale) 
                elementData[5] = scale
            end
            function userFunc.addPoints(points,ref)
                local pntX,pntY,pntZ,rotation = pointSet[1],pointSet[2],pointSet[3],pointSet[4]
                local s1,s2 = #pntX, #points
                local total = s1+s2
                pntX[total] = false
                pntY[total] = false
                pntZ[total] = false
                
                for i=s1+1, total do
                    local pnt = points[i]
                    pntX[i] = pnt[1]
                    pntY[i] = pnt[2]
                    pntZ[i] = pnt[3]
                end
            end
            
            
            function userFunc.setFaces(newFaces,r,g,b)
                local concat,remove = table.concat,table.remove
                local pntX,pntY,pntZ = pointSet[1],pointSet[2],pointSet[3]
                
                local function getData(pointIndices)
                    local pntCount = #pointIndices
                    if pntCount > 2 then
                        local p1i,p2i,p3i = pointIndices[1],pointIndices[2],pointIndices[3]
                        local p1x,p1y,p1z,p2x,p2y,p2z,p3x,p3y,p3z = pntX[p1i],pntY[p1i],pntZ[p1i],pntX[p2i],pntY[p2i],pntZ[p2i],pntX[p3i],pntY[p3i],pntZ[p3i]
                        
                        local v1x,v1y,v1z = p2x-p1x,p2y-p1y,p2z-p1z
                        local v2x,v2y,v2z = p3x-p1x,p3y-p1y,p3z-p1z
                        local nx,ny,nz = v1y*v2z-v1z*v2y,v1z*v2x-v1x*v2z,v1x*v2y-v2x*v1y
                        local mag = (nx*nx+ny*ny+nz*nz)^(0.5)
                        nx,ny,nz = nx/mag,ny/mag,nz/mag
                        local pX,pY,pZ = p1x+p2x+p3x,p1y+p2y+p3y,p1z+p2z+p3z
                        local oData = nil
                        if pntCount == 4 then
                            local tmpOData = getData({pointIndices[4],pointIndices[1],pointIndices[3]})
                            if not (tmpOData[4] == nx and tmpOData[5] == ny and tmpOData[6] == nz) then
                                remove(pointIndices,4)
                                oData = tmpOData
                            end
         
                        end
                        local count = 3
                        local string = {'<path color=rgb(%.f,%.f,%.f) d="M%.1f %.1fL%.1f %.1f %.1f %.1f'}
                        local sCount = 2
                        for i=4, #pointIndices do
                            local pi = pointIndices[i]
                            pX,pY,pZ = pX + pntX[pi],pY+ pntY[pi],pZ+ pntZ[pi] 
                            count = count + 1
                            string[sCount] = ' %.1f %.1f'
                            sCount = sCount + 1
                        end
                        string[sCount] = 'Z"/>'
                        
                        return {pX/count,pY/count,pZ/count,nx,ny,nz,pointIndices,r,g,b,concat(string)},oData
                    end
                end
                local m = 1
                for i=1, #newFaces do
                    local data,oData = getData(newFaces[i])
                    faces[m] = data
                    m=m+1
                    if oData then
                        faces[m] = oData
                        m=m+1
                    end
                end
            end
            
            function userFunc.setDrawData(drawData) elementData[8] = drawData end
            
            return userFunc
        end
        return self
    end
    
    objRotationHandler.assignFunctions(self)
    self.rotateXYZ(orientation)
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
    function self.setPosition(pos)
        local self = {}
        function self.setOrientation(orientation)
            local self = {}
            function self.setPositionType(positionType)
                local self = {}
                function self.setOrientationType(orientationType)
                    local self = {}
                    function self.build()
                        return Object(pos, orientation, positionType, orientationType)
                    end
                    return self
                end
                return self
            end
            return self
        end
        return self
    end
    return self
end


