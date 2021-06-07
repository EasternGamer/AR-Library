positionTypes = {
    globalP = "global",
    localP = "local"
}
orientationTypes = {
    globalO = "global",
    localO = "local" 
}
-- There are some "to investigate" parts in this, particularly the offset values.
-- To investigate simply means to make sure all is working as intended.
function Object(style, position, offset, orientation, positionType, orientationType)
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
        position = position
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
                newPoints[k] = {(point[1]) / scale + offsetX, -(point[2] / scale - offsetY), -(point[3] / scale  - offsetZ)}
            end
            group[i] = newPoints
        end
        self.polylineGroups[groupId] = group
    end
    
    function self.setCircles(groupId, style, scale, offset)
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
                -(position[2] - offsetY) / scale, 
                -(position[3] - offsetZ) / scale
            }
            function self.setLabel(label)
                local self = {}
                local label = label
                function self.setActionFunction(actionFunction)
                    local self = {}
                    function self.build()
                        group[c] = {position, radius, fill, label, actionFunction}
                        c = c + 1
                    end
                    return self
                end
                function self.build()
                    group[c] = {position, radius, fill, label, nil}
                    c = c + 1
                end
                return self
            end
            function self.build()
                group[c] = {position, radius, fill, nil, nil}
                c = c + 1
            end
            return self
        end
        return self
    end

    function self.setCurves(group, points) -- Currently placeholder
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
                    -(point[2] - offsetY) / scale, 
                    -(point[3] - offsetZ) / scale
                }
                pC = pC + 1
                return self
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
                    -(position[2] - offsetY) / scale, 
                    -(position[3] - offsetZ) / scale
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
                    if drawFuction ~= nil then
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
                            function self.build()
                                return Object(style, pos, offset, orientation, positionType, orientationType)
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