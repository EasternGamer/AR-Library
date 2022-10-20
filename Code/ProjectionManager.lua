function Projector(camera)
    -- Localize frequently accessed data
    --local utils = require("cpml.utils")

    --local library=library
    local construct, player, system, manager = construct, player, system, getManager()
    local frameCounter = 0
    local frameBuffer = {''}
    local isSmooth = true

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
        construct.getWorldRight,
        construct.getWorldForward,
        construct.getWorldUp,
        construct.getWorldPosition

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
    
    function self.setSmooth(iss) isSmooth = iss end

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
                cRX*oPX + cRY*oPY + cRZ*oPZ, 
                cFX*oPX + cFY*oPY + cFZ*oPZ, 
                cUX*oPX + cUY*oPY + cUZ*oPZ
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
    
    function self.getSVG()
        frameCounter = frameCounter + 1
        local isClicked = false
        if clicked then
            clicked = false
            isClicked = true
        end
        local isHolding = isHolding
        
        local fullSVG = {}
        local fc = 1

        local vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3, vw1, vw2, vw3, lCX, lCY, lCZ =
            self.getViewMatrix()
        local vx, vy, vz, vw = matrixToQuat(vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3)
        
        local atan, sort, format, unpack, concat, getModelMatrix, select =
            atan,
            table.sort,
            string.format,
            table.unpack,
            table.concat,
            self.getModelMatrix, select
        
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
        
        
        local processedNumber = 0
        local processPure = ProcessPureModule
        local processUI = ProcessUIModule
        local renderUI = RenderUIElement
        if processPure == nil then
            processPure = function(zBC, dU, uC) return zBC, dU, uC end
        end
        if processUI == nil then
            processUI = function(zBC, dU, uC) return zBC, dU, uC end
        end
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
                
                obj.checkUpdate()
                
                local mx, my, mz, mw, mw1, mw2, mw3 = getModelMatrix(obj)

                local vMX, vMY, vMZ, vMW =
                    mx*vw + mw*vx + my*vz - mz*vy,
                    my*vw + mw*vy + mz*vx - mx*vz,
                    mz*vw + mw*vz + mx*vy - my*vx,
                    mw*vw - mx*vx - my*vy - mz*vz

                local vMXvMX, vMYvMY, vMZvMZ = vMX*vMX, vMY*vMY, vMZ*vMZ

                local mXX, mXY, mXZ, mXW =
                    2*(0.5 - vMYvMY - vMZvMZ)*pxw,
                    2*(vMX*vMY + vMZ*vMW)*pxw,
                    2*(vMX*vMZ - vMY*vMW)*pxw,
                    (vw1 + vx1*mw1 + vy1*mw2 + vz1*mw3)*pxw
                local mYX, mYY, mYZ, mYW =
                    2*(vMX*vMY - vMZ*vMW),
                    2*(0.5 - vMXvMX - vMZvMZ),
                    2*(vMY*vMZ + vMX*vMW),
                    (vw2 + vx2*mw1 + vy2*mw2 + vz2*mw3)

                local mZX, mZY, mZZ, mZW =
                    2*(vMX*vMZ + vMY*vMW)*pzw,
                    2*(vMY*vMZ - vMX*vMW)*pzw,
                    2*(0.5 - vMXvMX - vMYvMY)*pzw,
                    (vw3 + vx3*mw1 + vy3*mw2 + vz3*mw3)*pzw
                
                avgZ = avgZ + mYW
                avgZC = avgZC + 1
                local P0XD, P0YD, P0ZD = lCX - mw1, lCY - mw2, lCZ - mw3

                zBC, dU, uC = processPure(zBC, dU, uC, obj[2], zBuffer, zSorter, isZSorting, drawStringData,
                mXX, mXY, mXZ, mXW,
                mYX, mYY, mYZ, mYW,
                mZX, mZY, mZZ, mZW)
                
                zBC, aBC = processUI(zBC, aBC, obj[3], zBuffer, zSorter, aBuffer, aSorter,
                mXX, mXY, mXZ, mXW,
                mYX, mYY, mYZ, mYW,
                mZX, mZY, mZZ, mZW,
                P0XD, P0YD, P0YZ,
                vMX, vMY, vMZ, vMW,
                pxw, pzw)
                
                ::is_nil::
            end
            if aBC > 0 then
                sort(aSorter)
                oldSelected, hovered = ProcessUIEvents(aBuffer, zBuffer, aBC, oldSelected, isClicked, isHolding)
            end
            sort(zSorter)
            for zC = zBC, 1,-1 do
                local distance = zSorter[zC]
                local uiElmt = zBuffer[distance]
                if uiElmt.isUI then
                    drawStringData[dU],uC = renderUI(uiElmt, distance, unpackData, uC, nearDivAspect)
                    dU = dU + 1
                elseif uiElmt.isCustomSingle then
                    drawStringData[dU],uC = uiElmt[3](uiElmt[1],uiElmt[2],distance,uiElmt[4],unpackData,uC)
                    dU = dU + 1
                else
                    drawStringData[dU],uC = uiElmt[4](uiElmt[1],uiElmt[2],uiElmt[3],uiElmt[5],unpackData,uC)
                    dU = dU + 1
                end
            end
            if avgZC > 0 then
                local dpth = avgZ / avgZC
                local actualSVGCode = concat(drawStringData):format(unpack(unpackData))
                local beginning, ending = '', ''
                if isSmooth then
                    if frameCounter % 2 == 1 then
                        beginning = '<style>.first{animation: f1 0.008s infinite linear;} .second{animation: f2 0.008s infinite linear;} @keyframes f1 {from {visibility: hidden;} to {visibility: hidden;}} @keyframes f2 {from {visibility: visible;} to { visibility: visible;}}</style><div class="first">'
                        ending = '</div>'
                    else
                        beginning = '<div class="second" style="visibility: hidden">'
                        ending = '</div>'
                    end
                end
                if objectGroup.glow then
                    local size
                    if objectGroup.scale then
                        size = atan(objectGroup.gRad, dpth) * nearDivAspect
                    else
                        size = objectGroup.gRad
                    end
                    svgBuffer[alpha] = {
                        dpth,
                        concat(
                            {
                                beginning,
                                '<div class="', 
                                objectGroup.class, 
                                '"><style>svg{background:none;width:',
                                width * nFactor,
                                'px;height:',
                                height * nFactor,
                                'px;position:absolute;top:0px;left:0px;}',
                                objectGroup.style,
                                '.blur { filter: blur(',
                                size,
                                'px) brightness(60%) saturate(3);',
                                objectGroup.gStyle,
                                '}</style><svg viewbox="-',
                                objGTransX,
                                ' -',
                                objGTransY,
                                ' ',
                                width * 2,
                                ' ',
                                height * 2,
                                '" class="blur">',
                                actualSVGCode,
                                '</svg><svg viewbox="-',
                                objGTransX,
                                ' -',
                                objGTransY,
                                ' ',
                                width * 2,
                                ' ',
                                height * 2,
                                '">',
                                actualSVGCode,
                                '</svg></div>',
                                ending
                            }
                        )}
                    alpha = alpha + 1
                else
                    svgBuffer[alpha] = {
                        dpth, 
                        concat(
                            {
                                beginning,
                                '<div class="', 
                                objectGroup.class, 
                                '"><style>svg{background:none;width:',
                                width * nFactor,
                                'px;height:',
                                height * nFactor,
                                'px;position:absolute;top:0px;left:0px;}',
                                objectGroup.style,
                                '}</style><svg viewbox="-',
                                objGTransX,
                                ' -',
                                objGTransY,
                                ' ',
                                width * 2,
                                ' ',
                                height * 2,
                                '">',
                                actualSVGCode,
                                '</svg></div>',
                                ending
                            }
                        )
                    }
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
        if frameCounter % 2 == 0 then
            frameBuffer[2] = concat(fullSVG)
            return concat(frameBuffer), processedNumber
        else
            if isSmooth then
                frameBuffer[1] = concat(fullSVG)
            else
                frameBuffer[1] = ''
            end
            return nil
        end
    end
    return self
end