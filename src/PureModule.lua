function LoadPureModule(self, singleGroup, multiGroup)
    
    function self.getMultiPointBuilder(groupId)
        local builder = {}
        local multiplePoints = LinkedList('','')
        multiGroup[#multiGroup+1] = multiplePoints
        function builder.addMultiPointSVG()
            local shown = false
            local pointSetX,pointSetY,pointSetZ={},{},{}
            local mp = {pointSetX,pointSetY,pointSetZ,false,false}
            local self={}
            local pC=1
            function self.show() 
                if not shown then 
                    shown = true
                    multiplePoints.Add(mp)
                end
            end
            function self.hide()
                if shown then 
                    shown = false
                    multiplePoints.Remove(mp)
                end
            end
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
                pC=#bulk+1
                return self
            end
            function self.setDrawFunction(draw)
                mp[4] = draw
                return self
            end
            function self.setData(dat)
                mp[5] = dat
                return self
            end
            function self.build()
                if pC > 1 then
                    multiplePoints.Add(mp)
                    shown = true
                else print("WARNING! Malformed multi-point build operation, no points specified. Ignoring.")
                end
            end
            return self
        end
        return builder
    end
    
    function self.getSinglePointBuilder(groupId)
        local builder = {}
        local points = LinkedList('','')
        singleGroup[#singleGroup+1] = points
        function builder.addSinglePointSVG()
            local shown = false
            local outArr = {false,false,false,false,false}

            function self.setPosition(px,py,pz)
                if type(px) == 'table' then
                    outArr[1],outArr[2],outArr[3]=px[1],px[2],px[3]
                else
                    outArr[1],outArr[2],outArr[3]=px,py,pz
                end
                return self
            end
            
            function self.setDrawFunction(draw)
                outArr[4] = draw
                return self
            end
            
            function self.setData(dat)
                outArr[5] = dat
                return self
            end
            
            function self.show()
                if ~shown then
                    shown = true
                end
            end
            function self.hide() 
                if shown then
                    points.Remove(outArr)
                    shown = false
                end
            end
            function self.build()
                points.Add(outArr)
                shown = true
                return self
            end
            return self
        end
        return builder
    end
end

function ProcessPureModule(zBC, singleGroup, multiGroup, zBuffer, zSorter,
        mXX, mXY, mXZ,
        mYX, mYY, mYZ,
        mZX, mZY, mZZ,
        mXW, mYW, mZW)
    for cG = 1, #singleGroup do
        local group = singleGroup[cG]
        local singleGroups,singleSize = group.GetData()
        for sGC = 1, singleSize do
            local singleGroup = singleGroups[sGC]
            local x,y,z = singleGroup[1], singleGroup[2], singleGroup[3]
            local pz = mYX*x + mYY*y + mYZ*z + mYW
            if pz < 0 then goto disabled end
            zBC = zBC + 1
            zSorter[zBC] = -pz
            zBuffer[-pz] = singleGroup[4]((mXX*x + mXY*y + mXZ*z + mXW)/pz,(mZX*x + mZY*y + mZZ*z + mZW)/pz,pz,singleGroup[5])
            ::disabled::
        end
    end
    for cG = 1, #multiGroup do
        local group = multiGroup[cG]
        local multiGroups,groupSize = group.GetData()
        for mGC = 1, groupSize do
            local multiGroup = multiGroups[mGC]

            local tPointsX,tPointsY,tPointsZ = {},{},{}
            local pointsX,pointsY,pointsZ = multiGroup[1],multiGroup[2],multiGroup[3]
            local size = #pointsX
            local mGAvg = 0
            for pC=1,size do
                local x,y,z = pointsX[pC],pointsY[pC],pointsZ[pC]
                local pz = mYX*x + mYY*y + mYZ*z + mYW
                if pz < 0 then
                    goto disabled
                end

                tPointsX[pC],tPointsY[pC] = (mXX*x + mXY*y + mXZ*z + mXW)/pz,(mZX*x + mZY*y + mZZ*z + mZW)/pz
                mGAvg = mGAvg + pz
            end
            local depth = -mGAvg/size
            zBC = zBC + 1
            zSorter[zBC] = depth
            zBuffer[depth] = multiGroup[4](tPointsX,tPointsY,depth,multiGroup[5])
            ::disabled::
        end
    end
    return zBC
end