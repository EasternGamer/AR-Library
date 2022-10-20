function LoadPureModule(self, customGroups)
    
    function self.setCustomSVGs(groupId)
        local multiPoint={}
        local singlePoint={}
        local group={multiPoint,singlePoint}
        local groupId = groupId or #customGroups+1
        customGroups[groupId]=group
        local mC,sC=1,1

        local self={}
        local function setState(group, state)
            for i=1, #group do
                group[i][1] = state
            end
        end
        function self.hideSingle() setState(singlePoint,false) end
        function self.hideMulti() setState(multiPoint,false) end
        function self.showSingle() setState(singlePoint,true) end
        function self.showMulti() setState(multiPoint,true) end
        function self.show() setState(multiPoint,true); setState(singlePoint,true) end
        function self.hide() setState(multiPoint,false); setState(singlePoint,false) end
        function self.removeMultiPointSVG(id)
            for i=id,#multiPoint-1 do
                local mp = multiPoint[i+1]
                multiPoint[i] = mp
                mp.setId(i) 
            end
            mC=mC-1
        end
        function self.removeSinglePointSVG(id)
            for i=id,#singlePoint-1 do
                local sp = singlePoint[i+1]
                singlePoint[i] = sp
                sp.setId(i) 
            end
            sC=sC-1
        end
        function self.addMultiPointSVG()
            local pointSetX,pointSetY,pointSetZ={},{},{}
            local mp = {false,pointSetX,pointSetY,pointSetZ,false,false}
            local self={['id'] = mC}
            multiPoint[mC]=mp
            mC=mC+1
            local pC=1
            function mp.setId(newId)
                self.id = newId
            end
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
            local outArr = {false,false,false,false,false,false}
            local self={['id'] = sC}
            singlePoint[sC]= outArr
            sC=sC+1

            function outArr.setId(newId)
                self.id = newId
            end
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
end

function ProcessPureModule(zBC, dU, uC, customGroups, zBuffer, zSorter, isZSorting, drawStringData,
                mXX, mXY, mXZ, mXW,
                mYX, mYY, mYZ, mYW,
                mZX, mZY, mZZ, mZW)
    for cG = 1, #customGroups do
        local customGroup = customGroups[cG]
        local multiGroups = customGroup[1]
        local singleGroups = customGroup[2]
        for mGC = 1, #multiGroups do
            local multiGroup = multiGroups[mGC]
            local enabled = multiGroup[1]
            if not enabled then goto disabled end

            local tPointsX,tPointsY,tPointsZ = {},{},{}
            local pointsX,pointsY,pointsZ = multiGroup[2],multiGroup[3],multiGroup[4]
            local size = #pointsX
            local mGAvg,less = 0,0
            for pC=1,size do
                local x,y,z = pointsX[pC],pointsY[pC],pointsZ[pC]
                local pz = mYX*x + mYY*y + mYZ*z + mYW
                if pz < 0 then
                    less = less + 1
                    goto behindMG
                end

                tPointsX[pC] = (mXX*x + mXY*y + mXZ*z + mXW)/pz
                tPointsY[pC] = (mZX*x + mZY*y + mZZ*z + mZW)/pz
                tPointsZ[pC] = pz
                mGAvg=mGAvg + pz
                ::behindMG::
            end
            if less~=size then
                if isZSorting then
                    zBC = zBC + 1
                    zSorter[zBC] = depth
                    zBuffer[depth] = {
                        tPointsX,
                        tPointsY,
                        tPointsZ,
                        multiGroup[5],
                        multiGroup[6]
                    }
                else
                    drawStringData[dU],uC = multiGroup[5](tPointsX,tPointsY,tPointsZ,multiGroup[6],unpackData,uC)
                    dU = dU + 1
                end
            end
            ::disabled::
        end
        for sGC = 1, #singleGroups do
            local singleGroup = singleGroups[sGC]
            if not singleGroup[1] then goto disabled end
            local x,y,z = singleGroup[2], singleGroup[3], singleGroup[4]
            local pz = mYX*x + mYY*y + mYZ*z + mYW
            if pz < 0 then goto disabled end
            if isZSorting then
                zBC = zBC + 1
                zSorter[zBC] = pz
                zBuffer[pz] = {
                    (mXX*x + mXY*y + mXZ*z + mXW)/pz,
                    (mZX*x + mZY*y + mZZ*z + mZW)/pz,
                    singleGroup[5],
                    singleGroup[6],
                    isCustomSingle = true
                }
            else
                drawStringData[dU],uC = singleGroup[5]((mXX*x + mXY*y + mXZ*z + mXW)/pz,(mZX*x + mZY*y + mZZ*z + mZW)/pz,pz,singleGroup[6],unpackData,uC)
                dU = dU + 1
            end
            ::disabled::
        end
    end
    return zBC, dU, uC
end