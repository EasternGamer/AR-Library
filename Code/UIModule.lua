
local atan = math.atan
local unpack = table.unpack

local TEXT_ARRAY = {
    lowercase = false,
    uppercase = true,
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
    [44] = {{0, -2, 2, 1}, 4,'M%g %gL%g %g',44}, -- ,
    [45] = {{2, 6, 6, 6}, 10,'M%g %gL%g %g',45}, -- -
    [46] = {{0, 0, 1, 0}, 3,'M%g %gL%g %g',46}, -- .
    [47] = {{2, 0, 10, 12}, 12,'M%g %gL%g %g',47}, -- /
    [48] = {{1, 0, 9, 0, 9, 12, 1, 12, 1, 0, 9, 12}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',48}, -- 0
    [49] = {{5, 0, 5, 12, 3, 10}, 10,'M%g %gL%g %gL%g %g',49}, -- 1
    
    [50] = {{1, 12, 9, 12, 9, 7, 1, 5, 1, 0, 9, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',50}, -- 2
    [51] = {{1, 12, 9, 12, 9, 0, 1, 0, 1, 6, 9, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',51}, -- 3
    [52] = {{1, 12, 1, 6,  9, 6, 9,12, 9, 0}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',52}, -- 4
    [53] = {{1, 0,  9, 0,  9, 6, 1, 7, 1, 12, 9, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',53}, -- 5
    [54] = {{1, 12, 1, 0,  9, 0, 9, 5, 1, 7}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',54}, -- 6
    [55] = {{1, 12, 9, 12, 9, 6, 5, 0}, 10,'M%g %gL%g %gL%g %gL%g %g',55}, -- 7
    [56] = {{1, 0, 9, 0, 9, 12, 1, 12, 1, 6, 9, 6}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',56}, -- 8
    [57] = {{9, 0, 9, 12, 1, 12, 1, 7, 9, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',57}, -- 9
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
    [92] = {{1, 12, 9, 0}, 10,'M%g %gL%g %g',92}, -- \
    [93] = {{2, 0, 6, 0, 6, 12, 2, 12}, 6,'M%g %gL%g %gL%g %gL%g %g',93}, -- ]
    [94] = {{2, 6, 4, 12, 6, 6}, 6,'M%g %gL%g %gL%g %g',94}, -- ^
    [95] = {{0, 0, 8, 0}, 10,'M%g %gL%g %g',95}, -- _
    [96] = {{2, 12, 6, 8}, 6,'M%g %gL%g %g',96}, -- `
    
    [123] = {{6, 0, 4, 2, 4, 10, 6, 12, 2, 6, 4, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',123}, -- {
    [124] = {{4, 0, 4, 5, 4, 6, 4, 12}, 6,'M%g %gL%g %g M%g %gL%g %g',124}, -- |
    [125] = {{4, 0, 6, 2, 6, 10, 4, 12, 6, 6, 8, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',125}, -- }
    [126] = {{0, 4, 2, 8, 6, 4, 8, 8}, 10,'M%g %gL%g %gL%g %gL%g %g',126} -- ~
}

STROKE_LINE_CAP = {
    butt = 'butt',
    round = 'round',
    square = 'square'
}
STROKE_LINE_JOIN = {
    miter = 'miter',
    miterclip = 'miter-clip',
    round = 'round',
    bevel = 'bevel',
    arcs = 'arcs'
}
function SetDefaultFont(font)
    local tmp = pcall(function() return require('Fonts/' .. font) end)
    if tmp then
        TEXT_ARRAY = require('Fonts/' .. font)
    else
        system.print('ERROR: Font \'' .. font .. '\' not found!')
    end
end

function PathBuilder()
    local points = {}
    local c = 1
    local path = {}
    local pc = 1
    
    local table = table
    local concat,insert,pairs = table.concat, table.insert, pairs
    
    local attributes = {
        Id = {nil,nil,'id','%s'},
        Class = {nil,nil,'class','%s'},
        Style = {nil,nil,'style','%s'},
        Fill = {nil,nil,'fill','%s'},
        FillOpacity = {nil,nil,'fill-opacity','%g'},
        Stroke = {nil,nil,'stroke','%s'},
        StrokeOpacity = {nil,nil,'stroke-opacity','%g'},
        StrokeWidth = {nil,nil,'stroke-width','%gpx'},
        StrokeLineCap = {nil,nil,'stroke-linecap','%s'},
        StrokeLineJoin = {nil,nil,'stroke-linejoin','%s'},
        StrokeMiterLimit = {nil,nil,'stroke-miterlimit','%g'},
        StrokeDashArray = {nil,nil,'stroke-dasharray','%s'},
        StrokeDashOffset = {nil,nil,'stroke-dashoffset','%s'}
    }
    
    local builder = {}
    local lastCommand = 0
    function builder.moveTo(x,y)
        lastCommand = 1
        points[c],points[c+1],path[pc] = x,y,'M%g %g'
        pc=pc+1
        c=c+2
        return builder
    end
    function builder.lineTo(x,y)
        points[c],points[c+1],path[pc] = x,y,'L%g %g'
        pc=pc+1
        c=c+2
        return builder
    end
    function builder.cubicCurve(cX1,cY1,cX2,cY2,x,y)
        lastCommand = 2
        points[c],points[c+1],points[c+2],points[c+3],points[c+4],points[c+5],path[pc] = cX1,cY1,cX2,cY2,x,y,'C%g %g %g %g %g %g'
        pc=pc+1
        c=c+6
        return builder
    end
    function builder.smoothCubicCurve(cX1,cY1,x,y)
        if lastCommand == 2 then
            points[c],points[c+1],points[c+2],points[c+3],path[pc] = cX1,cY1,x,y,'S%g %g %g %g'
            pc=pc+1
            c=c+4
        else
            system.print('Invalid command for Smooth Cubic Curve, preceed with a cubic.')
        end
        return builder
    end
    function builder.quadCurve(cX1,cY1,x,y)
        lastCommand = 3
        points[c],points[c+1],points[c+2],points[c+3],path[pc] = cX1,cY1,x,y,'Q%g %g %g %g'
        pc=pc+1
        c=c+4
        return builder
    end
    function builder.smoothQuadCurve(x,y)
        if lastCommand == 3 then
            points[c],points[c+1],path[pc] = x,y,'T%g %g'
            pc=pc+1
            c=c+2
        else
            system.print('Invalid command for Smooth Quad Curve, preceed with a quad.')
        end
        return builder
    end
    function builder.closePath()
        lastCommand = 0
        path[pc] = 'Z'
        pc=pc+1
        return builder
    end
    
    for k,v in pairs(attributes) do
        builder['set' .. k] = function(attribute, inTable) local attribution = attributes[k]; attribution[1],attribution[2] = attribute, inTable; return builder end
    end
    
    function builder.getPoints()
        return points
    end
    function builder.getResult()
        local sizes = {}
        local dataTable = {['sizes']=sizes}
        local dC = 1
        local pathString,pSC = {'<path '},2
        for k,v in pairs(attributes) do
            if v[1] then
                if v[2] then
                    if k == 'StrokeWidth' then
                        sizes[1] = v[1]
                        pSC = pSC+1
                        insert(pathString, 2,'stroke-width="' .. v[4] .. '" ')
                    else
                        dataTable[dC] = v[1]
                        dC = dC+1
                        pathString[pSC] = v[3] .. '="' .. v[4] .. '" '
                        pSC = pSC+1
                    end
                elseif v[2] == false or v[2] == nil then
                    if k == 'StrokeWidth' then
                        pSC = pSC+1
                        insert(pathString, 2,'stroke-width="' .. v[1] .. 'px" ')
                    else
                        pathString[pSC] = v[3] .. '="' .. v[1] .. '" '
                        pSC = pSC+1
                    end
                end
            end
        end
        pathString[pSC] = 'd="'
        pathString[pSC+1] = concat(path)
        pathString[pSC+2] = '"/>'
        return concat(pathString), dataTable, points
    end
    return builder
end


function LoadUIModule(self, uiGroups, manager, RotationHandler)
    local rand = math.random
    function self.setUIElements(groupId)
        groupId = groupId or 1
        local remove,unpack = table.remove,table.unpack

        local function createNormal(points, rx, ry, rz, rw)
            if #points < 3 then
                print("Invalid Point Set! Not enough points to create normal!")
                return false,false,false
            end
            return 2*(rx*ry-rz*rw),1-2*(rx*rx+rz*rz),2*(ry*rz+rx*rw)
        end
        local function createBounds(pointsX,pointsY,scale)
            local size = #pointsX
            if size >= 60 then return false end
            if scale == 1 then
                return {{unpack(pointsX)},{unpack(pointsY)}}
            else
                local bPointsX,bPointsY = {},{}
                for i=1,size do
                    bPointsX[i] = pointsX[i]*scale
                    bPointsY[i] = pointsY[i]*scale
                end
                return {bPointsX,bPointsY}
            end
        end
        
        local head = nil
        local tail = nil

        local self = {}

        local function createUITemplate(x,y,z)
            
            if not (x and y and z) then
                print('Invalid coordinate set for UI element, defaulting to 0, 0, 0.')
                x,y,z = 0, 0, 0
            end
            
            local removed = false
            local huge = math.huge
            local maxX,minX,maxY,minY = -huge,huge,-huge,huge
            local boundScale = 1
            
            local pointSetX,pointSetY = {},{}
            local actions = {false,false,false,false,false,false,false}
            local mainRotation = {0,0,0,1}
            local resultantPos = {x,y+rand()*0.00001,z}
            local mRot = RotationHandler(mainRotation,resultantPos)
            
            local elementData = {
                false, 
                false, 
                false, 
                actions, 
                1, 
                true, 
                false, 
                false, 
                pointSetX, 
                pointSetY, 
                resultantPos, 
                false,
                false,
                false,
                false, 
                mainRotation,
                mRot,
                true,
                subRotIndex = nil,
                nextNode = nil, 
                prevNode = nil,
                parentNode = nil,
                nextSubNode = nil, 
                prevSubNode = nil,
                head = nil, 
                tail = nil
            }
            
            
            if tail then
                tail.nextNode = elementData
                elementData.prevNode = tail
                tail = elementData
            else
                head = elementData
                tail = elementData
                uiGroups[groupId] = head
            end
            
            function elementData.addSubElement(element)
                if element then
                    element.parentNode = elementData
                    
                    local nodeTail = elementData.tail
                    if nodeTail then
                        nodeTail.nextSubNode = element
                        element.prevSubNode = nodeTail
                        elementData.tail = element
                    else
                        elementData.head = element
                        elementData.tail = element
                    end
                    element.subRotIndex = mRot.addSubRotation(element.getRotationManager())
                else
                    print("Sub element attempted to added is nil!")
                end
            end
            function elementData.removeSubElement(element, deepDelete)
                if element.parentElement == user then
                    mRot.removeSubRotation(element.subRotIndex)
                    element.parentNode = nil
                    element.subRotIndex = nil
                    local nextSubNode = element.nextSubNode
                    local prevSubNode = element.prevSubNode
                    if nextSubNode then
                       if prevSubNode then
                            nextSubNode.prevSubNode = prevSubNode
                            prevSubNode.nextSubNode = nextSubNode
                       else
                            nextSubNode.prevSubNode = nil
                            elementData.head = nextSubNode
                       end
                    else
                        if prevSubNode then
                            prevSubNode.nextSubNode = nil
                            elementData.tail = prevSubNode 
                        else
                            elementData.head = nil
                            elementData.tail = nil
                        end
                    end
                    local curSubNode = element.head
                    while curSubNode do
                        element.removeSubElement(curSubNode, deepDelete)
                        curSubNode = curSubNode.nextSubNode
                    end
                    if deepDelete then
                        element.remove(deepDelete)
                    end
                end
            end
            local function handleBound(x,y)
                if x > maxX then maxX = x end
                if x < minX then minX = x end
                if y > maxY then maxY = y end
                if y < minY then minY = y end
            end
            function elementData.addPoint(x,y)
                local pC = #pointSetX+1
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
            function elementData.addPoints(points,override)
                local pntsX,pntsY = nil,nil
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
                            local inc = 1
                            for i = 1, pointCount,2 do
                                local index = startIndex + inc
                                
                                local x,y = points[i],points[i+1]
                                handleBound(x,y)
                                
                                pntsX[index],pntsY[index] = x,y
                                inc = inc + 1
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
                
            function elementData.getRotationManager()
                return mRot
            end
            
            local function updateNormal()
                local curSubNode = elementData.head
                while curSubNode do
                    curSubNode.updateNormal()
                    curSubNode = curSubNode.nextSubNode
                end
                if elementData[15] then
                    elementData.setNormal(createNormal(pointSetX, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4]))
                end
            end
            elementData.updateNormal = updateNormal
            mRot.assignFunctions(elementData, updateNormal)
            local function dataParityCheck(drawString)
                local count = select(2, drawString:gsub("%%", ""))
                local otherCount = (#elementData[9])*2
                local drawData = elementData[8]
                local drawDataCount = 0
                if drawData then
                    drawDataCount = drawDataCount + #drawData
                    local sizes = drawData.sizes
                    if sizes then
                        drawDataCount = drawDataCount + #sizes
                    end
                end
                otherCount = otherCount + drawDataCount
                if otherCount ~= count then
                    print('Input Parity Failed for ' .. elementData.toString() .. '. It has ' .. count .. ' in the draw string while it has ' .. otherCount .. ' values stored for access, with ' .. drawDataCount .. ' being draw data. Try set the draw string last.')
                end
            end
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
            
            function elementData.setHoverDraw(hDraw) elementData[1] = hDraw; dataParityCheck(hDraw); drawChecks() end
            function elementData.setDefaultDraw(dDraw) elementData[2] = dDraw; dataParityCheck(dDraw); drawChecks() end
            function elementData.setClickDraw(cDraw) elementData[3] = cDraw; dataParityCheck(cDraw); drawChecks() end
            
            function elementData.setClickAction(action) actions[1] = action; actionCheck() end
            function elementData.setHoldAction(action) actions[2] = action; actionCheck() end
            function elementData.setEnterAction(action) actions[3] = action; actionCheck() end
            function elementData.setLeaveAction(action) actions[4] = action; actionCheck() end
            function elementData.setHoverAction(action) actions[5] = action; actionCheck() end
            function elementData.setIdentifier(identifier) actions[6] = identifier; end
            
            function elementData.setScale(scale) 
                elementData[5] = scale
            end
            
            function elementData.getMaxValues()
                return maxX,minX,maxY,minY
            end
            
            function elementData.hide() elementData[6] = false end
            function elementData.show() elementData[6] = true end
            function elementData.isShown() return elementData[6] end
            function elementData.hideDraw() elementData[18] = false end
            function elementData.showDraw() elementData[18] = true end
            
            function elementData.remove(deepDelete)
                if not removed then
                    local curSubNode = elementData.head
                    while curSubNode do
                        elementData.removeSubElement(curSubNode, deepDelete)
                        curSubNode = curSubNode.nextSubNode
                    end
        
                    local nextNode = elementData.nextNode
                    local prevNode = elementData.prevNode
                    if nextNode then
                        if prevNode then
                            nextNode.prevNode = prevNode
                            prevNode.nextNode = nextNode
                       else
                            nextNode.prevNode = nil
                            head = nextNode
                       end
                    else
                        if prevNode then
                            prevNode.nextNode = nil
                            tail = prevNode 
                        else
                            head = nil
                            tail = nil
                        end
                    end
                    local parentNode = elementData.parentNode
                    if parentNode then
                        parentNode.removeSubElement(elementData, deepDelete)
                    end
                    removed = true
                else
                    print('Error: Trying to remove an already removed element.')
                end
            end
            local psX,psY = 0,0
            function elementData.move(sx,sy,indices,updateHitbox)
                if not indices then
                    for i = 1, #pointSetX do
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
                end
                psX = sx
                psY = sy
                
                if updateHitbox then
                    user.setBounds(createBounds(pointSetX,pointSetY,boundScale))
                end
            end
            local ogPointSetX,ogPointSetY
            function elementData.moveTo(sx,sy,indices,updateHitbox,useOG)
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
                    elementData.setBounds(createBounds(pointSetX,pointSetY,boundScale))
                end
            end
            
            function elementData.setDrawOrder(indices)
                elementData[7] = indices
            end
            
            function elementData.setDrawData(drawData) elementData[8] = drawData end
            function elementData.getDrawData() return elementData[8] end
            function elementData.setSizes(sizes) 
                if not elementData[8] then
                     elementData[8] = {['sizes'] = sizes}
                else
                    elementData[8].sizes = sizes
                end
            end
            function elementData.getDrawOrder() return elementData[7] end
            
            function elementData.getPoints() return elementData[9],elementData[10] end
            
            function elementData.setPoints(pointsX,pointsY) 
                if not pointsY then 
                    user.addPoints(pointsX,true)
                else
                    pointSetX,pointSetY = pointsX,pointsY
                    elementData[9],elementData[10] = pointsX,pointsY
                end
            end
            
            function elementData.setNormal(nx,ny,nz)
                elementData[12],elementData[13],elementData[14] = nx,ny,nz
            end
            
            function elementData.setBounds(bounds)
                local nx, ny, nz = createNormal(pointSetX, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4])
                elementData.setNormal(nx,ny,nz)
                elementData[15] = bounds
            end
            
            function elementData.setBoundsScale(bScale)
                boundScale = bScale
            end
            
            function elementData.usePathBuilder(pathBuilder)
                local drawString,dataTable,points = pathBuilder.getResult()
                elementData.addPoints(points)
                elementData.setDrawData(dataTable)
                elementData.setDefaultDraw(drawString)
            end
            function elementData.toString()
                local typeOfElement = 'Generic'
                if elementData.setFontSize then
                    typeOfElement = 'Text'
                elseif elementData.setText then
                    typeOfElement = 'Button'
                elseif elementData.getProgress then
                    typeOfElement = 'Progress Bar'
                end
                return '[' .. typeOfElement .. '] ' .. elementData[2] 
            end
            
            function elementData.build(force, hasBounds)
                
                local nx, ny, nz = createNormal(pointSetX, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4])
                if nx then
                    if elementData[2] then
                        elementData.setNormal(nx,ny,nz)
                        if not force then
                            if hasBounds or hasBounds == nil then
                                elementData.setBounds(createBounds(pointSetX,pointSetY,boundScale))
                            else
                                elementData.setBounds(false)
                            end
                        end
                    else
                        print("Element Malformed: No default draw.")
                    end
                else
                    print("Element Malformed: Insufficient points.")
                end
            end
            return elementData
        end
        local pcall,require = pcall,require
        function self.createText(tx, ty, tz, font)
            local concat,byte,upper,lower = table.concat,string.byte,string.upper,string.lower
            
            local userFunc = createUITemplate(tx, ty, tz)
            local fontSpace = TEXT_ARRAY
            if font then
                
                local tmp = pcall(function() return require('Fonts/' .. font) end)
                if tmp then
                    fontSpace = require('Fonts/' .. font)
                else
                    system.print('ERROR: Font \'' .. font .. '\' not found! Defaulting')
                end
            end
            local textCache,offsetCacheX,offsetCacheY,txt = {},{},0,''
            local drawData = {['sizes']={0.08333333333},'white',1}
            local alignmentX,alignmentY = 'middle','middle'
            local wScale = 1
            local mx,my = 0,0
            local maxX,minX,maxY,minY = userFunc.getMaxValues()
            
            userFunc.setDrawData(drawData)
            local oldMax = userFunc.getMaxValues
            function userFunc.getMaxValues()
                return maxX,minX,maxY,minY
            end
            function userFunc.getText()
                return txt
            end
            local function buildTextCache(text)
                txt = text
                
                if not fontSpace.lowercase and fontSpace.uppercase then
                    text = upper(text)
                elseif fontSpace.lowercase and not fontSpace.uppercase then
                    text = lower(text)
                end
                local result = {byte(text, 1, #text)}
                textCache = {}
                local text_array = fontSpace
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
                local offsetY = offsetCacheY + my
                local woffsetX,offsetXCounter = offsetCacheX[1] + mx,1
                local fontSize = drawData.sizes[1] / wScale
                
                local pointsX,pointsY,drawStrings = {},{},{'<path stroke-width="%gpx" stroke="%s" stroke-opacity="%g" fill="none" d="'}
                local count = 1
                
                local textCacheSize = #textCache
                maxX,minX,maxY,minY = oldMax()
                for k = 1, textCacheSize do
                    local char = textCache[k]
                    drawStrings[k + 1] = char[3]
                    
                    local charPoints, charSize = char[1], char[2]
                    for m = 1, #charPoints, 2 do
                        local x,y = charPoints[m] * fontSize + woffsetX, charPoints[m + 1] * fontSize + offsetY
                        
                        handleBound(x,y)
                        
                        pointsX[count] = x
                        pointsY[count] = y
                        count = count + 1
                    end
                    woffsetX = woffsetX + charSize * fontSize
                    if char[4] == 10 then
                        offsetXCounter = offsetXCounter + 1
                        woffsetX = offsetCacheX[offsetXCounter] + mx
                        offsetY = offsetY - charSize * fontSize
                    end
                end

                drawStrings[textCacheSize+2] = '"/>'
                userFunc.setPoints(pointsX,pointsY)
                userFunc.setDefaultDraw(concat(drawStrings))
            end
            
            function userFunc.setText(text)
                buildTextCache(text)
                buildOffsetCache()
                buildPoints()
            end
            userFunc.usePathBuilder = nil
            
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
            
            return userFunc
        end

        function self.createButton(bx, by, bz)
            local userFunc = createUITemplate(bx, by, bz)
            local txtFuncs = nil
            function userFunc.setText(text,rx, ry, rz)
                rx,ry,rz = rx or 0, ry or -0.001, rz or 0
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
                    txtFuncs.setFontSize((size)*0.85)
                else
                    local size = theight/r1
                    txtFuncs.setFontSize((size)*0.75)
                end
                return txtFuncs
            end
            function userFunc.getText()
                return txtFuncs.getText()
            end
            local oldMove = userFunc.move
            function userFunc.move(sx,sy,indices,updateHitbox)
                oldMove(sx,sy,indices,updateHitbox)
                if txtFuncs then
                    txtFuncs.move(sx,sy)
                end
            end
            return userFunc
        end
        
        function self.createProgressBar(ex, ey, ez)
            
            local userFuncOut = createUITemplate(ex, ey, ez)
            local userFuncFill = createUITemplate(0, 0, 0)
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
                if progress == 0 then
                    userFuncFill.hide()
                else
                    if userFuncOut.isShown() then
                        userFuncFill.show()
                    end
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
            local oldShow = userFuncOut.show
            local oldHide = userFuncOut.hide
            function userFuncOut.hide()
                oldHide()
                userFuncFill.hide()
            end
            function userFuncOut.show()
                if progress ~= 0 then
                    userFuncFill.show()
                end
                oldShow()
            end
            
            userFuncOut.setFillPoints = userFuncFill.addPoints
            userFuncOut.getFillDrawData = userFuncFill.getDrawData
            userFuncOut.setFillDrawData = userFuncFill.setDrawData
            userFuncOut.setFillDraw = userFuncFill.setDefaultDraw
            userFuncOut.setFillOffsetPosition = userFuncFill.setPosition
            
            
            function userFuncOut.usePathBuilder(pathBuilder)
                local drawString,dataTable,points = pathBuilder.getResult()
                userFuncOut.addPoints(points)
                userFuncOut.setDrawData(dataTable)
                userFuncOut.setDefaultDraw(drawString)
            end
            
            function userFuncOut.useFillPathBuilder(pathBuilder)
                local drawString,dataTable,points = pathBuilder.getResult()
                userFuncOut.setFillPoints(points)
                userFuncOut.setFillDrawData(dataTable)
                userFuncOut.setFillDraw(drawString)
            end
            
            
            
            return userFuncOut
        end
        self.createCustomDraw = createUITemplate
        return self
    end
end
function ProcessUIModule(zBC, aBC, uiGroups, zBuffer, zSorter, aBuffer, aSorter,
                mXX, mXY, mXZ, mXW,
                mYX, mYY, mYZ, mYW,
                mZX, mZY, mZZ, mZW,
                P0XD, P0YD, P0YZ,
                vMX, vMY, vMZ, vMW,
                pxw, pzw)
    local predefinedRotation = {}
    for i=1, #uiGroups do
        local el = uiGroups[i]
        while el do
            if not el[6] then
                el = el.nextNode
                goto behindElement
            end
            el[17].checkUpdate()
            local doDraw = el[18]
            local eO = el[11]
            local eXO, eYO, eZO = eO[1], eO[2], eO[3]

            local eCZ = mYX*eXO + mYY*eYO + mYZ*eZO + mYW
            if eCZ < 0 then
                el = el.nextNode
                goto behindElement
            end

            local actions = el[4]
            local oRM = el[16]
            local fx, fy, fz, fw = oRM[1], oRM[2], oRM[3],-oRM[4]
            local key = fx .. ',' .. fy .. ',' .. fz .. ',' .. fw
            local pMR = predefinedRotation[key]
            if pMR then
                goto skip
            end
            if fw ~= -1 then
                local rx, ry, rz, rw =
                fx*vMW + fw*vMX + fy*vMZ - fz*vMY,
                fy*vMW + fw*vMY + fz*vMX - fx*vMZ,
                fz*vMW + fw*vMZ + fx*vMY - fy*vMX,
                fw*vMW - fx*vMX - fy*vMY - fz*vMZ

                local rxrx, ryry, rzrz = rx * rx, ry * ry, rz * rz
                pMR = {
                    (1 - 2*(ryry + rzrz))*pxw, 2*(rx*rz - ry*rw)*pxw,
                    2*(rx*ry - rz*rw), 2*(ry*rz + rx*rw),
                    2*(rx*rz + ry*rw)*pzw, (1 - 2*(rxrx + ryry))*pzw
                }
                predefinedRotation[key] = pMR
            else
                pMR = {mXX,mXZ,mYX,mYZ,mZX,mZZ}
                predefinedRotation[key] = pMR
            end
            ::skip::
            if el[15] and actions[7] then
                aBC = aBC + 1
                local p0X, p0Y, p0Z = P0XD - eXO, P0YD - eYO, P0ZD - eZO

                local NX, NY, NZ = el[12], el[13], el[14]
                local t = -(p0X * NX + p0Y * NY + p0Z * NZ) / (vx2 * NX + vy2 * NY + vz2 * NZ)
                local px, py, pz = p0X + t * vx2, p0Y + t * vy2, p0Z + t * vz2

                if not pMR[7] then
                    fw = -fw
                    local fyfy = fy*fy
                    pMR[7],pMR[8],pMR[9],pMR[10],pMR[11],pMR[12] = 
                    2*(0.5-fyfy-fz*fz),2*(fx*fy + fz*fw),2*(fx*fz - fy*fw),
                    2*(fx*fz + fy*fw),2*(fy*fz - fx*fw),2*(0.5 - fx*fx - fyfy)
                end
                if doDraw then
                    zBC = zBC + 1
                    zSorter[zBC] = eCZ
                    zBuffer[eCZ] = {
                        el,
                        false,
                        mXX*eXO + mXY*eYO + mXZ*eZO + mXW,
                        mZX*eXO + mZY*eYO + mZZ*eZO + mZW,
                        pMR,
                        isUI = true
                    }
                end
                local gX,gY,gZ = px + eXO, py + eYO, pz + eZO
                local depth = gX*gX+gY*gY+gZ*gZ
                local function retrieveFull()
                    return pMR[7]*px + pMR[8]*py + pMR[9]*pz,
                    pMR[10]*px + pMR[11]*py + pMR[12]*pz, 
                    gX, gY, gZ, eXO, eYO, eZO
                end
                local refEl = el
                local function retrieveInitial()
                    return refEl, eCZ, retrieveFull
                end
                aSorter[aBC] = depth
                aBuffer[depth] = retrieveInitial
            elseif doDraw then
                zBC = zBC + 1
                zSorter[zBC] = eCZ
                zBuffer[eCZ] = {
                    el,
                    false,
                    mXX*eXO + mXY*eYO + mXZ*eZO + mXW,
                    mZX*eXO + mZY*eYO + mZZ*eZO + mZW,
                    pMR,
                    isUI = true
                }
            end
            el = el.nextNode
            ::behindElement::
        end
    end
    return zBC, aBC
end

function ProcessUIEvents(aBuffer, zBuffer, aBC, oldSelected, isClicked, isHolding)
    local newSelected = false
    local notIntersected = true
    for aC = 1, aBC do
        local el,zDepth,retrieveFull = aBuffer[aSorter[aC]]()

        local drawForm = el[2]
        if notIntersected then
            local eBounds = el[15]
            local inside = false

            local pX, pZ, gx, gy, gz, eX, eY, eZ = retrieveFull()
            if type(eBounds) == "function" then
                inside = eBounds(pX, pZ, zDepth)
            else
                local eBX,eBY = eBounds[1],eBounds[2]
                local N = #eBX + 1
                local p1x, p1y = eBX[1], eBY[1]
                local offset = 0
                for eb = 2, N do
                    local mod = eb % N
                    if mod == 0 then
                        offset = 1
                    end
                    local index = mod + offset
                    local p2x, p2y = eBX[index], eBY[index]
                    local minY, maxY
                    if p1y < p2y then
                        minY, maxY = p1y, p2y
                    else
                        minY, maxY = p2y, p1y
                    end

                    if pZ > minY and pZ <= maxY then
                        local maxX = p1x > p2x and p1x or p2x

                        if pX <= maxX then
                            if p1y ~= p2y then
                                if p1x == p2x or pX <= (pZ - p1y) * (p2x - p1x) / (p2y - p1y) + p1x then
                                    inside = not inside
                                end
                            end
                        end
                    end
                    p1x, p1y = p2x, p2y
                end

            end
            if not inside then
                goto broke
            end
            local actions = el[4]
            notIntersected = false
            newSelected = {el, actions, pX, pZ}
            local identifier = uiElmt
            if not oldSelected then
                local enter = actions[3]
                if enter then
                    enter(el, pX, pZ, eX, eY, eZ, gx, gy, gz)
                end
            elseif newSelected[10] == oldSelected[10] then
                if isClicked then
                    local clickAction = actions[1]
                    if clickAction then
                        clickAction(el, pX, pZ, eX, eY, eZ, gx, gy, gz)
                        isClicked = false
                    end
                    drawForm = el[3]
                elseif isHolding then
                    local holdAction = actions[2]
                    if holdAction then
                        hovered = true
                        holdAction(el, pX, pZ, eX, eY, eZ, gx, gy, gz)
                    end
                    drawForm = el[3]
                else
                    local hoverAction = actions[5]
                    if hoverAction then
                        hovered = true
                        hoverAction(el, pX, pZ, eX, eY, eZ, gx, gy, gz)
                    end
                    drawForm = el[1]
                end
            else
                local enter = actions[3]
                if enter then
                    enter(el, pX, pZ)
                end
                local leave = oldSelected[2][4]
                if leave then
                    leave(oldSelected[1], pX, pZ)
                end

            end
            ::broke::
        end
        if el[18] then
            zBuffer[zDepth][2] = drawForm
        end
    end
    if not newSelected and oldSelected then
        local leave = oldSelected[2][4]
        if leave then
            leave(oldSelected[1], oldSelected[3], oldSelected[4])
        end
    end
    return newSelected, hovered
end

function RenderUIElement(uiElmt, distance, unpackData, uC, nearDivAspect)
    local el,drawForm,xwAdd,zwAdd,pMR=unpack(uiElmt)
    local xxMult,xzMult,yxMult,yzMult,zxMult,zzMult=unpack(pMR)
    if not drawForm then
        drawForm = el[2]
        if not drawForm then
            return '',uC
        end
    end
    local ywAdd = distance
    local count = 1

    local scale,drawOrder,drawData,pointsX,pointsY = el[5],el[7],el[8],el[9],el[10]

    local oUC = uC
    if drawData then
        local sizes = drawData.sizes
        if sizes then
            uC = uC + #sizes
        end
        uC = uC + #drawData
    end

    local broken = false
    local pointCount = #pointsX
    if not drawOrder then
        for ePC=1, pointCount do
            local ex, ez = pointsX[ePC]*scale, pointsY[ePC]*scale

            local pz = yxMult*ex + yzMult*ez + ywAdd
            if pz < 0 then
                return '',oUC
            end

            unpackData[uC] = (xxMult*ex + xzMult*ez + xwAdd) / pz
            unpackData[uC + 1] = (zxMult*ex + zzMult*ez + zwAdd) / pz
            uC = uC + 2
        end
    else
        while ePC <=pointCount do
            local ex, ez = pointsX[ePC]*scale, pointsY[ePC]*scale

            local pz = yxMult*ex + yzMult*ez + ywAdd
            if pz < 0 then
                return '',oUC
            end

            local px = (xxMult*ex + xzMult*ez + xwAdd) / pz
            local py = (zxMult*ex + zzMult*ez + zwAdd) / pz

            local indexList = drawOrder[ePC] or {}
            for i = 1, #indexList do
                local index = indexList[i] + (uC - 1)
                unpackData[index] = px
                unpackData[index + 1] = py
            end
        end
    end
    mUC = uC
    uC = oUC
    if drawData then
        local sizes = drawData["sizes"]
        if sizes then
            for i = 1, #sizes do
                unpackData[uC] = atan(sizes[i], distance) * nearDivAspect
                uC = uC + 1
            end
        end
        for dDC = 1, #drawData do
            unpackData[uC] = drawData[dDC]
            uC = uC + 1
        end
    end
    
    return drawForm,mUC
end