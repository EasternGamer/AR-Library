function Projector(camera)
    -- Localize frequently accessed data
    local construct, player, system, math = construct, player, system, math
    
    -- Internal Parameters
    local frameBuffer,frameRender,isSmooth = {''},true,true

    -- Localize frequently accessed functions
    --- System-based function calls
    local getWidth, getHeight, getFov, print, getTime =
    system.getScreenWidth,
    system.getScreenHeight,
    system.getFov,
    system.print,
    system.getArkTime

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
    local rotMatrixToQuat,solveMat,quatMulti = rotMatrixToQuat,library.systemResolution3,quaternionMultiply
    local function solve(mx,my,mz,mw,ix,iy,iz,iw)
        if ix then return quatMulti(mx,my,mz,mw,ix,iy,iz,iw) else return solveMat(mx,my,mz,mw) end
    end
    
    -- Localize Math functions
    local tan, atan, rad = math.tan, math.atan, math.rad

    --- FOV Paramters
    local vertFov = system.getCameraVerticalFov
    local horizontalFov = system.getCameraHorizontalFov
    local fnearDivAspect = 0

    local objectGroups = LinkedList('Group', '')

    local self = {}
  
    function self.getSize(size, zDepth, max, min)
        local pSize = atan(size, zDepth) * fnearDivAspect
        if max then
            if pSize >= max then
                return max
            else
                if min then
                    if pSize < min then
                        return min
                    end
                end
                return pSize
            end
        end
        return pSize
    end

    function self.setSmooth(iss) isSmooth = iss end

    function self.addObjectGroup(objectGroup) objectGroups.Add(objectGroup) end

    function self.removeObjectGroup(objectGroup) objectGroups.Remove(objectGroup) end
    
    local previousUI = nil
    
    function self.getSVG()
        local getTime, atan, sort, format, concat = getTime, atan, table.sort, string.format, table.concat
        local startTime = getTime()
        frameCounter = not frameCounter
        local isClicked = false
        if clicked then
            clicked = false
            isClicked = true
        end
        local isHolding = holding

        local buffer,bufferCounter = {},0

        local width,height = getWidth(), getHeight()
        local aspect = width/height
        local tanFov = tan(rad(horizontalFov() * 0.5))
        
        --- Matrix Subprocessing
        local nearDivAspect = (width*0.5) / tanFov
        fnearDivAspect = nearDivAspect

        -- Localize projection matrix values
        local px1 = 1 / tanFov
        local pz3 = px1 * aspect

        local pxw,pzw = px1 * width * 0.5, -pz3 * height * 0.5
        
        --- View Matrix Processing
        local vCX, vCY, vCZ, lEye =
        getCamLocalRight(),
        getCamLocalFwd(),
        getCamLocalUp(),
        getCameraLocalPos()
        local lx,ly,lz = lEye[1],lEye[2],lEye[3]
        local vx, vy, vz, vw = rotMatrixToQuat(vCX,vCY,vCZ)
        local vW = solve(vCX,vCY,vCZ,lEye)
        
        -- View Matrix
        local vXX,vXY,vXZ = vCX[1]*pxw,vCX[2]*pxw,vCX[3]*pxw
        local vYX,vYY,vYZ = vCY[1], vCY[2], vCY[3]
        local vZX,vZY,vZZ = vCZ[1]*pzw, vCZ[2]*pzw, vCZ[3]*pzw
        local vXW,vYW,vZW = -vW[1]*pxw, -vW[2], -vW[3]*pzw

        
        -- Localize screen info
        local objectGroupsArray,objectGroupSize = objectGroups.GetData()
        local svgBuffer,svgZBuffer,svgBufferCounter = {},{},0


        local processedNumber = 0
        local processPure = ProcessPureModule
        local processUI = ProcessUIModule
        local processRots = ProcessOrientations
        local renderUI = RenderUIElement
        local processEvents = ProcessActionEvents
        if processPure == nil then
            processPure = function(zBC) return zBC end
        end
        if processUI == nil then
            processUI = function(zBC) return zBC end
            processRots = function() end
            processEvents = function() end
        end
        local predefinedRotations = {}
        local deltaPreProcessing = getTime() - startTime
        local deltaDrawProcessing, deltaEvent, deltaZSort, deltaZBufferCopy, deltaPostProcessing = 0,0,0,0,0
        for i = 1, objectGroupSize do
            local drawProcessingStartTime = getTime()
            local objectGroup = objectGroupsArray[i]
            if objectGroup.enabled == false then
                goto not_enabled
            end
            local objects = objectGroup.objects

            local avgZ, avgZC = 0, 0
            local zBuffer, zSorter, aBuffer, aSorter, aBC, zBC = {},{},{},{}, 0, 0

            local notIntersected = true
            for m = 1, #objects do
                local obj = objects[m]
                if not obj[1] then
                    goto is_nil
                end

                obj.checkUpdate()
                local objOri,objPos = obj[7],obj[8]
                local mx, my, mz, mw = objOri[1], objOri[2], objOri[3], objOri[4]
                local mW = solve(vCX, vCY, vCZ, objPos)
                local vMX, vMY, vMZ, vMW = solve(mx,my,mz,mw, vx,vy,vz,vw)

                local processRotations = processRots(predefinedRotations,vx,vy,vz,vw,pxw,pzw)
                local vMXvMX, vMXvMY, vMXvMZ, vMXvMW, vMYvMY, vMYvMZ, vMYvMW, vMZvMZ, vMZvMW = 2*vMX*vMX, 2*vMX*vMY, 2*vMX*vMZ, 2*vMX*vMW, 2*vMY*vMY, 2*vMY*vMZ, 2*vMY*vMW, 2*vMZ*vMZ, 2*vMZ*vMW

                local mXX, mXY, mXZ, mXW =
                (1 - vMYvMY - vMZvMZ)*pxw,
                (vMXvMY + vMZvMW)*pxw,
                (vMXvMZ - vMYvMW)*pxw,
                mW[1]*pxw + vXW

                local mYX, mYY, mYZ, mYW =
                (vMXvMY - vMZvMW),
                (1 - vMXvMX - vMZvMZ),
                (vMYvMZ + vMXvMW),
                mW[2] + vYW

                local mZX, mZY, mZZ, mZW =
                (vMXvMZ + vMYvMW)*pzw,
                (vMYvMZ - vMXvMW)*pzw,
                (1 - vMXvMX - vMYvMY)*pzw,
                mW[3]*pzw + vZW


                predefinedRotations[mx .. ',' .. my .. ',' .. mz .. ',' .. mw] = {mXX,mXZ,mYX,mYZ,mZX,mZZ}

                avgZ = avgZ + mYW
                local uiGroups = obj[4]
                
                -- Process Actionables
                obj.previousUI = processEvents(uiGroups, obj.previousUI, isClicked, isHolding, mYX, mYY, mYZ, mYW, vYX,vYY,vYZ, processRotations, lx,ly,lz, sort)
                -- Progress Pure
                zBC = processPure(zBC, obj[2], obj[3], zBuffer, zSorter,
                    mXX, mXY, mXZ, mXW,
                    mYX, mYY, mYZ, mYW,
                    mZX, mZY, mZZ, mZW)
                -- Process UI
                zBC = processUI(zBC, uiGroups, zBuffer, zSorter,
                    vXX,vXY,vXZ,
                    vYX,vYY,vYZ,
                    vZX,vZY,vZZ,
                    vXW,vYW,vZW,
                    processRotations,nearDivAspect)

                ::is_nil::
            end
            local eventStartTime = getTime()
            deltaDrawProcessing = deltaDrawProcessing + eventStartTime - drawProcessingStartTime
            if aBC > 0 then
                sort(aSorter)
                oldSelected, hovered = ProcessUIEvents(aBuffer, zBuffer, aBC, oldSelected, isClicked, isHolding)
            end
            local zSortingStartTime = getTime()
            deltaEvent = deltaEvent + zSortingStartTime - eventStartTime
            if objectGroup.isZSorting then
                sort(zSorter)
            end
            
            local zBufferCopyStartTime = getTime()
            deltaZSort = deltaZSort + zBufferCopyStartTime - zSortingStartTime
            local drawStringData = {}
            for zC = 1, zBC do
                drawStringData[zC] = zBuffer[zSorter[zC]]
            end
            local postProcessingStartTime = getTime()
            deltaZBufferCopy = deltaZBufferCopy + postProcessingStartTime - zBufferCopyStartTime
            if zBC > 0 then
                local dpth = avgZ / avgZC
                local actualSVGCode = concat(drawStringData)
                local beginning, ending = '', ''
                if isSmooth then
                    ending = '</div>'
                    if frameCounter then
                        beginning = '<div class="second" style="visibility: hidden">'
                    else
                        beginning = '<style>.first{animation: f1 0.008s infinite linear;} .second{animation: f2 0.008s infinite linear;} @keyframes f1 {from {visibility: hidden;} to {visibility: hidden;}} @keyframes f2 {from {visibility: visible;} to { visibility: visible;}}</style><div class="first">'
                    end
                end
                local styleHeader = ('<style>svg{background:none;width:%gpx;height:%gpx;position:absolute;top:0px;left:0px;}'):format(width,height)
                local svgHeader = ('<svg viewbox="-%g -%g %g %g"'):format(width*0.5,height*0.5,width,height)
                
                svgBufferCounter = svgBufferCounter + 1
                svgZBuffer[svgBufferCounter] = dpth
                
                if objectGroup.glow then
                    local size
                    if objectGroup.scale then
                        size = atan(objectGroup.gRad, dpth) * nearDivAspect
                    else
                        size = objectGroup.gRad
                    end
                    svgBuffer[dpth] = concat({
                                beginning,
                                '<div class="', objectGroup.class ,'">',
                                styleHeader,
                                objectGroup.style,
                                '.blur { filter: blur(',size,'px) brightness(60%) saturate(3);',
                                objectGroup.gStyle, '}</style>',
                                svgHeader,
                                ' class="blur">',
                                actualSVGCode,'</svg>',
                                svgHeader, '>',
                                actualSVGCode,
                                '</svg></div>',
                                ending
                            })
                    
                else
                    svgBuffer[dpth] = concat({
                                beginning,
                                '<div class="', objectGroup.class ,'">',
                                styleHeader,
                                objectGroup.style, '}</style>',
                                svgHeader, '>',
                                actualSVGCode,
                                '</svg></div>',
                                ending
                            })
                end
            end
            deltaPostProcessing = deltaPostProcessing + getTime() - postProcessingStartTime
            ::not_enabled::
        end
        
        sort(svgZBuffer)
        
        for i = 1, svgBufferCounter do
            buffer[i] = svgBuffer[svgZBuffer[i]]
        end
        if frameCounter then
            frameBuffer[2] = concat(buffer)
            return concat(frameBuffer), deltaPreProcessing, deltaDrawProcessing, deltaEvent, deltaZSort, deltaZBufferCopy, deltaPostProcessing
        else
            if isSmooth then
                frameBuffer[1] = concat(buffer)
            else
                frameBuffer[1] = ''
            end
            return nil
        end
    end
    return self
end