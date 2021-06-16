positionTypes = {
    globalP = "global",
    localP = "local"
}
orientationTypes = {
    globalO = "global",
    localO = "local" 
}

function ObjectGroup(style, objects, transX, transY)

    local objects = objects or {}
    local self = {style = style, objects = objects, transX = transX, transY = transY, enabled = true}
    function self.addObject(object, id)
        local id = id or #objects + 1
        objects[id] = object
        return id
    end
    function self.removeObject(id)
        objects[id] = {}
    end
    function self.hide()
        self.enabled = false
    end
    function self.show()
        self.enabled = true
    end
    return self
end

function Object(style, position, offset, orientation, positionType, orientationType, transX, transY)
    local rad = math.rad
    local print = system.print
    
    local position = position
    local positionOffset = offset
    local heading = rad(orientation[1])
    local pitch = rad(orientation[2])
    local roll = rad(orientation[3])
    
    local style = style
    local polylineGroups = {}
    local circleGroups = {}
    local curveGroups = {}
    local customGroups = {}
    local subObjects = {}
    local positionType = positionType
    local orientationType = orientationType
    
    local self = {
        polylineGroups = polylineGroups, 
        circleGroups = circleGroups, 
        curveGroups = curveGroups, 
        customGroups = customGroups,
        subObjects = subObjects,
        positionType = positionType,
        orientationType = orientationType,
        orientation = {pitch,heading,roll},
        style = style,
        position = position,
        offset = offset,
        transX,
        transY
    }
    
    function self.setPolylines(groupId, style, points, scale)
        -- Polylines for-loop
        local group = {style}
        local scale = scale or 1
        local offset = positionOffset
        local offsetX,offsetY,offsetZ = offset[1],offset[2],offset[3]
        for i = 2, #points do
            local line = points[i - 1]
            local newPoints = {}
            for k = 1, #line do
                local point = line[k]
                newPoints[k] = {(point[1]) / scale + offsetX, (point[2] / scale - offsetY), (point[3] / scale  - offsetZ)}
            end
            group[i] = newPoints
        end
        self.polylineGroups[groupId] = group
    end
    
    function self.setCircles(groupId, style, scale)
        local group = {
            style
        }
        local scale = scale or 1
        local c = 2
        self.circleGroups[groupId] = group
        local offset = offset or positionOffset
        local offsetX,offsetY,offsetZ = offset[1],offset[2],offset[3]
        local self = {}
        function self.addCircle(position, radius, fill)
            local self = {}
            local position = {
                (position[1] - offsetX) / scale,
                (position[2] - offsetY) / scale, 
                (position[3] - offsetZ) / scale
            }
            local label = nil
            local offX = nil
            local offY = nil
            local size = nil
            local resize = false
            local action = nil
            function self.setLabel(label, resize, size, offX, offY)
                label = label
                offX = offX or 0
                offY = offY or 0
                size = size or 10
                resize = resize or false
                return self
            end
            function self.setActionFunction(actionFunction)
                action = actionFunction
                return self
            end
            function self.build()
                local circleObj = {position,radius,fill,label,offX,offY,size,resize,actionFunction}
                group[c] = circleObj
                c = c + 1
                return circleObj,c
            end
            return self
        end
        return self
    end

    function self.setCurves(groupId, style, scale)
        local scale = scale or 1
        local curves = {}
        local group = {
            style,
            curves
        }
        local offset = positionOffset
        local offsetX,offsetY,offsetZ = offset[1],offset[2],offset[3]
        self.curveGroups[groupId] = group
        local self = {}
        local c = 1
        function self.circleBuilder()
            local self = {}
            function self.createCircle(center, radius)
                local k = 0.5522847498
                local radius = radius / scale
                local cX,cY,cZ = center[1]/scale+offsetX,center[2]/scale+offsetY, center[3]/scale+offsetZ
                local cPoints = {
                    {cX,radius+cY,cZ},
                    {radius*k+cX,radius+cY,cZ},
                    {radius+cX,radius*k+cY,cZ},
                    {radius+cX,cY,cZ},
                    {radius+cX,-radius*k+cY,cZ},
                    {radius*k+cX,-radius+cY,cZ},
                    {cX,-radius+cY,cZ},
                    {-radius*k+cX,-radius+cY,cZ},
                    {-radius+cX,-radius*k+cY,cZ},
                    {-radius+cX,cY,cZ},
                    {-radius+cX,radius*k+cY,cZ},
                    {-radius*k+cX,radius+cY,cZ}
                }
                local resize = false
                local size = 10
                local labelDat = {nil,resize,size}
                local self = {}
                
                function self.setLabel(label, resize, size)
                    local resize = resize or false
                    local size = size / 500 or 0.05
                    labelDat = {label, resize, size}
                    return self
                end
                function self.build()
                    local persCircleArray = {'circle', cPoints, labelDat}
                    curves[c]=persCircleArray
                    c=c+1
                    return persCircleArray, c
                end
                return self
            end
            return self
        end
        function self.bezierBuilder()
            local self = {}
            function self.createCurve(sP)
            end
            function self.addControlPoint(cP)
            end
            function self.addEndPoint(eP)
            end
            return self
        end
        return self
    end

    function self.setCustomSVGs(groupId, style, scale)
        local multiPoint = {}
        local singlePoint = {}
        local group = {
            style,
            multiPoint,
            singlePoint
        }
        local scale = scale or 1
        local mC = 1
        local sC = 1
        self.customGroups[groupId] = group
        local offset = positionOffset
        local offsetX,offsetY,offsetZ = offset[1],offset[2],offset[3]
        local self = {}
        function self.addMultiPointSVG()
            local points = {}
            local data = nil
            local drawFunction = nil
            local self = {}
            local pC = 1
            function self.addPoint(point)
                local point = point
                points[pC] = {
                    (point[1] + offsetX) / scale, 
                    (point[2] - offsetY) / scale, 
                    (point[3] - offsetZ) / scale
                }
                pC = pC + 1
                return self
            end
            -- ! This function applies no processing !
            function self.bulkSetPoints(bulk)
                points = bulk
            end
            function self.setData(dat)
                data = dat
                return self
            end
            function self.setDrawFunction(draw)
                
                drawFunction = draw
                return self
            end
            function self.build()
                if pC > 0 then
                    if drawFunction ~= nil then
                        multiPoint[mC] = {points, drawFunction, data}
                        mC = mC + 1
                        return points
                    else
                        print("WARNING! Malformed multi-point build operation, no draw function specified. Ignoring.")
                    end
                else
                    print("WARNING! Malformed multi-point build operation, no points specified. Ignoring.")
                end
            end
            return self
        end
        function self.addSinglePointSVG()
            local point = nil
            local drawFunction = nil
            local data = nil
            local self = {}
            function self.setPosition(position)
                point = {
                    (position[1] + offsetX) / scale, 
                    (position[2] - offsetY) / scale, 
                    (position[3] - offsetZ) / scale
                }
                return self
            end
            function self.setDrawFunction(draw)
                drawFunction = draw
                return self
            end
            function self.setData(dat)
                data = dat
                return self
            end
            function self.build()
                if point ~= nil then
                    if drawFunction ~= nil then
                        singlePoint[sC] = {point, drawFunction, data}
                        sC = sC + 1
                    else
                        print("WARNING! Malformed single point build operation, no draw function specified. Ignoring.")
                    end
                else
                    print("WARNING! Malformed single point build operation, no point specified. Ignoring.")
                end
            end
            return self
        end
        return self
    end
    
    function self.rotateHeading(heading)
        self.orientation[2] = self.orientation[2] + rad(heading)
    end
    
    function self.rotatePitch(pitch)
        self.orientation[1] = self.orientation[1] + rad(pitch)
    end
    
    function self.rotateRoll(roll)
        self.orientation[3] = self.orientation[3] + rad(roll)
    end
    
    function self.setPosition(posX, posY, posZ)
        self.position = {posX, posY, posZ}
    end
    
    function self.addSubObject(object, id)
        local id = id or #self.subObjects+1
        self.subObjects[id] = object
        return id
    end
    function self.removeSubObject(id)
        self.subObjects[id] = {}
    end
    
    function self.setSubObjects()
        local self = {}
        local c = 1
        function self.addSubObject(object)
            subObjects[c] = object
            c = c + 1
            return self
        end
        return self
    end
    
    return self
end

function ObjectBuilderLinear()
    local self = {}
    function self.setStyle(style)
        local self = {}
        local style = style
        function self.setPosition(pos)
            local self = {}
            local pos = pos
            function self.setOffset(offset)
                local self = {}
                local offset = offset
                function self.setOrientation(orientation)
                    local self = {}
                    local orientation = orientation
                    function self.setPositionType(positionType)
                        local self = {}
                        local positionType = positionType
                        function self.setOrientationType(orientationType)
                            local self = {}
                            local orientationType = orientationType
                            local transX = nil
                            local transY = nil
                            function self.setTranslation(translateX, translateY)
                                transX = translateX
                                transY = translateY
                                return self
                            end
                            function self.build()
                                return Object(style, pos, offset, orientation, positionType, orientationType, transX, transY)
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
        return self
    end
    return self
end