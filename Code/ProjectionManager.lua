function Projector(camera)
    -- Localize frequently accessed data
    --local utils = require("cpml.utils")

    --local library=library
    local core, system, manager = core, system, getManager()

    -- Localize frequently accessed functions
    --- System-based function calls
    local getWidth, getHeight, getFov, getMouseDeltaX, getMouseDeltaY, print =
        system.getScreenWidth,
        system.getScreenHeight,
        system.getFov,
        system.getMouseDeltaX,
        system.getMouseDeltaY,
        system.print

    --- Core-based function calls
    local getCWorldR, getCWorldF, getCWorldU, getCWorldPos =
        core.getConstructWorldRight,
        core.getConstructWorldForward,
        core.getConstructWorldUp,
        core.getConstructWorldPos

    --- Camera-based function calls
    local getCameraLocalPos = system.getCameraPos
    local getCamLocalFwd, getCamLocalRight, getCamLocalUp =
        system.getCameraForward,
        system.getCameraRight,
        system.getCameraUp

    --- Manager-based function calls
    ---- Quaternion operations
    local matrixToQuat = manager.matrixToQuat

    -- Localize Math functions
    local maths = math
    local sin, cos, tan, rad ,atan =
        maths.sin,
        maths.cos,
        maths.tan,
        maths.rad,
        maths.atan
    --local rnd = utils.round
    -- Projection infomation

    --- FOV Paramters
    local vertFov = system.getCameraVerticalFov
    local horizontalFov = system.getCameraHorizontalFov

    local fnearDivAspect = 0

    local objectGroups = {}

    local self = {objectGroups = objectGroups}
    local oldSelected = false
    function self.getSize(size, zDepth, max, min)
        local pSize = atan(size, zDepth) * (fnearDivAspect)
        local max = max or pSize
        local min = min or pSize
        if pSize >= max then
            return max
        elseif pSize <= min then
            return min
        else
            return pSize
        end
    end

    function self.addObjectGroup(objectGroup, id)
        local index = id or #objectGroups + 1
        objectGroups[index] = objectGroup
        return index
    end

    function self.removeObjectGroup(id)
        objectGroups[id] = {}
    end
    local ax,ay,az,aw,cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ
    function self.getModelMatrix(mObject)
        local s, c = sin, cos
        local modelMatrices = {}

        -- Localize Object values.
        local objOri, objPos = mObject[6], mObject[7]
        local objPosX, objPosY, objPosZ = objPos[1], objPos[2], objPos[3]
        local wx, wy, wz, ww = objOri[1], objOri[2], objOri[3], objOri[4]
        if mObject[5] == 1 then
            wx, wy, wz, ww =
                wx*aw + ww*ax + wy*az - wz*ay,
                wy*aw + ww*ay + wz*ax - wx*az,
                wz*aw + ww*az + wx*ay - wy*ax,
                ww*aw - wx*ax - wy*ay - wz*az
        end
        if mObject[4] == 2 then -- If Local
            return wx, wy, wz, ww, 
            objPosX, -- Convert this to 
            objPosY, 
            objPosZ
        else
            local cWorldPos = getCWorldPos()
            local oPX, oPY, oPZ = objPosX-cWorldPos[1], objPosY-cWorldPos[2], objPosZ-cWorldPos[3]
            return wx, wy, wz, ww,
                cRX * oPX + cRY * oPY + cRZ * oPZ, 
                cFX * oPX + cFY * oPY + cFZ * oPZ, 
                cUX * oPX + cUY * oPY + cUZ * oPZ
        end
    end
    function self.getViewMatrix()
        local cU, cF, cR = getCWorldU(), getCWorldF(), getCWorldR()
        cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ = cR[1], cR[2], cR[3], cF[1], cF[2], cF[3], cU[1], cU[2], cU[3]
        ax,ay,az,aw = matrixToQuat(cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ)
        
        local id = camera.cType.id
        local fG, fL = id == 0, id == 1

        if fG or fL then -- To do and fix (VERY broken now)
            local s, c = sin, cos
            local cOrientation = camera.orientation
            local pitch, heading, roll = cOrientation[1] * 0.5, -cOrientation[2] * 0.5, cOrientation[3] * 0.5
            local sP, sR, sH = s(pitch), s(heading), s(roll)
            local cP, cR, cH = c(pitch), c(heading), c(roll)

            local cx, cy, cz, cw = sP * cR, sP * sR, cP * sR, cP * cR
            if fL then
                wx, wy, wz, ww = cx, cy, cz, cw
            else
                local mx, my, mz, mw =
                    sx * cw + sw * cx + sy * cz - sz * cy,
                    sy * cw + sw * cy + sz * cx - sx * cz,
                    sz * cw + sw * cz + sx * cy - sy * cx,
                    sw * cw - sx * cx - sy * cy - sz * cz
                wx, wy, wz, ww = mx, my, mz, mw
            end
        else
            local lEye = getCameraLocalPos()
            local lEyeX, lEyeY, lEyeZ = lEye[1], lEye[2], lEye[3]
            local lf, lr, lu =
                getCamLocalFwd(),
                getCamLocalRight(),
                getCamLocalUp()
            
            local lrx, lry, lrz = lr[1], lr[2], lr[3]
            local lfx, lfy, lfz = lf[1], lf[2], lf[3]
            local lux, luy, luz = lu[1], lu[2], lu[3]
            
            return lrx, lry, lrz, 
                   lfx, lfy, lfz, 
                   lux, luy, luz, 
                   -(lrx * lEyeX + lry * lEyeY + lrz * lEyeZ), 
                   -(lfx * lEyeX + lfy * lEyeY + lfz * lEyeZ), 
                   -(lux * lEyeX + luy * lEyeY + luz * lEyeZ), 
                   lEyeX, lEyeY, lEyeZ
        end
    end
    
    function self.getSVG(isvg, fc)
        local getT = system.getTime
        local isClicked = false
        if clicked then
            clicked = false
            isClicked = true
        end
        local isHolding = isHolding
        
        local fullSVG = isvg or {}
        local fc = fc or 1

        local vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3, vw1, vw2, vw3, lCX, lCY, lCZ =
            self.getViewMatrix()
        local vx, vy, vz, vw = matrixToQuat(vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3)
        
        local atan, sort, format, unpack, concat, getModelMatrix =
            atan,
            table.sort,
            string.format,
            table.unpack,
            table.concat,
            self.getModelMatrix
        local nFactor = 2
        local width,height = getWidth()/nFactor, getHeight()/nFactor
        local aspect = width/height
        local tanFov = tan(rad(horizontalFov() * 0.5))
        local function zSort(t1, t2)
            return t1[1] > t2[1]
        end
        --- Matrix Subprocessing
        local nearDivAspect = width / tanFov
        fnearDivAspect = nearDivAspect
        
        -- Localize projection matrix values
        local px1 = 1 / tanFov
        local pz3 = px1 * aspect

        local pxw = px1 * width
        local pzw = -pz3 * height
        -- Localize screen info
        local objectGroups = objectGroups
        local svgBuffer = {}
        local alpha = 1
        for i = 1, #objectGroups do
            local objectGroup = objectGroups[i]
            if objectGroup.enabled == false then
                goto not_enabled
            end

            local objGTransX = objectGroup.transX or width
            local objGTransY = objectGroup.transY or height
            local objects = objectGroup.objects

            local avgZ, avgZC = 0, 0
            local zBuffer,zSorter, aBuffer,aSorter, aBC, zBC = {},{},{},{}, 0, 0
            local unpackData, drawStringData, uC, dU = {},{}, 1, 1
            local isZSorting = objectGroup.isZSorting
            
            local notIntersected = true
            for m = 1, #objects do
                local obj = objects[m]
                if not obj[1] then
                    goto is_nil
                end

                local mx, my, mz, mw, mw1, mw2, mw3 = getModelMatrix(obj)

                local vMX, vMY, vMZ, vMW =
                    mx * vw + mw * vx + my * vz - mz * vy,
                    my * vw + mw * vy + mz * vx - mx * vz,
                    mz * vw + mw * vz + mx * vy - my * vx,
                    mw * vw - mx * vx - my * vy - mz * vz

                local vMXvMX, vMYvMY, vMZvMZ = vMX * vMX, vMY * vMY, vMZ * vMZ

                local mXX, mXY, mXZ, mXW =
                    (1 - 2 * (vMYvMY + vMZvMZ)) * pxw,
                    2 * (vMX * vMY + vMZ * vMW) * pxw,
                    2 * (vMX * vMZ - vMY * vMW) * pxw,
                    (vw1 + vx1 * mw1 + vy1 * mw2 + vz1 * mw3) * pxw

                local mYX, mYY, mYZ, mYW =
                    2 * (vMX * vMY - vMZ * vMW),
                    1 - 2 * (vMXvMX + vMZvMZ),
                    2 * (vMY * vMZ + vMX * vMW),
                    (vw2 + vx2 * mw1 + vy2 * mw2 + vz2 * mw3)

                local mZX, mZY, mZZ, mZW =
                    2 * (vMX * vMZ + vMY * vMW) * pzw,
                    2 * (vMY * vMZ - vMX * vMW) * pzw,
                    (1 - 2 * (vMXvMX + vMYvMY)) * pzw,
                    (vw3 + vx3 * mw1 + vy3 * mw2 + vz3 * mw3) * pzw

                avgZ = avgZ + mYW
                avgZC = avgZC + 1
                local P0XD, P0YD, P0ZD = lCX - mw1, lCY - mw2, lCZ - mw3

                local customGroups, uiGroups = obj[2], obj[3]
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
                local predefinedRotation = {}
                for uiC = 1, #uiGroups do
                    local uiGroup = uiGroups[uiC]

                    local elements = uiGroup[1]
                    local modelElements = uiGroup[2]

                    for eC = 1, #modelElements do
                        local mod = modelElements[eC]
                        local mXO, mYO, mZO = mod[10], mod[11], mod[12]
                        local scale = mod[5]
                        local pointsInfo = mod[9]
                        local pointsX, pointsY, pointsZ = pointsInfo[1], pointsInfo[2], pointsInfo[3]
                        local tPointsX, tPointsY = {}, {}
                        local size = #pointsX
                        tPointsX[size] = false
                        tPointsY[size] = false

                        local xwAdd = mXX * mXO + mXY * mYO + mXZ * mZO + mXW
                        local ywAdd = mYX * mXO + mYY * mYO + mYZ * mZO + mYW
                        local zwAdd = mZX * mXO + mZY * mYO + mZZ * mZO + mZW

                        for index = 1, size do
                            local x, y, z = pointsX[index]*scale, pointsY[index]*scale, pointsZ[index]*scale
                            local pz = mYX * x + mYY * y + mYZ * z + ywAdd
                            if pz > 0 then
                                tPointsX[index] = (mXX * x + mXY * y + mXZ * z + xwAdd) / pz
                                tPointsY[index] = (mZX * x + mZY * y + mZZ * z + zwAdd) / pz
                            end
                        end

                        local lX, lY, lZ = 0.26726, 0.80178, 0.53452
                        local ambience = 0.3
                        local planes = mod[13]
                        local planeNumber = #planes
                        zSorter[zBC + planeNumber] = false
                        for p = 1, planeNumber do
                            local plane = planes[p]
                            local eXO, eYO, eZO = plane[1] + mXO, plane[2] + mYO, plane[3] + mZO
                            local eCZ = mYX * eXO + mYY * eYO + mYZ * eZO + mYW
                            if eCZ < 0 then
                                goto behindElement
                            end
                            local p0X, p0Y, p0Z = P0XD - eXO, P0YD - eYO, P0ZD - eZO

                            local NX, NY, NZ = plane[4], plane[5], plane[6]
                            local dotValue = p0X * NX + p0Y * NY + p0Z * NZ

                            if dotValue < 0 then
                                goto behindElement
                            end

                            local brightness = (lX * NX + lY * NY + lZ * NZ)
                            if brightness < 0 then
                                brightness = (brightness * 0.1) * (1 - ambience) + ambience
                            else
                                brightness = (brightness) * (1 - ambience) + ambience
                            end
                            
                            zBC = zBC + 1
                            zSorter[zBC] = eCZ
                            zBuffer[eCZ] = {
                                function (uD,c)
                                    local plane = plane
                                    local m = 3 + c
                                    local indices = plane[7]
                                    local indexSize = #indices
                                    uD[m + indexSize * 2 - 1] = false
                                
                                    for i = 1, indexSize do
                                        local index = indices[i]
                                        local pntX = tPointsX[index]
                                        if not pntX then
                                            return '',c
                                        end

                                        uD[m] = pntX
                                        uD[m + 1] = tPointsY[index]
                                        m = m + 2
                                    end
                                    uD[c] = plane[8] * brightness
                                    uD[c+1] = plane[9] * brightness
                                    uD[c+2] = plane[10] * brightness
                                    return plane[11], m
                                end,
                                is3D = true
                            }

                            ::behindElement::
                        end
                    end
                    for eC = 1, #elements do
                        local el = elements[eC]
                        if not el[6] then
                            goto behindElement
                        end
                        el[17].checkUpdate()
                        local eO = el[11]
                        local eXO, eYO, eZO = eO[1], eO[2], eO[3]
                        
                        local eCZ = mYX*eXO + mYY*eYO + mYZ*eZO + mYW
                        if eCZ < 0 then
                            goto behindElement
                        end
                        
                        local eCX = mXX*eXO + mXY*eYO + mXZ*eZO + mXW
                        local eCY = mZX*eXO + mZY*eYO + mZZ*eZO + mZW

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
                        zBC = zBC + 1
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
                            zSorter[zBC] = eCZ
                            zBuffer[eCZ] = {
                                el,
                                false,
                                eCX,
                                eCY,
                                pMR,
                                isUI = true
                            }
                            aSorter[aBC] = eCZ
                            aBuffer[eCZ] = {
                                el,
                                pMR[7]*px + pMR[8]*py + pMR[9]*pz,
                                pMR[10]*px + pMR[11]*py + pMR[12]*pz,
                                actions
                            }
                        else
                            zSorter[zBC] = eCZ
                            zBuffer[eCZ] = {
                                el,
                                false,
                                eCX,
                                eCY,
                                pMR,
                                isUI = true
                            }
                        end

                        ::behindElement::
                    end
                end
                ::is_nil::
            end
            if aBC > 0 then
                if hoveringOverUIElement then
                    hoveringOverUIElement = false
                end
                local newSelected = false
                sort(aSorter)
                for aC = 1, aBC do
                    local zDepth = aSorter[aC]
                    local uiElmt = aBuffer[zDepth]

                    local el = uiElmt[1]
                    local drawForm = el[2]
                    local actions = el[4]
                    if notIntersected then
                        local eBounds = el[15]
                        if eBounds and actions[7] then
                            local inside = false
                            local pX, pZ = uiElmt[2], uiElmt[3]
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
                            notIntersected = false
                            newSelected = uiElmt
                            local eO = el[11]
                            local identifier = actions[6]
                            newSelected[8],newSelected[9],newSelected[10] = pX,pZ,identifier
                            if not oldSelected then
                                --system.print('Enter a new')
                                local enter = actions[3]
                                if enter then
                                    enter(identifier, pX, pZ)
                                end
                            elseif newSelected[10] == oldSelected[10] then
                                --system.print('New == Old')
                                if isClicked then
                                    local clickAction = actions[1]
                                    if clickAction then
                                        clickAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                        isClicked = false
                                    end
                                    drawForm = el[3]
                                elseif isHolding then
                                    local holdAction = actions[2]
                                    if holdAction then
                                        hovered = true
                                        holdAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                    end
                                    drawForm = el[3]
                                else
                                    local hoverAction = actions[5]
                                    
                                    if hoverAction then
                                        hoveringOverUIElement = true
                                        hovered = true
                                        hoverAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                    end
                                    drawForm = el[1]
                                end
                            else
                                --system.print('Else')
                                local enter = actions[3]
                                if enter then
                                    enter(identifier, pX, pZ)
                                end
                                local leave = oldSelected[4][4]
                                if leave then
                                    --system.print('Else')
                                    leave(oldSelected[10], pX, pZ)
                                end
                                
                            end
                            ::broke::
                        end
                    end
                    zBuffer[zDepth][2] = drawForm
                end
                if not newSelected and oldSelected then
                    --system.print('Fall Back')
                    local leave = oldSelected[4][4]
                    if leave then
                        leave(oldSelected[10], oldSelected[8], oldSelected[9])
                    end
                end
                oldSelected = newSelected
            end
            sort(zSorter)
            for zC = zBC, 1,-1 do
                local distance = zSorter[zC]
                local uiElmt = zBuffer[distance]
                if uiElmt.isUI then
                    local el = uiElmt[2]
                    local el,drawForm,xwAdd,zwAdd,pMR=unpack(uiElmt)
                    local xxMult,xzMult,yxMult,yzMult,zxMult,zzMult=unpack(pMR)
                    if not drawForm then
                        drawForm = el[2]
                        if not drawForm then
                            goto broken
                        end
                    end
                    local ywAdd = distance
                    local count = 1
                     
                    local scale = el[5]
                    local drawOrder = el[7]
                    local drawData = el[8]
                    local pointsX,pointsY = el[9],el[10]

                    local oUC = uC
                    if drawData then
                        local sizes = drawData["sizes"]
                        if sizes then
                            uC = uC + #sizes
                        end
                        uC = uC + #drawData
                    end

                    local broken = false
                    if not drawOrder then
                        for ePC = 1, #pointsX do
                            local ex, ez = pointsX[ePC]*scale, pointsY[ePC]*scale

                            local pz = yxMult*ex + yzMult*ez + ywAdd
                            if pz < 0 then
                                uC = oUC
                                goto broken
                            end

                            distance = distance + pz
                            count = count + 1

                            unpackData[uC] = (xxMult*ex + xzMult*ez + xwAdd) / pz
                            unpackData[uC + 1] = (zxMult*ex + zzMult*ez + zwAdd) / pz
                            uC = uC + 2
                        end
                    else
                        for ePC = 1, #pointsX do
                            local ex, ez = pointsX[ePC]*scale, pointsY[ePC]*scale

                            local pz = yxMult*ex + yzMult*ez + ywAdd
                            if pz < 0 then
                                uC = oUC
                                goto broken
                            end

                            distance = distance + pz
                            count = count + 1

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
                    local depthFactor = distance / count
                    if drawData then
                        local sizes = drawData["sizes"]
                        if sizes then
                            for i = 1, #sizes do
                                local size = sizes[i]
                                local tSW = type(size)
                                if tSW == "number" then
                                    unpackData[uC] = atan(size, depthFactor) * nearDivAspect
                                elseif tSW == "function" then
                                    unpackData[uC] = size(depthFactor, nearDivAspect)
                                end
                                uC = uC + 1
                            end
                        end
                        for dDC = 1, #drawData do
                            unpackData[uC] = drawData[dDC]
                            uC = uC + 1
                        end
                    end
                    drawStringData[dU] = drawForm
                    dU = dU + 1
                    uC = mUC
                    ::broken::
                elseif uiElmt.is3D then
                    drawStringData[dU],uC = uiElmt[1](unpackData,uC)
                    dU = dU + 1
                elseif uiElmt.isCustomSingle then
                    drawStringData[dU],uC = uiElmt[3](uiElmt[1],uiElmt[2],distance,uiElmt[4],unpackData,uC)
                    dU = dU + 1
                else
                    drawStringData[dU],uC = uiElmt[4](uiElmt[1],uiElmt[2],uiElmt[3],uiElmt[5],unpackData,uC)
                    dU = dU + 1
                end
            end
            local svg = {
                format(
                    '<svg viewbox="-%g -%g %g %g">',
                    objGTransX,
                    objGTransY,
                    width * 2,
                    height * 2
                ),
                format(
                    '<style>svg{background:none;width:%gpx;height:%gpx;position:absolute;top:0px;left:0px;}%s</style>',
                    width * nFactor,
                    height * nFactor,
                    objectGroup.style
                ),
                concat(drawStringData):format(unpack(unpackData)),
                '</svg>'
            }
            if avgZC > 0 then
                local dpth = avgZ / avgZC
                svgBuffer[alpha] = {dpth, concat(svg)}
                alpha = alpha + 1
                if objectGroup.glow then
                    local size
                    if objectGroup.scale then
                        size = atan(objectGroup.gRad, dpth) * nearDivAspect
                    else
                        size = objectGroup.gRad
                    end
                    svg[1] =
                        format(
                        '<svg viewbox="-%g -%g %g %g" class="blur">',
                        objGTransX,
                        objGTransY,
                        width * 2,
                        height * 2
                    )
                    svg[2] =
                        [[
                        <style> 
                            .blur {
                                filter: blur(]] .. size .. [[px) 
                                        brightness(60%)
                                        saturate(3);
                                ]] .. objectGroup.gStyle .. [[
                            }
                        </style>]]
                    svgBuffer[alpha] = {dpth + 0.1, concat(svg)}
                    alpha = alpha + 1
                end
            end
            ::not_enabled::
        end
        sort(svgBuffer, zSort)
        local svgBufferSize = #svgBuffer
        if svgBufferSize > 0 then
            fc = fc - 1
            for dm = 1, svgBufferSize do
                fullSVG[fc + dm] = svgBuffer[dm][2]
            end
        end
        return fullSVG, fc + svgBufferSize + 1
    end
    return self
end