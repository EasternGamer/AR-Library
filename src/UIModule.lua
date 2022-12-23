local atan = math.atan
local unpack,pairs,print = table.unpack, pairs, DUSystem.print

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
        print('ERROR: Font \'' .. font .. '\' not found!')
    end
end

function PathBuilder()
    local points = {}
    local c = 1
    local path = {}
    local pc = 1

    local table = table
    local concat,insert,pairs,print = table.concat, table.insert, pairs, print

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
            print('Invalid command for Smooth Cubic Curve, preceed with a cubic.')
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
            print('Invalid command for Smooth Quad Curve, preceed with a quad.')
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


function LoadUIModule(self, uiGroups, objectRotation)
    local rand = math.random

    function self.setUIElements(groupId)
        groupId = groupId or 1
        local remove,unpack = table.remove,table.unpack

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
        local DrawList = LinkedList('Draw', 'draw')
        local ActionList = LinkedList('Action', 'action')
        uiGroups[groupId] = {DrawList,ActionList}

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
            local resultantPos = {x,y,z}
            local mRot = getRotationManager(mainRotation,resultantPos, 'Element')
            objectRotation.addSubRotation(mRot)
            local elementData = {
                false,
                false,
                false,
                actions,
                1,
                false,
                pointSetX,
                pointSetY,
                resultantPos,
                false,
                mainRotation,
                false
            }
            function elementData.addSubElement(element)
                mRot.addSubRotation(element.getRotationManger())
            end
            function elementData.removeSubElement(element, deepDelete)
                mRot.removeSubRotation(element.getRotationManger())
                if deepDelete then
                    element.remove(deepDelete)
                else
                    objectRotation.addSubRotation(element.getRotationManager())
                end
            end
            function elementData.remove(deepDelete)
                if not removed then
                    local curSubList,size = mRot.getSubRotationData()
                    for i=1, size do
                        elementData.removeSubElement(curSubList[i], deepDelete)
                    end

                    DrawList.drawRemove(elementData)
                    ActionList.actionRemove(elementData)
                    mRot.remove()
                    removed = true
                else
                    print('Error: Trying to remove an already removed element.')
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
            function elementData.addPoints(points)
                local pntsX,pntsY = pointSetX,pointSetY
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

            mRot.assignFunctions(elementData)
            elementData.setPositionIsRelative(true)
            local function dataParityCheck(drawString)
                local count = select(2, drawString:gsub("%%", ""))
                local pointCount = (#elementData[7])*2
                local drawData = elementData[6]
                local drawDataCount = 0
                if drawData then
                    drawDataCount = drawDataCount + #drawData
                    local sizes = drawData.sizes
                    if sizes then
                        drawDataCount = drawDataCount + #sizes
                    end
                end
                drawDataCount = pointCount + drawDataCount
                if drawDataCount ~= count then
                    print('Input Parity Failed for ' .. elementData.toString() .. '. It has ' .. count .. ' in the draw string while it has ' .. drawDataCount .. ' values stored for access, with ' .. pointCount .. ' being point data. Try set the draw string last.')
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
                elementData[12] = defaultDraw
                elementData.showDraw()
            end
            local function actionCheck()
                elementData.showActionable()
            end

            function elementData.setHoverDraw(hDraw) elementData[1] = hDraw; dataParityCheck(hDraw); drawChecks() end
            function elementData.setDefaultDraw(dDraw) elementData[2] = dDraw; dataParityCheck(dDraw); drawChecks() end
            function elementData.setClickDraw(cDraw) elementData[3] = cDraw; dataParityCheck(cDraw); drawChecks() end

            function elementData.setClickAction(action) actions[1] = action; actionCheck() end
            function elementData.setHoldAction(action) actions[2] = action; actionCheck() end
            function elementData.setEnterAction(action) actions[3] = action; actionCheck() end
            function elementData.setLeaveAction(action) actions[4] = action; actionCheck() end
            function elementData.setHoverAction(action) actions[5] = action; actionCheck() end

            function elementData.setScale(scale)
                elementData[5] = scale
            end

            function elementData.getMaxValues()
                return maxX,minX,maxY,minY
            end

            function elementData.hideDraw() DrawList.drawRemove(elementData) end
            function elementData.showDraw() DrawList.drawAdd(elementData) end
            function elementData.hideActionable() ActionList.actionRemove(elementData); mRot.disableNormal() end
            function elementData.showActionable() ActionList.actionAdd(elementData); mRot.enableNormal() end

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
                    elementData.setBounds(createBounds(pointSetX,pointSetY,boundScale))
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

            function elementData.setDrawData(drawData) elementData[6] = drawData end
            function elementData.getDrawData() return elementData[6] end
            function elementData.setSizes(sizes)
                if not elementData[6] then
                    elementData[6] = {['sizes'] = sizes}
                else
                    elementData[6].sizes = sizes
                end
            end

            function elementData.getPoints() return elementData[7],elementData[8] end

            function elementData.setPoints(pointsX,pointsY)
                if not pointsY then
                    elementData.addPoints(pointsX)
                else
                    pointSetX,pointSetY = pointsX,pointsY
                    elementData[7],elementData[8] = pointsX,pointsY
                end
            end

            function elementData.setBounds(bounds)
                elementData[10] = bounds
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
                if elementData[2] then
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
                    DUSystem.print('ERROR: Font \'' .. font .. '\' not found! Defaulting')
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
            local prevx,prevy = 0,0
            function userFunc.move(x,y)
                mx = mx - prevx + x
                my = my - prevy + y
                prevx = x
                prevy = y
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
function ProcessOrientations(predefinedRotations,vMX,vMY,vMZ,vMW,pxw,pzw)
    return function (el)
        local oRM = el[11]
        local fx, fy, fz, fw = oRM[1], oRM[2], oRM[3], oRM[4]
        local key = fx .. ',' .. fy .. ',' .. fz .. ',' .. fw
        local pMR = predefinedRotations[key]
        if pMR then
            goto skip
        end
        do
            local vMX,vMY,vMZ,vMW,pxw,pzw = vMX,vMY,vMZ,vMW,pxw,pzw
            local a, b, c, d =
            fx*vMW + fw*vMX + fy*vMZ - fz*vMY,
            fy*vMW + fw*vMY + fz*vMX - fx*vMZ,
            fz*vMW + fw*vMZ + fx*vMY - fy*vMX,
            fw*vMW - fx*vMX - fy*vMY - fz*vMZ
            pMR = {
                2*(0.5 - b*b - c*c)*pxw, 2*(a*c - b*d)*pxw,
                2*(a*b - c*d), 2*(b*c + a*d),
                2*(a*c + b*d)*pzw, 2*(0.5 - a*a - b*b)*pzw
            }
            predefinedRotations[key] = pMR
        end
        ::skip::
        return pMR
    end
end

function ProcessUIModule(zBC, uiGroups, zBuffer, zSorter,
                vXX,vXY,vXZ,
                vYX,vYY,vYZ,
                vZX,vZY,vZZ,
                eyeX,eyeY,eyeZ,
                proc,nearDivAspect)
    
    
    local unpack = unpack
    local move = table.move
    for i=1, #uiGroups do
        local elGroup = uiGroups[i]
        local elements,size = elGroup[1].drawGetData()
        for i=1,size do
            local el = elements[i]
            el.checkUpdate()
            local eO = el[9]
            local eXO, eYO, eZO = eO[1]-eyeX, eO[2]-eyeY, eO[3]-eyeZ
            local ywAdd = vYX*eXO + vYY*eYO + vYZ*eZO
            if ywAdd < 0 then
                goto behindElement
            end
            local unpackData = {}
            local uC = 1
            local xwAdd,zwAdd = vXX*eXO + vXY*eYO + vXZ*eZO,vZX*eXO + vZY*eYO + vZZ*eZO
            local xxMult,xzMult,yxMult,yzMult,zxMult,zzMult = unpack(proc(el))
            local scale,drawData,pointsX,pointsY = el[5],el[6],el[7],el[8]
            local sizes = drawData.sizes
            if sizes then
                for di=1,#sizes do
                    unpackData[uC] = atan(sizes[di], ywAdd) * nearDivAspect
                    uC = uC + 1
                end
            end
            local drawDataSize = #drawData
            move(drawData,1,drawDataSize,uC,unpackData)
            uC = uC + drawDataSize
            for ePC=1, #pointsX do
                local ex, ez = pointsX[ePC]*scale, pointsY[ePC]*scale

                local pz = yxMult*ex + yzMult*ez + ywAdd
                if pz < 0 then
                    goto behindElement
                end

                unpackData[uC] = (xxMult*ex + xzMult*ez + xwAdd) / pz
                unpackData[uC + 1] = (zxMult*ex + zzMult*ez + zwAdd) / pz
                uC = uC + 2
            end

            zBC = zBC + 1
            zSorter[zBC] = -ywAdd
            zBuffer[-ywAdd] = el[12]:format(unpack(unpackData))
            ::behindElement::
        end
    end
    return zBC
end

function ProcessActionEvents(uiGroups, oldSelected, isClicked, isHolding, mYW, mYX,mYY,mYZ, vX,vY,vZ, proc, P0XD,P0YD,P0ZD, sort)
    local aBuffer,aSorter,aBC = {},{},0
    for i=1, #uiGroups do
        local elGroup = uiGroups[i]
        local elements,size = elGroup[2].actionGetData()
        for m=1,size do
            local el = elements[m]
            el.checkUpdate()
            local eO = el[9]
            local eX, eY, eZ = eO[1], eO[2], eO[3]

            local eCZ = mYX*eX + mYY*eY + mYZ*eZ + mYW
            if eCZ < 0 then
                goto behindElement
            end

            aBC = aBC + 1
            local p0X, p0Y, p0Z = P0XD - eX, P0YD - eY, P0ZD - eZ

            local NX, NY, NZ = el.getNormal()
            local t = -(p0X*NX + p0Y*NY + p0Z*NZ)/(vX*NX + vY*NY + vZ*NZ)

            local function Process()
                local el = el
                local pMR,t = proc(el),t
                local px, py, pz = p0X + t*vX, p0Y + t*vY, p0Z + t*vZ
                local gx,gy,gz = px + eX, py + eY, pz + eZ
                if not pMR[7] then
                    local oRM = el[11]
                    local fx,fy,fz,fw = oRM[1],oRM[2],oRM[3],oRM[4]
                    local fxfz,fyfy,fyfw = fx*fz,fy*fy,fy*fw
                    pMR[7],pMR[8],pMR[9],pMR[10],pMR[11],pMR[12] =
                    2*(0.5-fyfy-fz*fz),
                    2*(fx*fy - fz*fw),
                    2*(fxfz + fyfw),
                    2*(fxfz - fyfw),
                    2*(fy*fz + fx*fw),
                    2*(0.5 - fx*fx - fyfy)
                end
                local eBounds = el[10]
                local inside = false

                local pX, pZ = pMR[7]*px + pMR[8]*py + pMR[9]*pz, pMR[10]*px + pMR[11]*py + pMR[12]*pz
                if type(eBounds) == "function" then
                   inside = eBounds(pX, pZ, t)
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
                    return false
                end
                local actions,clickDraw,hoverDraw = el[4],el[3],el[1]

                if not oldSelected then
                    local enter = actions[3]
                    if enter then
                        enter(el, pX, pZ, eX, eY, eZ, gx, gy, gz)
                    end
                    el[12] = hoverDraw
                elseif el == oldSelected[1] then
                    if isClicked then
                        local clickAction = actions[1]
                        if clickAction then
                            clickAction(el, pX, pZ, eX, eY, eZ, gx, gy, gz)
                            isClicked = false
                        end
                        el[12] = clickDraw
                    elseif isHolding then
                        local holdAction = actions[2]
                        if holdAction then
                            holdAction(el, pX, pZ, eX, eY, eZ, gx, gy, gz)
                        end
                        el[12] = clickDraw
                    else
                        local hoverAction = actions[5]
                        if hoverAction then
                            hoverAction(el, pX, pZ, eX, eY, eZ, gx, gy, gz)
                        end
                        el[12] = hoverDraw
                    end
                else
                    local enter = actions[3]
                    if enter then
                        enter(el, pX, pZ)
                    end
                    el[12] = hoverDraw
                    local leave = oldSelected[2][4]

                    oldSelected[1][12] = oldSelected[1][2]
                    if leave then
                        leave(oldSelected[1], oldSelected[3], oldSelected[4])
                    end

                end
                return {el, actions, pX, pZ}
            end
            aSorter[aBC] = t
            aBuffer[t] = Process
            ::behindElement::
        end
    end
    sort(aSorter)
    local newSelected = false
    for aC = 1, aBC do
        local tmp = aBuffer[aSorter[aC]]()
        if tmp then
            newSelected = tmp
            break
        end
    end
    if not newSelected and oldSelected then
        local leave = oldSelected[2][4]
        if leave then
            leave(oldSelected[1], oldSelected[3], oldSelected[4])
        end
    end
    return newSelected
end