function Projector()
    -- Localize frequently accessed data
    local construct, player, system, math = DUConstruct, DUPlayer, DUSystem, math
    
    -- Internal Parameters
    local frameBuffer,frameRender,isSmooth = {''},true,true

    -- Localize frequently accessed functions
    --- System-based function calls
    local getWidth, getHeight, getTime =
    system.getScreenWidth,
    system.getScreenHeight,
    system.getArkTime

    --- Camera-based function calls
    
    local getCamWorldRight, getCamWorldFwd, getCamWorldUp, getCamWorldPos =
    system.getCameraWorldRight,
    system.getCameraWorldForward,
    system.getCameraWorldUp,
    system.getCameraWorldPos
   
    local getConWorldRight, getConWorldFwd, getConWorldUp, getConWorldPos = 
    construct.getWorldRight,
    construct.getWorldForward,
    construct.getWorldUp,
    construct.getWorldPosition

    --- Manager-based function calls
    ---- Quaternion operations
    local rotMatrixToQuat,quatMulti = RotMatrixToQuat,QuaternionMultiply
    
    -- Localize Math functions
    local tan, atan, rad = math.tan, math.atan, math.rad

    --- FOV Paramters
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
    
    function self.getSVG()
        local getTime, atan, sort, unpack, format, concat, quatMulti = getTime, atan, table.sort, table.unpack, string.format, table.concat, quatMulti
        local startTime = getTime()
        frameRender = not frameRender
        local isClicked = false
        if clicked then
            clicked = false
            isClicked = true
        end
        local isHolding = holding

        local buffer = {}

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
         --- View Matrix Processing
        
        
        -- Localize screen info
        local objectGroupsArray,objectGroupSize = objectGroups.GetData()
        local svgBuffer,svgZBuffer,svgBufferCounter = {},{},0

        local processPure = ProcessPureModule
        local processUI = ProcessUIModule
        local processRots = ProcessOrientations
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
        local camR,camF,camU,camP = getCamWorldRight(),getCamWorldFwd(),getCamWorldUp(),getCamWorldPos()
        
        do
            local cwr,cwf,cwu = getConWorldRight(),getConWorldFwd(),getConWorldUp()
            ConstructReferential.rotateXYZ(cwr,cwf,cwu)
            ConstructOriReferential.rotateXYZ(cwr,cwf,cwu)
            ConstructReferential.setPosition(getConWorldPos())
            ConstructReferential.checkUpdate()
            ConstructOriReferential.checkUpdate()
        end
        local vx,vy,vz,vw = rotMatrixToQuat(camR,camF,camU)
        
        local vxx,vxy,vxz,vyx,vyy,vyz,vzx,vzy,vzz = camR[1]*pxw,camR[2]*pxw,camR[3]*pxw,camF[1],camF[2],camF[3],camU[1]*pzw,camU[2]*pzw,camU[3]*pzw
        local ex,ey,ez = camP[1],camP[2],camP[3]
        local deltaPreProcessing = getTime() - startTime
        local deltaDrawProcessing, deltaEvent, deltaZSort, deltaZBufferCopy, deltaPostProcessing = 0,0,0,0,0
        for i = 1, objectGroupSize do
            local objectGroup = objectGroupsArray[i]
            if objectGroup.enabled == false then
                goto not_enabled
            end
            local objects = objectGroup.objects

            local avgZ, avgZC = 0, 0
            local zBuffer, zSorter, zBC = {},{}, 0

            local notIntersected = true
            for m = 1, #objects do
                local obj = objects[m]
                if not obj[1] then
                    goto is_nil
                end

                obj.checkUpdate()
                local objOri, objPos, oriType, posType  = obj[5], obj[6], obj[7], obj[8]
                local objX,objY,objZ = objPos[1]-ex,objPos[2]-ey,objPos[3]-ez
                local mx,my,mz,mw = objOri[1], objOri[2], objOri[3], objOri[4]
                
                local a,b,c,d = quatMulti(mx,my,mz,mw,vx,vy,vz,vw)
                local aa, ab, ac, ad, bb, bc, bd, cc, cd = 2*a*a, 2*a*b, 2*a*c, 2*a*d, 2*b*b, 2*b*c, 2*b*d, 2*c*c, 2*c*d
                
                local mXX, mXY, mXZ,
                      mYX, mYY, mYZ,
                      mZX, mZY, mZZ = 
                (1 - bb - cc)*pxw,    (ab + cd)*pxw,    (ac - bd)*pxw,
                (ab - cd),           (1 - aa - cc),     (bc + ad),
                (ac + bd)*pzw,        (bc - ad)*pzw,    (1 - aa - bb)*pzw
                
                local mWX,mWY,mWZ = ((vxx*objX+vxy*objY+vxz*objZ)),(vyx*objX+vyy*objY+vyz*objZ),((vzx*objX+vzy*objY+vzz*objZ))

                local processRotations = processRots(predefinedRotations,vx,vy,vz,vw,pxw,pzw)
                predefinedRotations[mx .. ',' .. my .. ',' .. mz .. ',' .. mw] = {mXX,mXZ,mYX,mYZ,mZX,mZZ}
                
                avgZ = avgZ + mWY
                local uiGroups = obj[4]
                
                -- Process Actionables
                local eventStartTime = getTime()
                --obj.previousUI = processEvents(uiGroups, obj.previousUI, isClicked, isHolding, mYW, mYX, mYY, mYZ, vyx,vyy,vyz, processRotations, ex,ey,ez, sort)
                local drawProcessingStartTime = getTime()
                deltaEvent = deltaEvent + drawProcessingStartTime - eventStartTime
                -- Progress Pure
       
                zBC = processPure(zBC, obj[2], obj[3], zBuffer, zSorter,
                    mXX, mXY, mXZ,
                    mYX, mYY, mYZ,
                    mZX, mZY, mZZ,
                    mWX, mWY, mWZ
                )
                -- Process UI
                zBC = processUI(zBC, uiGroups, zBuffer, zSorter,
                            vxx, vxy, vxz,
                            vyx, vyy, vyz,
                            vzx, vzy, vzz,
                            ex,ey,ez,
                        processRotations,nearDivAspect)
                deltaDrawProcessing = deltaDrawProcessing + getTime() - drawProcessingStartTime
                ::is_nil::
            end
            local zSortingStartTime = getTime()
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
                    if frameRender then
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
        if frameRender then
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