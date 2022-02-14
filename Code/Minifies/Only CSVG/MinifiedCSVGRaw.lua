positionTypes = {
    globalP=1,
    localP=2
}
orientationTypes = {
    globalO=1,
    localO=2 
}
CameraTypes={
    fixed={
        fLocal={
            name="fLocal",
            id = 0
        },
        fGlobal={
            name="fGlobal",
            id = 1
        }
    },
    player={
        name="player",
        id = 2
    }
}

function getManager()
    local self = {}
    --- Core-based function calls

    local function matrixToQuat(m11,m21,m31,m12,m22,m32,m13,m23,m33)
        local t=m11+m22+m33
        if t>0 then
            local s=0.5/(t+1)^(0.5)
            return (m32-m23)*s,(m13-m31)*s,(m21-m12)*s,0.25/s
        elseif m11>m22 and m11>m33 then
            local s = 1/(2*(1+m11-m22-m33)^(0.5))
            return 0.25/s,(m12+m21)*s,(m13+m31)*s,(m32-m23)*s
        elseif m22>m33 then
            local s=1/(2*(1+m22-m11-m33)^(0.5))
            return (m12+m21)*s,0.25/s,(m23+m32)*s,(m13-m31)*s
        else
            local s=1/(2*(1+m33-m11- m22)^(0.5))
            return (m13+m31)*s,(m23+m32)*s,0.25/s,(m21-m12)*s
        end
    end
    
    local function rotMatrixToQuat(rM1,rM2,rM3)
        if rM2 and rM3 then
            return matrixToQuat(rM1[1],rM1[2],rM1[3],rM2[1],rM2[2],rM2[3],rM3[1],rM3[2],rM3[3])
        else
            return matrixToQuat(rM1[1],rM1[5],rM1[9],rM1[2],rM1[6],rM1[10],rM1[3],rM1[7],rM1[11])
        end
    end
    self.matrixToQuat = matrixToQuat
    self.rotMatrixToQuat = rotMatrixToQuat
    
    local function RotationHandler(rotArray,resultantPos)
        --====================--
        --Local Math Functions--
        --====================--
        local rad,sin,cos,rand,print,type = math.rad,math.sin,math.cos,math.random,system.print,type
        local function getQuaternion(x,y,z,w)
            if type(x) == 'number' then
                if w == nil then
                    if x == x and y == y and z == z then
                        x = -rad(x * 0.5)
                        y = rad(y * 0.5)
                        z = -rad(z * 0.5)
                        local s,c=sin,cos
                        local sP,sH,sR=s(x),s(y),s(z)
                        local cP,cH,cR=c(x),c(y),c(z)
                        return (sP*cH*cR-cP*sH*sR),(cP*sH*cR+sP*cH*sR),(cP*cH*sR-sP*sH*cR),(cP*cH*cR+sP*sH*sR)
                    else
                        return 0,0,0,1
                    end
                else
                    return x,y,z,w
                end
            elseif type(x) == 'table' then
                if #x == 3 then
                    return rotMatrixToQuat(x, y, z)
                elseif #x == 4 then
                    return x[1],x[2],x[3],x[4]
                else
                    print('Unsupported Rotation!')
                end
            end
        end
        local function multiply(ax,ay,az,aw,bx,by,bz,bw)
            return ax*bw+aw*bx+ay*bz-az*by,
                   ay*bw+aw*by+az*bx-ax*bz,
                   az*bw+aw*bz+ax*by-ay*bx,
                   aw*bw-ax*bx-ay*by-az*bz
        end
        local function rotatePoint(ax,ay,az,aw,oX,oY,oZ,wX,wY,wZ)
            local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
            return 
                2*(oY*(ax*ay-aw*az)+oZ*(ax*az+aw*ay))+oX*(awaw+axax-ayay-azaz)+wX,
                2*(oX*(aw*az+ax*ay)+oZ*(ay*az-aw*ax))+oY*(awaw-axax+ayay-azaz)+wY,
                2*(oX*(ax*az-aw*ay)+oY*(ax*aw+ay*az))+oZ*(awaw-axax-ayay+azaz)+wZ    
        end
        local superManager,needsUpdate = nil,false
        local outBubble = nil
        --=================--
        --Positional Values--
        --=================--
        local pX,pY,pZ = resultantPos[1],resultantPos[2],resultantPos[3] -- These are original values, for relative to super rotation
        local offX,offY,offZ = 0,0,0
        local wXYZ = resultantPos
        local isRelativePosition = false
        --==================--
        --Orientation Values--
        --==================--
        local tix,tiy,tiz,tiw = 0,0,0,1 -- temp intermediate rotation values
        local tdx,tdy,tdz,tdw = 0,0,0,1 -- temp default intermediate rotation values
    
        local ix,iy,iz,iw = 0,0,0,1 -- intermediate rotation values
        local dx,dy,dz,dw = 0,0,0,1 -- default intermediate rotation values
    
        local out_rotation = rotArray
        local subRotations = {}
    
        --==============--
        --Function Array--
        --==============--
        local out = {}
        
        --============================--
        --Primary Processing Functions--
        --============================--
        local function process(wx,wy,wz,ww,lX,lY,lZ,lTX,lTY,lTZ)
            --local timeStart = system.getTime()
            wx,wy,wz,ww = wx or 0, wy or 0, wz or 0, ww or 1
            lX,lY,lZ = lX or pX, lY or pY, lZ or pZ
            lTX,lTY,lTZ = lTX or pX, lTY or pY, lTZ or pZ
        
            local dX,dY,dZ
            if not isRelativePosition then
                dX,dY,dZ = pX - lX, pY - lY, pZ - lZ
            else
                dX,dY,dZ = pX,pY,pZ
            end
            if ww ~= 1 and ww ~= -1 then
                if dX ~= 0 or dY ~= 0 or dZ ~= 0 then
                    wXYZ[1],wXYZ[2],wXYZ[3] = rotatePoint(wx,wy,wz,ww,dX,dY,dZ,lTX,lTY,lTZ)
	           else
                    wXYZ[1],wXYZ[2],wXYZ[3] = lTX,lTY+rand()*0.00001,lTZ
                end
                if dw ~= 1 then
                    wx,wy,wz,ww = multiply(wx,wy,wz,ww,dx,dy,dz,dw)
                end
                if iw ~= 1 then
                    wx,wy,wz,ww = multiply(wx,wy,wz,ww,ix,iy,iz,iw)
                end
            else
                wXYZ[1],wXYZ[2],wXYZ[3] = lTX+dX,lTY+dY,lTZ+dZ
                if dw ~= 1 then
                    if iw ~= 1 then
                        wx,wy,wz,ww = multiply(dx,dy,dz,dw,ix,iy,iz,iw)
                    else
                        wx,wy,wz,ww = dx,dy,dz,dw
                    end
                else
                    if iw ~= 1 then
                        wx,wy,wz,ww = ix,iy,iz,iw
                    end
                end
            end
            out_rotation[1],out_rotation[2],out_rotation[3],out_rotation[4] = wx,wy,wz,ww
            for i=1, #subRotations do
                subRotations[i].update(wx,wy,wz,ww,pX,pY,pZ,wXYZ[1],wXYZ[2],wXYZ[3])
	       end
            --local endTime = system.getTime()
            needsUpdate = false
        end
        out.update = process 
        local function validate()
            if not superManager then
                process()
            else
                superManager.bubble()
            end
        end
        local function rotate(isDefault)
            if isDefault then
                dx,dy,dz,dw = getQuaternion(tdx,tdy,tdz,tdw)
            else
                ix,iy,iz,iw = getQuaternion(tix,tiy,tiz,tiw)
            end
            validate()
        end
    
        function out.setSuperManager(rotManager)
            superManager = rotManager
        end
    
        function out.addSubRotation(rotManager)
            rotManager.setSuperManager(out)
            subRotations[#subRotations + 1] = rotManager
            process()
        end
        
        function out.bubble()
            if superManager then
                superManager.bubble()
            else
                needsUpdate = true
            end
        end
        outBubble = out.bubble
        function out.checkUpdate()
            if needsUpdate then
                process()
            end
            return needsUpdate
        end
        
        local function assignFunctions(inFuncArr,specialCall)
            inFuncArr.update = process
            function inFuncArr.getPosition() return pX,pY,pZ end
            function inFuncArr.getRotationManger() return out end
            
            function inFuncArr.setPosition(tx,ty,tz)
                if not (tx ~= tx or ty ~= ty or tz ~= tz)  then
                    pX,pY,pZ = tx,ty+rand()*0.00001,tz
                    outBubble()
                end
            end
            
            function inFuncArr.rotateXYZ(rotX,rotY,rotZ,rotW)
                if rotX and rotY and rotZ then
                    tix,tiy,tiz,tiw = rotX,rotY,rotZ,rotW
                    rotate(false)
                    if specialCall then specialCall() end
                else
                    if type(rotX) == 'table' then
                        if #rotX == 3 then
                            tix,tiy,tiz,tiw = rotX[1],rotX[2],rotX[3],nil
                            if specialCall then specialCall() end
                            goto valid  
                        end
                    end
                    print('Invalid format. Must be three angles, or right, forward and up vectors, or a quaternion. Use radians if angles.')
                    ::valid::

                end
                
            end
    
            function inFuncArr.rotateX(rotX) tix = rotX; tiw = nil; rotate(false); if specialCall then specialCall() end end
            function inFuncArr.rotateY(rotY) tiy = rotY; tiw = nil; rotate(false); if specialCall then specialCall() end end
            function inFuncArr.rotateZ(rotZ) tiz = rotZ; tiw = nil; rotate(false); if specialCall then specialCall() end end
    
            function inFuncArr.rotateDefaultXYZ(rotX,rotY,rotZ,rotW)
                if rotX and rotY and rotZ then
                    tdx,tdy,tdz,tdw = rotX,rotY,rotZ,rotW
                    rotate(true)
                    if specialCall then specialCall() end
                else
                    if type(rotX) == 'table' then
                        if #rotX == 3 then
                            tdx,tdy,tdz,tdw = rotX[1],rotX[2],rotX[3],nil
                            if specialCall then specialCall() end
                            goto valid  
                        end
                    end
                    print('Invalid format. Must be three angles, or right, forward and up vectors, or a quaternion. Use radians if angles.')
                    ::valid::
                end
            end
            function inFuncArr.rotateDefaultX(rotX) tdx = rotX; tdw = nil; rotate(true); if specialCall then specialCall() end end
            function inFuncArr.rotateDefaultY(rotY) tdy = rotY; tdw = nil; rotate(true); if specialCall then specialCall() end end
            function inFuncArr.rotateDefaultZ(rotZ) tdz = rotZ; tdw = nil; rotate(true); if specialCall then specialCall() end end
            function inFuncArr.setPositionIsRelative(isRelative) isRelativePosition = true; outBubble() end
        end
        out.assignFunctions = assignFunctions
        
        return out
    end
    self.getRotationManager = RotationHandler
    return self
end

function Camera(camType, position, orientation)
    
    local rad=math.rad
    local ori = orientation or {0,0,0,1}
    local pos = position or {0,0,0}
    local rotM = getManager().getRotationManager(orientation,position)
    local self = {
        cType = camType or CameraTypes.player,
        position = pos, 
        orientation = ori
    }
    rotM.assignFunctions(self)

    return self
end

local print = system.print

function ObjectGroup(objects, transX, transY)
    local objects=objects or {}
    local self={style='',gStyle='',objects=objects,transX=transX,transY=transY,enabled=true,glow=false,gRad=10,scale = false}
    function self.addObject(object, id)
        local id=id or #objects+1
        objects[id]=object
        return id
    end
    function self.removeObject(id) objects[id] = {} end
    
    function self.hide() self.enabled = false end
    function self.show() self.enabled = true end
    function self.isEnabled() return self.enabled end
    
    function self.setStyle(style) self.style = style end
    function self.setGlowStyle(gStyle) self.gStyle = gStyle end
    function self.setGlow(enable,radius,scale) self.glow = enable; self.gRad = radius or self.gRad; self.scale = scale or false end 
    return self
end

function Object(style, position, offset, orientation, positionType, orientationType, transX, transY)
    local rad,print,rand,manager=math.rad,system.print,math.random,getManager()
    local RotationHandler = manager.getRotationManager
    
    local position=position
    local positionOffset=offset
    
    local style=style
    local customGroups,uiGroups,subObjects={},{},{}
    local positionType=positionType
    local orientationType=orientationType
    local ori = {0,0,0,1}
    local objRotationHandler = RotationHandler(ori,position)
    
    local defs = {}
    local self = {
        false,false,false,customGroups,false,uiGroups,subObjects,
        positionType, --8
        orientationType, --9
        ori,
        style,
        position,
        offset,
        transX,
        transY,
        defs
    }
    function self.addDef(string)
        defs[#defs + 1] = string
    end
    function self.resetDefs()
        defs = {}
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
                pC=#points+1
                return self
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
                if pC > 1 then
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
            local self={}
            local outArr = {false,false,false,false,false,false}
            singlePoint[sC]= outArr
            sC=sC+1
            function self.setPosition(position)
                outArr[2],outArr[3],outArr[4]=position[1]/scale+offsetX,position[2]/scale-offsetY,position[3]/scale-offsetZ
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
            function self.setEnabled(enabled)
                outArr[1] = enabled
                return self
            end
            function self.build()
                outArr[1] = true
                return self
            end
            return self
        end
        return self
    end
    objRotationHandler.assignFunctions(self)
    
    function self.addSubObject(object)
        objRotationHandler.addSubRotation(object.getRotationManager())
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
        local objOri, objPos = mObject[10], mObject[12]
        local objPosX, objPosY, objPosZ = objPos[1], objPos[2], objPos[3]
        local wx, wy, wz, ww = objOri[1], objOri[2], objOri[3], objOri[4]
        if mObject[9] == 1 then
            wx, wy, wz, ww =
                wx*aw + ww*ax + wy*az - wz*ay,
                wy*aw + ww*ay + wz*ax - wx*az,
                wz*aw + ww*az + wx*ay - wy*ax,
                ww*aw - wx*ax - wy*ay - wz*az
        end
        if mObject[8] == 2 then -- If Local
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
            local notIntersected = true
            for m = 1, #objects do
                local obj = objects[m]
                if obj[12] == nil then
                    goto is_nil
                end

                local mx, my, mz, mw, mw1, mw2, mw3 = getModelMatrix(obj)

                local objStyle = obj[11]
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

                local customGroups, uiGroups = obj[4], obj[6]
                for cG = 1, #customGroups do
                    local customGroup = customGroups[cG]
                    local multiGroups = customGroup[2]
                    local singleGroups = customGroup[3]
                    for mGC = 1, #multiGroups do
                        local multiGroup = multiGroups[mGC]
                        local pts = multiGroup[1]
                        local tPoints = {}
                        local ct = 1
                        local mGAvg = 0
                        for pC = 1, #pts do
                            local p = pts[pC]
                            local x, y, z = p[1], p[2], p[3]
                            local pz = mYX * x + mYY * y + mYZ * z + mYW
                            if pz < 0 then
                                goto behindMG
                            end

                            tPoints[ct] = {
                                (mXX * x + mXY * y + mXZ * z + mXW) / pz,
                                (mZX * x + mZY * y + mZZ * z + mZW) / pz,
                                pz
                            }
                            mGAvg = mGAvg + pz
                            ct = ct + 1
                            ::behindMG::
                        end
                        if ct ~= 1 then
                            local drawFunction = multiGroup[2]
                            local data = multiGroup[3]
                            zBC = zBC + 1
                            local depth = mGAvg/(ct-1)
                            zSorter[zBC] = depth
                            zBuffer[depth] = {
                                tPoints,
                                data,
                                drawFunction
                            }
                        end
                    end
                    for sGC = 1, #singleGroups do
                        local singleGroup = singleGroups[sGC]
                        if not singleGroup[1] then goto behindSingle end
                        
                        local x, y, z = singleGroup[2], singleGroup[3], singleGroup[4]
                        local pz = mYX * x + mYY * y + mYZ * z + mYW
                        if pz < 0 then
                            goto behindSingle
                        end

                        local drawFunction = singleGroup[5]
                        local data = singleGroup[6]
                        zBC = zBC + 1
                        zSorter[zBC] = pz
                        zBuffer[pz] = {
                            (mXX * x + mXY * y + mXZ * z + mXW) / pz,
                            (mZX * x + mZY * y + mZZ * z + mZW) / pz,
                            data,
                            drawFunction,
                            isCustomSingle = true
                        }
                        ::behindSingle::
                    end
                end
                ::is_nil::
            end
            sort(zSorter)
            for zC = zBC, 1,-1 do
                local distance = zSorter[zC]
                local uiElmt = zBuffer[distance]
                if uiElmt.isCustomSingle then
                    local x,y,data,drawFunction = uiElmt[1],uiElmt[2],uiElmt[3],uiElmt[4]
                    local unpackSize = #unpackData
                    drawStringData[dU] = drawFunction(x,y,distance,data,unpackData,uC) or '<text x=0 y=0>Error: N-CS</text>'
                    dU = dU + 1
                    local newUnpackSize = #unpackData
                    if unpackSize ~= newUnpackSize then
                        uC = newUnpackSize + 1
                    end
                else
                    local points,data,drawFunction = uiElmt[1],uiElmt[2],uiElmt[3]
                    local unpackSize = #unpackData
                    drawStringData[dU] = drawFunction(points,data,unpackData,uC)
                    dU = dU + 1
                    local newUnpackSize = #unpackData
                    if unpackSize ~= newUnpackSize then
                        uC = newUnpackSize + 1
                    end
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
                    '<style> svg{width:%gpx;height:%gpx;position:absolute;top:0px;left:0px;} %s </style>',
                    width * nFactor,
                    height * nFactor,
                    objectGroup.style
                ),
                format(concat(drawStringData), unpack(unpackData)),
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