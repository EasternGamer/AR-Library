positionTypes = {
    globalP=1,
    localP=2
}
orientationTypes = {
    globalO=1,
    localO=2 
}

function ObjectGroup(style, objects, transX, transY)
    local objects=objects or {}
    local self={style=style,objects=objects,transX=transX,transY=transY,enabled=true}
    function self.addObject(object, id)
        local id=id or #objects+1
        objects[id]=object
        return id
    end
    function self.removeObject(id) objects[id] = {} end
    function self.hide() self.enabled = false end
    function self.show() self.enabled = true end
    function self.isEnabled() return self.enabled end
    return self
end

function Object(style, position, offset, orientation, positionType, orientationType, transX, transY)
    local rad,print=math.rad,system.print
    
    local position=position
    local positionOffset=offset
    local heading=rad(orientation[1])
    local pitch=rad(orientation[2])
    local roll=rad(orientation[3])
    
    local style=style
    local polylineGroups,circleGroups,curveGroups,customGroups,triangleGroups,subObjects={},{},{},{},{},{}
    local positionType=positionType
    local orientationType=orientationType
    
    local self = {polylineGroups,circleGroups,curveGroups,customGroups,triangleGroups,subObjects,
        positionType,
        orientationType,
        {pitch,heading,roll},
        style,
        position,
        offset,
        transX,
        transY
    }
    
    function self.setPolylines(groupId,style,points,scale)
        -- Polylines for-loop
        local group={style}
        local scale=scale or 1
        local offset=positionOffset
        local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
        for i=2,#points+1 do
            local line=points[i-1]
            local newPoints={}
            for k=1,#line do
                local point=line[k]
                newPoints[k]={point[1]/scale+offsetX,point[2]/scale-offsetY,point[3]/scale-offsetZ}
            end
            group[i]=newPoints
        end
        self[1][groupId]=group
    end
    
    function self.setCircles(groupId,style,scale)
        local group={style}
        local scale=scale or 1
        local c=2
        self[2][groupId]=group
        local offset=offset or positionOffset
        local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
        local self={}
        function self.addCircle(position,radius,fill)
            local self={}
            local position={position[1]/scale+offsetX,position[2]/scale-offsetY,position[3]/scale-offsetZ}
            local label,offX,offY,size,resize,action = nil,nil,nil,nil,false,nil

            function self.setLabel(lab,rs,s,ofX,ofY)
                label=lab
                offX=ofX or 0
                offY=ofY or 0
                size=s or 10
                resize=rs or false
                return self
            end
            function self.setActionFunction(actionFunction)
                action=actionFunction
                return self
            end
            function self.build()
                local circleObj={position,radius,fill,label,offX,offY,size,resize,actionFunction}
                group[c]=circleObj
                c=c+1
                return circleObj,c
            end
            return self
        end
        return self
    end

    function self.setCurves(groupId,style,scale)
        local scale=scale or 1
        local curves= {}
        local group={style,curves}
        local offset=positionOffset
        local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
        self[3][groupId]=group
        local self={}
        local c=1
        function self.circleBuilder()
            local self={}
            function self.createCircle(center,radius)
                local k=0.5522847498307933984023
                local radius=radius/scale
                local cX,cY,cZ=center[1]/scale+offsetX,center[2]/scale-offsetY,center[3]/scale-offsetZ
                local cPoints={
                    {cX,radius+cY,cZ},{radius*k+cX,radius+cY,cZ},{radius+cX,radius*k+cY,cZ},
                    {radius+cX,cY,cZ},{radius+cX,-radius*k+cY,cZ},{radius*k+cX,-radius+cY,cZ},
                    {cX,-radius+cY,cZ},{-radius*k+cX,-radius+cY,cZ},{-radius+cX,-radius*k+cY,cZ},
                    {-radius+cX,cY,cZ},{-radius+cX,radius*k+cY,cZ},{-radius*k+cX,radius+cY,cZ}
                }
                local resize,size=false,10
                local labelDat={nil,resize,size}
                local self={}
                
                function self.setLabel(label,resize,size)
                    local resize=resize or false
                    local size=size*0.002 or 0.05
                    labelDat={label,resize,size}
                    return self
                end
                function self.build()
                    local persCircleArray={1,cPoints,labelDat}
                    curves[c]=persCircleArray
                    c=c+1
                    return persCircleArray,c
                end
                return self
            end
            return self
        end
        function self.bezierBuilder()
            local self={}
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

    function self.setCustomSVGs(groupId,style,scale)
        local multiPoint={}
        local singlePoint={}
        local group={style,multiPoint,singlePoint}
        local scale=scale or 1
        local mC,sC=1,1
        self[4][groupId]=group
        local offset=positionOffset
        local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
        local self={}
        function self.addMultiPointSVG()
            local points={}
            local data=nil
            local drawFunction=nil
            local self={}
            local pC=1
            function self.addPoint(point)
                local point=point
                points[pC]={point[1]/scale+offsetX,point[2]/scale-offsetY,point[3]/scale-offsetZ}
                pC=pC+1
                return self
            end
            function self.bulkSetPoints(bulk)
                points=bulk
            end
            function self.setData(dat)
                data=dat
                return self
            end
            function self.setDrawFunction(draw)
                drawFunction=draw
                return self
            end
            function self.build()
                if pC > 0 then
                    if drawFunction ~= nil then
                        multiPoint[mC]={points, drawFunction, data}
                        mC=mC+1
                        return points
                    else print("WARNING! Malformed multi-point build operation, no draw function specified. Ignoring.")
                    end
                else print("WARNING! Malformed multi-point build operation, no points specified. Ignoring.")
                end
            end
            return self
        end
        function self.addSinglePointSVG()
            local point,drawFunction,data=nil,nil,nil
            local self={}
            function self.setPosition(position)
                point={position[1]/scale+offsetX,position[2]/scale-offsetY,position[3]/scale-offsetZ}
                return self
            end
            function self.setDrawFunction(draw)
                drawFunction=draw
                return self
            end
            function self.setData(dat)
                data=dat
                return self
            end
            function self.build()
                if point~=nil then
                    if drawFunction~=nil then
                        singlePoint[sC]={point,drawFunction,data}
                        sC=sC+1
                    else print("WARNING! Malformed single point build operation, no draw function specified. Ignoring.")
                    end
                else print("WARNING! Malformed single point build operation, no point specified. Ignoring.")
                end
            end
            return self
        end
        return self
    end
    function self.setTriangles(groupId,style,scale)
        local triangleInfo={}
        local points={}
        local group={style,triangleInfo,points}
        local scale=scale or 1
        local tC=1
        local vC=1
        self[5][groupId]=group
        local offset=positionOffset
        local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
        local self={}

        function self.addVertex(point)
            points[vC]={{point[1]/scale+offsetX,point[2]/scale-offsetY,point[3]/scale-offsetZ},{}}
            vC=vC+1
            return vC-1
        end
        function self.addTriangle(pointIndices,normal,color)
            for i=1,3 do
                local index=pointIndices[i]
                local pointInfo=points[index][2]
                
                pointInfo[#pointInfo+1]=tC
            end
            triangleInfo[tC]={{},normal,color}
            tC=tC+1
        end
        return self
    end
    
    function self.rotateHeading(heading) self[9][2]=self[9][2]+rad(heading) end
    function self.rotatePitch(pitch) self[9][1]=self[9][1]+rad(pitch) end
    function self.rotateRoll(roll) self[9][3]=self[9][3]+rad(roll) end
    function self.setPosition(posX, posY, posZ) self[11] = {posX, posY, posZ} end
    
    function self.addSubObject(object, id)
        local id=id or #self[6]+1
        self[6][id]=object
        return id
    end
    function self.removeSubObject(id)
        self[6][id]={}
    end
    
    function self.setSubObjects()
        local self={}
        local c=1
        function self.addSubObject(object)
            self[6][c]=object
            c=c+1
            return self
        end
        return self
    end
    
    return self
end

function ObjectBuilderLinear()
    local self={}
    function self.setStyle(style)
        local self={}
        local style=style
        function self.setPosition(pos)
            local self={}
            local pos=pos
            function self.setOffset(offset)
                local self={}
                local offset=offset
                function self.setOrientation(orientation)
                    local self={}
                    local orientation=orientation
                    function self.setPositionType(positionType)
                        local self={}
                        local positionType=positionType
                        function self.setOrientationType(orientationType)
                            local self={}
                            local orientationType = orientationType
                            local transX,transY=nil,nil
                            function self.setTranslation(translateX,translateY)
                                transX,transY=translateX,translateY
                                return self
                            end
                            function self.build()
                                return Object(style,pos,offset,orientation,positionType,orientationType,transX,transY)
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