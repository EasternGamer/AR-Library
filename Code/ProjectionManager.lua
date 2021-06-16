function Projector(core, camera)
    -- Localize frequently accessed data
    local utils = require('cpml.utils')
    local library = library
    local core = core
    local unit = unit
    local system = system
    local manager = getManager()
    
    -- Localize frequently accessed functions
    --- Library-based function calls
    local solve = library.systemResolution3
    
    --- System-based function calls
    local getWidth = system.getScreenWidth
    local getHeight = system.getScreenHeight
    local getFov = system.getFov
    local getMouseDeltaX = system.getMouseDeltaX
    local getMouseDeltaY = system.getMouseDeltaY
    local getPlayerWorldPos = system.getPlayerWorldPos
    local print = system.print
    
    --- Core-based function calls
    local getCWorldPos = core.getConstructWorldPos
    local getCWorldOriR = core.getConstructWorldOrientationRight
    local getCWorldOriF = core.getConstructWorldOrientationForward
    local getCWorldOriU = core.getConstructWorldOrientationUp
    local getElementPositionById = core.getElementPositionById
    local getElementRotationById = core.getElementRotationById
    
    --- Unit-based function calls
    local getRelativeOrientation = unit.getMasterPlayerRelativeOrientation
    
    --- Camera-based function calls
    local getAlignmentType = camera.getAlignmentType
    
    --- Manager-based function calls
    ---- Positional Operations
    local getLocalToWorldConverter = manager.getLocalToWorldConverter
    local getWorldToLocalConverter = manager.getWorldToLocalConverter
    local getTrueWorldPos = manager.getTrueWorldPos
    local getPlayerLocalPos = manager.getPlayerLocalPos
    ---- Quaternion operations
    local rotToQuat = manager.rotationMatrixToQuaternion
    local rotToEuler = manager.rotationMatrixToEuler
    local inverse = manager.inverse
    local multiply = manager.multiply
    local divide = manager.divide
    
    -- Localize Math functions
    local sin, cos, tan = math.sin, math.cos, math.tan
    local rad, deg, sqrt = math.rad, math.deg, math.sqrt
    local atan = math.atan
    local ceil, floor = math.ceil, math.floor
    local round = utils.round

    -- Projection infomation
    --- Screen Parameters
    local width = getWidth()/2
    local height = getHeight()/2

    --- FOV Paramters
    
    --local offset = (width + height) / 5000
    local offset = 0
    local hfovRad = rad(getFov() + offset)
    local tanFov = tan(hfovRad/2)*height/width

    --- Matrix Subprocessing
    local aspect = width/height
    local near = width/tanFov
    local top = near * tanFov
    local bottom = -top;
    local left = bottom * aspect
    local right = top * aspect

    --- Matrix Paramters
    local x0 = 2 * near / (right - left)
    local y0 = 2 * near / (top - bottom)
    
    -- Player-related values
    local playerId = unit.getMasterPlayerId()
    local unitId = unit.getId()
    
    -- Camera-Related values
    local eye = camera.position
    local cOrientation = camera.orientation
    local cameraType = camera.cType
    local alignmentType = nil
    
    --- Mouse info
    local sensitivity = 1 --export: Sensitivtiy
    local m = sensitivity*(width*2)*0.00104584100642898 + 0.00222458611638299

    local bottomLock = false
    local topLock = false
    local rightLock = false
    local leftLock = false

    local objectGroups = {}
    
    local self = {objectGroups = objectGroups}

    function self.getSize(size, zDepth, max, min)
        local pSize = atan(size, zDepth) * (near / aspect)
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
    
    function self.updateCamera()
        if cameraType.name ~= "fGlobal" and cameraType.name ~= "fLocal" then
            
            -- Localize variables
            local atan = atan
            
            eye = getPlayerLocalPos(playerId)

            local deltaMouseY = getMouseDeltaY()
            local deltaMouseX = getMouseDeltaX()
            local width = width
            local deltaPitch = atan(-deltaMouseY,width) * m
            local deltaHeading = atan(deltaMouseX,width) * m
        
            local pPitch = cOrientation[1]
            local pHeading = cOrientation[2]
            
            local alignmentType = alignmentType
            if alignmentType == nil then
                alignmentType = getAlignmentType()
            end
            --print(alignmentType.name)
            local pitchPos = alignmentType.pitchPos
            local pitchNeg = alignmentType.pitchNeg
            local headingPos = alignmentType.headingPos
            local headingNeg = alignmentType.headingNeg
            
            if pitchPos ~= nil then
                if (bottomLock == false and topLock == false) then  
                    pPitch = pPitch + deltaPitch
                    if pPitch <= pitchNeg then
                        pPitch = pitchNeg
                        bottomLock = true
                    end
                    if pPitch >= pitchPos then
                        pPitch = pitchPos
                        topLock = true
                    end
                else
                    if bottomLock == true and deltaMouseY < 0 then
                        bottomLock = false
                        pPitch = pPitch + deltaPitch
                    end
                    if topLock == true and deltaMouseY > 0 then
                        topLock = false
                        pPitch = pPitch + deltaPitch
                    end
                end
                cOrientation[1] = pPitch
            else
                cOrientation[1] = 0
            end
            if headingPos ~= nil then
                if (leftLock == false and rightLock == false) then  
                    pHeading = pHeading + deltaHeading
                    if pHeading <= headingNeg then
                        pHeading = headingNeg
                        leftLock = true
                    end
                    if pHeading >= headingPos then
                        pHeading = headingPos
                        rightLock = true
                    end
                else
                    if rightLock == true and deltaMouseX < 0 then
                        rightLock = false
                        pHeading = pHeading + deltaHeading
                    end
                    if leftLock == true and deltaMouseX > 0 then
                        leftLock = false
                        pHeading = pHeading + deltaHeading
                    end
                end
                cOrientation[2] = pHeading
            else
                cOrientation[2] = 0
            end
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
    
    function self.getModelMatrices(mObject)
        
        local s = sin
        local c = cos
        local multi = multiply
        local inverse = inverse
        local modelMatrices = {}
        
        -- Localize Object values.
        local obj = mObject
        local objOriType = obj.orientationType
        local objOri = obj.orientation
        local objPosType = obj.positionType
        local objPos = obj.position
        local objPosX,objPosY,objPosZ = objPos[1],objPos[2],objPos[3]
        
        local cU = getCWorldOriU()
        local cUX,cUY,cUZ = cU[1],cU[2],cU[3]
        local cF = getCWorldOriF()
        local cFX,cFY,cFZ = cF[1],cF[2],cF[3]
        local cR = getCWorldOriR()
        local cRX,cRY,cRZ = cR[1],cR[2],cR[3]
        
        local sx,sy,sz,sw = rotToQuat({cRX,cRY,cRZ,0,cFX,cFY,cFZ,0,cUX,cUY,cUZ,0,0,0,0,1})
        
        local recurse = {}
        local ct = 2
        function recurse.subObjectMatrices(lx, ly, lz, lw, sObjX, sObjY, sObjZ, object, posLX, posLY, posLZ)
            local objPos = object.position
            local objRot = object.orientation
            local objRotType = object.orientationType
            local objX,objY,objZ = objPos[1],objPos[2],objPos[3]
            
            local objP,objH,objR = objRot[1] / 2,objRot[2] / 2,objRot[3] / 2
            local sP,sH,sR = s(objP),s(objR),s(objH)
            local cP,cH,cR = c(objP),c(objR),c(objH)
    
            local wwx = sP*cH*cR - cP*sH*sR
            local wwy = cP*sH*cR + sP*cH*sR
            local wwz = cP*cH*sR - sP*sH*cR
            local www = cP*cH*cR + sP*sH*sR
            local wx, wy, wz, ww = wwx,wwy,wwz,www

            local lix, liy, liz, liw = inverse(lx, ly, lz, lw)
            
            local posTX, posTY, posTZ, posTW = multi(lx, ly, lz, lw, objX, objY, objZ, 0)

            local posIX = -posTX*liw + posTW*lix - posTY*liz - posTZ*liy
            local posIY = posTY*liw + posTW*liy + posTZ*lix - posTX*liz
            local posIZ = -posTZ*liw + posTW*liz + posTX*liy + posTY*lix

            if object.positionType == "local" then
                local dotX = cRX*posIX + cFX*posIY + cUX*posIZ
                local dotY = cRY*posIX + cFY*posIY + cUY*posIZ
                local dotZ = cRZ*posIX + cFZ*posIY + cUZ*posIZ
                posIX = dotX
                posIY = dotY
                posIZ = dotZ
            end
            posIX, posIY, posIZ = posIX + posLX, posIY + posLY, posIZ + posLZ
            
            if objRotType == "local" then
                wx, wy, wz, ww = multi(wx, wy, wz, ww, sx, sy, sz, sw)
            end
            local wxwx,wxwy,wxwz,wxww = wx*wx,wx*wy,wx*wz,wx*ww
            local wywy,wywz,wyww = wy*wy,wy*wz,wy*ww
            local wzwz,wzww = wz*wz,wz*ww
            local a1 = 1 - 2*(wywy + wzwz)
            local b1 = 2*(wxwy - wzww)
            local c1 = 2*(wxwz + wyww)
    
            local d1 = 2*(wxwy + wzww)
            local e1 = 1 - 2*(wxwx + wzwz)
            local f1 = 2*(wywz - wxww)
    
            local g1 = 2*(wxwz - wyww)
            local h1 = 2*(wywz + wxww)
            local i1 = 1 - 2*(wxwx + wywy)
            
            modelMatrices[ct] = {
                object,
                {
                    a1, -d1, -g1, posIX,
                    -b1, e1, h1, -posIY,
                    -c1, f1, i1, -posIZ,
                    0, 0, 0, 1
                }

            }
            ct=ct+1
            
            local subObjects = object.subObjects
            if #subObjects > 0 then
                for k = 1, #subObjects do
                    local subObj = subObjects[k]
                    if subObj.position~=nil then
                        recurse.subObjectMatrices(wwx, wwy, wwz, www, objX, objY, objZ, subObj, posIX, posIY, posIZ)
                    end
                end
            end
        end
        local pitch,heading,roll = objOri[1] / 2,objOri[2] / 2,objOri[3] / 2
        
        --- Quaternion of object rotations
        local sP,sH,sR = s(pitch),s(roll),s(heading)
        local cP,cH,cR = c(pitch),c(roll),c(heading)
    
        local wwx = (sP*cH*cR - cP*sH*sR)
        local wwy = (cP*sH*cR + sP*cH*sR)
        local wwz = (cP*cH*sR - sP*sH*cR)
        local www = (cP*cH*cR + sP*sH*sR)
        local wx,wy,wz,ww = wwx,wwy,wwz,www
        
        if objOriType == "local" then
            wx,wy,wz,ww = multiply(wx,wy,wz,ww,sx,sy,sz,sw)
        end
        
        local wxwx,wxwy,wxwz,wxww = wx*wx,wx*wy,wx*wz,wx*ww
        local wywy,wywz,wyww = wy*wy,wy*wz,wy*ww
        local wzwz,wzww = wz*wz,wz*ww
        
        local a2 = 1 - 2*(wywy + wzwz)
        local b2 = 2*(wxwy - wzww)
        local c2 = 2*(wxwz + wyww)
    
        local d2 = 2*(wxwy + wzww)
        local e2 = 1 - 2*(wxwx + wzwz)
        local f2 = 2*(wywz - wxww)
    
        local g2 = 2*(wxwz - wyww)
        local h2 = 2*(wywz + wxww)
        local i2 = 1 - 2*(wxwx + wywy)

        if objPosType == "local" then
            local dotX = cRX*objPosX + cFX*objPosY + cUX*objPosZ
            local dotY = cRY*objPosX + cFY*objPosY + cUY*objPosZ
            local dotZ = cRZ*objPosX + cFZ*objPosY + cUZ*objPosZ
            objPosX = dotX
            objPosY = dotY
            objPosZ = dotZ
        else
            local cWorldPos = getTrueWorldPos()
            objPosX = objPosX - cWorldPos[1]
            objPosY = objPosY - cWorldPos[2]
            objPosZ = objPosZ - cWorldPos[3]
        end
        local subObjs = obj.subObjects
        if #subObjs > 0 then
            for k = 1, #subObjs do
                local subObj = subObjs[k]
                if subObj.position ~= nil then
                    recurse.subObjectMatrices(wwx,wwy,wwz,www,objPos[1],objPos[2],objPos[3],subObj,objPosX,objPosY,objPosZ)
                end
            end
        end
        modelMatrices[1] = {obj,{a2, -d2, -g2, objPosX,-b2, e2, h2, -objPosY,-c2, f2, i2, -objPosZ,0, 0, 0, 1}}
        return modelMatrices
    end
	function self.getViewMatrix()
        local multi = multiply
        local solve = solve
        
        local board = getElementRotationById(unitId)
        local ax,ay,az,aw = board[1],board[2],board[3],board[4]
        
        local body = getRelativeOrientation()
        local bx,by,bz,bw = body[1],body[2],body[3],body[4]

        local v1 = getCWorldOriR()
        local v2 = getCWorldOriF()
        local v3 = getCWorldOriU()
        local v1t = solve(v1,v2,v3,{1,0,0})
        local v2t = solve(v1,v2,v3,{0,1,0})
        local v3t = solve(v1,v2,v3,{0,0,1})
        
        local sx, sy, sz, sw = rotToQuat({v1t[1],v1t[2],v1t[3],0,v2t[1],v2t[2],v2t[3],0,v3t[1],v3t[2],v3t[3],0,0,0,0,1})
        local lx, ly, lz, lw = rotToQuat({v1[1],v1[2],v1[3],0,v2[1],v2[2],v2[3],0,v3[1],v3[2],v3[3],0,0,0,0,1})

        local eye = eye
        local eyeX,eyeY,eyeZ = eye[1],eye[2],eye[3]
        local dotX, dotY, dotZ = eyeX, eyeY, eyeZ
        local wx, wy, wz, ww = 0,0,0,1
        local s = sin
        local c = cos
        
        local px, py, pz, pw = multi(ax, ay, az, aw, bx, by, bz, bw)
        local alignment = getAlignmentType(px, py, pz, pw, eyeX, eyeY, eyeZ)
        alignmentType = alignment
        local pix, piy, piz, piw = inverse(px, py, pz, pw)
        local shift = alignment.shift
            
        local eyeTX, eyeTY, eyeTZ, eyeTW = multi(px, py, pz, pw, shift[1], shift[2], shift[3], 0)
        local eyeIX, eyeIY, eyeIZ, eyeIW = multi(eyeTX, eyeTY, eyeTZ, eyeTW, pix, piy, piz, piw)
        
        local alignName = alignment.name
        local nFG=alignName~="fGlobal"
        local fG=alignName=="fGlobal"
        local nFL=alignName~="fLocal"
        local fL=alignName=="fLocal"
        local ori = cOrientation
        local pitch,roll,heading = ori[1] / 2,0,ori[2] / 2,0
        if pitch ~= 0 or heading ~= 0 or roll ~= 0 or fG or fL then
            local sP,sH,sR = s(pitch),s(roll),s(heading)
            local cP,cH,cR = c(pitch),c(roll),c(heading)
            
            local cx = sP*cH*cR - cP*sH*sR
            local cy = -cP*sH*cR - sP*cH*sR
            local cz = -cP*cH*sR + sP*sH*cR
            local cw = cP*cH*cR + sP*sH*sR
            if nFG and nFL then
                px,py,pz,pw = multi(px,py,pz,pw,cx,cy,cz,cw)

            elseif alignName == "fGlobal" then
                wx,wy,wz,ww = cx,cy,cz,cw
            else
                wx,wy,wz,ww = multi(sx,sy,sz,sw,cx,cy,cz,cw)
            end
        end
        
        if nFG and nFL then
            local pxpx,pxpy,pxpz,pxpw = px*px,px*py,px*pz,px*pw
            local pypy,pypz,pypw = py*py,py*pz,py*pw
            local pzpz,pzpw = pz*pz,pz*pw
            
            local a1 = 1 - 2*(pypy + pzpz)
            local b1 = 2*(pxpy - pzpw)
            local c1 = 2*(pxpz + pypw)
    
            local d1 = 2*(pxpy + pzpw)
            local e1 = 1 - 2*(pxpx + pzpz)
            local f1 = 2*(pypz - pxpw)
    
            local g1 = 2*(pxpz - pypw)
            local h1 = 2*(pypz + pxpw)
            local i1 = 1 - 2*(pxpx + pypy)
            eyeX = eyeX - eyeIX
            eyeY = eyeY + eyeIY
            eyeZ = eyeZ + eyeIZ
        
            dotX = a1*eyeX + -d1*eyeY + -g1*eyeZ
            dotY = -b1*eyeX + e1*eyeY + h1*eyeZ
            dotZ = -c1*eyeX + f1*eyeY + i1*eyeZ
            wx,wy,wz,ww = multi(sx,sy,sz,sw,px,py,pz,pw)
        end
        -- Camera rotation determination
        --- Directly input euler angles in radians
        
        local wxwx,wxwy,wxwz,wxww = wx*wx,wx*wy,wx*wz,wx*ww
        local wywy,wywz,wyww = wy*wy,wy*wz,wy*ww
        local wzwz,wzww = wz*wz,wz*ww
        
        --- Matrix of camera rotations, using quaternions
        local a2 = 1 - 2*(wywy + wzwz)
        local b2 = 2*(wxwy - wzww)
        local c2 = 2*(wxwz + wyww)
    
        local d2 = 2*(wxwy + wzww)
        local e2 = 1 - 2*(wxwx + wzwz)
        local f2 = 2*(wywz - wxww)
    
        local g2 = 2*(wxwz - wyww)
        local h2 = 2*(wywz + wxww)
        local i2 = 1 - 2*(wxwx + wywy)

        return {a2, -d2, -g2, dotX,-b2, e2, h2, dotY,-c2, f2, i2, dotZ,0, 0, 0, 1}
    end
    
    function self.getSVG()
        local svg = {}
        local c = 1
        local view = self.getViewMatrix()

        local vx1,vy1,vz1,vw1 = view[1],view[2],view[3],view[4]
        local vx2,vy2,vz2,vw2 = view[5],view[6],view[7],view[8]
        local vx3,vy3,vz3,vw3 = view[9],view[10],view[11],view[12]
        
        local getSize = self.getSize
        
        local function translate(x,y,z,mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
            local x,y,z = x,-y,-z
            local px = mXX * x + mXY * y + mXZ * z + mXW
            local py = mYX * x + mYY * y + mYZ * z + mYW
            local pz = mZX * x + mZY * y + mZZ * z + mZW
            local pw = -py
                
            -- Convert to window coordinates after W-Divide
            local wx = (px / pw) * width
            local wy = (pz / pw) * height
            return wx, wy, pw
        end
        local function createCurve(svg,c,mx,my,cx1,cy1,cx2,cy2,ex,ey)
            svg[c]='M'
            svg[c+1]=mx
            svg[c+2]=' '
            svg[c+3]=my
            svg[c+4]='C'
            svg[c+5]=cx1
            svg[c+6]=' '
            svg[c+7]=cy1
            svg[c+8]=','
            svg[c+9]=cx2
            svg[c+10]=' '
            svg[c+11]=cy2
            svg[c+12]=','
            svg[c+13]=ex
            svg[c+14]=' '
            svg[c+15]=ey
            return c+16
        end
        local function createLabel(svg,c,x,y,text,size,opacity,fill)
            svg[c] = '<text x="'
            svg[c+1] = x
            svg[c+2] = '" y="'
            svg[c+3] = y
            c=c+4
            if opacity~=nil then
                svg[c] = '" fill-opacity="'
                svg[c+1] = opacity
                svg[c+2] = '" stroke-opacity="'
                svg[c+3] = opacity
                c=c+4
            end
            if fill~=nil then
                svg[c] = '" fill="'
                svg[c+1]=fill
                c=c+2
            end
            if size~=nil then
                svg[c] = '" font-size="'
                svg[c+1]=size
                c=c+2
            end
            
            svg[c] = '">'
            svg[c+1] = text
            svg[c+2] = '</text>'
            return c+3
        end
        -- Localize projection matrix values
        local px1 = x0
        local py2 = 1 --c0
        local pz3 = y0
        
        -- Localize screen info
        local width = width
        local height = height

        local objectGroups = objectGroups
        for i = 1, #objectGroups do
            local objectGroup = objectGroups[i]
            if objectGroup.enabled == true then
            local objGTransX = objectGroup.transX or width
            local objGTransY = objectGroup.transY or height
            local objects = objectGroup.objects
            
            svg[c] = [[<svg viewBox="0 0 ]]
            svg[c+1] = width*2
            svg[c+2] = [[ ]]
            svg[c+3] = height*2
            svg[c+4] = [[" class="]]
            svg[c+5] = objectGroup.style
            svg[c+6] = '"><g transform="translate('
            svg[c+7] = objGTransX
            svg[c+8] = ','
            svg[c+9] = objGTransY
            svg[c+10] = ')">'
            c=c+11
            for m = 1, #objects do
                local obj = objects[m]
                if obj.position ~= nil then
                local models = self.getModelMatrices(obj)
                -- Localize model matrix values
                for k = 1, #models do
                    local modelObj = models[k]
                    local object = modelObj[1]
                    local model = modelObj[2]
                    
                    local objStyle = object.style
                    local objTransX = object.transX or 0
                    local objTransY = object.transY or 0
                    
                    svg[c] = '<g class="'
                    svg[c+1] = objStyle
                    c=c+2
                    if objTransX ~= 0 or objTransY ~= 0 then
                            svg[c] = '" transform="translate('
                            svg[c+1] = objTransX
                            svg[c+2] = ','
                            svg[c+3] = objTransY
                            svg[c+4] = ')'
                            c=c+5
                    end
                    svg[c] = '">'
                    c=c+1
                    local mx1,my1,mz1,mw1 = model[1],model[2],model[3],model[4]
                    local mx2,my2,mz2,mw2 = model[5],model[6],model[7],model[8]
                    local mx3,my3,mz3,mw3 = model[9],model[10],model[11],model[12]
                
                    local mXX = px1*(vx1*mx1 + vy1*mx2 + vz1*mx3)
                    local mXY = px1*(vx1*my1 + vy1*my2 + vz1*my3)
                    local mXZ = px1*(vx1*mz1 + vy1*mz2 + vz1*mz3)
                    local mXW = px1*(vw1 + vx1*mw1 + vy1*mw2 + vz1*mw3)
        
                    local mYX = (vx2*mx1 + vy2*mx2 + vz2*mx3)
                    local mYY = (vx2*my1 + vy2*my2 + vz2*my3)
                    local mYZ = (vx2*mz1 + vy2*mz2 + vz2*mz3)
                    local mYW = (vw2 + vx2*mw1 + vy2*mw2 + vz2*mw3)
        
                    local mZX = pz3*(vx3*mx1 + vy3*mx2 + vz3*mx3)
                    local mZY = pz3*(vx3*my1 + vy3*my2 + vz3*my3)
                    local mZZ = pz3*(vx3*mz1 + vy3*mz2 + vz3*mz3)
                    local mZW = pz3*(vw3 + vx3*mw1 + vy3*mw2 + vz3*mw3)
                
                    local polylineGroups = object.polylineGroups
                    local circleGroups = object.circleGroups
                    local curvesGroups = object.curveGroups
                    local customGroups = object.customGroups
            
                    -- Polylines for-loop
                    for d=1,#polylineGroups do
                        local polylineGroup = polylineGroups[d]
                        svg[c] = '<path class="'
                        svg[c+1] = polylineGroup[1]
                        svg[c+2] = '" d="'
                        c = c+3
                        for f=2,#polylineGroup do
                            local line = polylineGroup[f]
                            svg[c] = 'M '
                            local lC=0
                            local sP={}
                            local eP={}
                            c=c+1
                            for h = 1, #line do
                                local p = line[h]
                                local wx,wy,ww = translate(p[1],p[2],p[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)

                                -- If PW is negative, it means the point is behind you
                                if ww > 0 then
                                    if lC ~= 0 then
                                        svg[c] = ' L '
                                        c = c + 1
                                        eP = {wx, wy}
                                    else
                                        sP = {wx, wy}
                                    end
                                    svg[c] = wx
                                    svg[c+1] = ' '
                                    svg[c+2] = wy
                                    c=c+3
                                    lC=lC+1
                                end
                            end
                            if lC < 2 then
                                if lC == 1 then
                                    svg[c-4] = ''
                                    svg[c-3] = ''
                                    svg[c-2] = ''
                                    svg[c-1] = ''
                                    c=c-4
                                else
                                    svg[c-1] = ''
                                    c=c-1
                                end
                            else
                                if eP[1] == sP[1] and eP[2] == sP[2] then
                                    svg[c-4] = ' Z '
                                    svg[c-3] = ''
                                    svg[c-2] = ''
                                    svg[c-1] = ''
                                    c=c-3
                                end
                            end
                        end
                        svg[c] = '"/>'
                        c=c+1
                    end
                    for cG=1,#circleGroups do
                        local circleGroup = circleGroups[cG]
                        svg[c] = '<g class="'
                        svg[c+1] = circleGroup[1]
                        svg[c+2] = '">'
                        c=c+3
                        for l=2, #circleGroup do
                            local cir = circleGroup[l]
                            local p = cir[1]
                            local wx,wy,wz = translate(p[1],p[2],p[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                            if wz > 0 then
                                local radius,fill,label,offX,offY,size,resize,action = cir[2],cir[3],cir[4],cir[5],cir[6],cir[7],cir[8],cir[9]
                                svg[c] = '<circle cx="'
                                svg[c+1] = wx
                                svg[c+2] = '" cy="'
                                svg[c+3] = wy
                                svg[c+4] = '" r="'
                                svg[c+5] = radius
                                svg[c+6] = '" fill="'
                                svg[c+7] = fill
                                svg[c+8] = '"/>'
                                c = c+9
                                if label ~= nil then
                                    svg[c] = '<text x="'
                                    svg[c+1] = wx + offX
                                    svg[c+2] = '" y="'
                                    svg[c+3] = wy + offY
                                    c=c+4
                                    if size ~= nil then
                                        if resize==true then
                                           svg[c]='" font-size="'
                                           svg[c+1] = getSize(size, wz)
                                        else
                                           svg[c]='" font-size="'
                                           svg[c+1] = size
                                        end
                                        c=c+2
                                    end
                                    svg[c] = '">'
                                    svg[c+1] = label
                                    svg[c+2] = '</text>'
                                    c=c+3
                                end
                                if action ~= nil then
                                    c = action(svg, c, object, wx, wy, wz)
                                end
                            end
                        end
                        svg[c] = '</g>'
                        c=c+1
                    end
                    for cuG=1, #curvesGroups do
                            local curveG = curvesGroups[cuG]
                            svg[c] = '<g class="'
                            svg[c+1] = curveG[1]
                            svg[c+2] = '">'
                            c=c+3
                            local curveG = curvesGroups[cuG]
                            svg[c] = '<path d="'
                            c=c+1
                            local curves = curveG[2]
                            local sLabelDat = {}
                            local sLDC = 0
                            for cCt=1, #curves do
                                local curve = curves[cCt]
                                if curve[1] == 'circle' then
                                    local pts = curve[2]
                                    local labelDat = curve[3]
                                    local p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12 = pts[1],pts[2],pts[3],pts[4],pts[5],pts[6],pts[7],pts[8],pts[9],pts[10],pts[11],pts[12]
                                    local m1x,m1y,m1z=translate(p1[1],p1[2],p1[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    local m2x,m2y,m2z=translate(p2[1],p2[2],p2[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    local m3x,m3y,m3z=translate(p3[1],p3[2],p3[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    local m4x,m4y,m4z=translate(p4[1],p4[2],p4[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    if m1z>0 and m2z>0 and m3z>0 and m4z>0 then
                                            c=createCurve(svg,c,m1x,m1y,m2x,m2y,m3x,m3y,m4x,m4y)
                                    end
                                    local m5x,m5y,m5z=translate(p5[1],p5[2],p5[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    local m6x,m6y,m6z=translate(p6[1],p6[2],p6[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    local m7x,m7y,m7z=translate(p7[1],p7[2],p7[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    if m4z>0 and m5z>0 and m6z>0 and m7z>0 then
                                            c=createCurve(svg,c,m4x,m4y,m5x,m5y,m6x,m6y,m7x,m7y)
                                    end
                                    local m8x,m8y,m8z=translate(p8[1],p8[2],p8[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    local m9x,m9y,m9z=translate(p9[1],p9[2],p9[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    local m10x,m10y,m10z=translate(p10[1],p10[2],p10[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    if m7z>0 and m8z>0 and m9z>0 and m10z>0 then
                                            c=createCurve(svg,c,m7x,m7y,m8x,m8y,m9x,m9y,m10x,m10y)
                                    end    
                                    local m11x,m11y,m11z=translate(p11[1],p11[2],p11[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    local m12x,m12y,m12z=translate(p12[1],p12[2],p12[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                    if m10z>0 and m11z>0 and m12z>0 and m1z>0 then
                                            c=createCurve(svg,c,m10x,m10y,m11x,m11y,m12x,m12y,m1x,m1y)
                                    end
                                    if labelDat[1]~=nil then
                                            if m1z>0 and m4z>0 and m7z>0 and m10z>0 then
                                                sLabelDat[sLDC+1]={
                                                    {m1x,m1y,m1z},
                                                    {m4x,m4y,m4z},
                                                    {m7x,m7y,m7z},
                                                    {m10x,m10y,m10z},
                                                    labelDat
                                                }
                                                sLDC=sLDC+1
                                            end
                                    end
                                else
                                end
                            end
                            svg[c] = '"/>'
                            c=c+1
                            if sLDC > 0 then
                                for ll=1, sLDC do
                                        local lInfo = sLabelDat[ll]
                                        local p1,p2,p3,p4,dat = lInfo[1],lInfo[2],lInfo[3],lInfo[4],lInfo[5]
                                        local s = dat[3]
                                        local s1,s2,s3,s4 = s,s,s,s
                                        local label = dat[1]
                                        if dat[2] == true then
                                            s1,s2,s3,s4 = getSize(s1, p1[3], 100, 1), getSize(s2, p2[3], 100, 1), getSize(s3, p3[3], 100, 1), getSize(s4, p4[3], 100, 1)
                                        end
                                        c=createLabel(svg,c,p1[1],p1[2],label,s1,nil,'white')
                                        c=createLabel(svg,c,p2[1],p2[2],label,s2,nil,'white')
                                        c=createLabel(svg,c,p3[1],p3[2],label,s3,nil,'white')
                                        c=createLabel(svg,c,p4[1],p4[2],label,s4,nil,'white')
                                end
                            end
                    end
                    for cG = 1, #customGroups do
                        local customGroup = customGroups[cG]
                        local multiGroups = customGroup[2]
                        local singleGroups = customGroup[3]
                        svg[c] = '<g class="'
                        svg[c+1] = customGroup[1]
                        svg[c+2] = '">'
                        c = c+3
                        for mGC = 1, #multiGroups do
                            local multiGroup = multiGroups[mGC]
                            local pts = multiGroup[1]
                            local tPoints = {}
                            local ct = 1
                            for pC = 1, #pts do
                                local p = pts[pC]
                                local tx,ty,tz = translate(p[1],p[2],p[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                                if tz > 0 then
                                    tPoints[ct] = {tx,ty,tz}
                                    ct = ct + 1
                                end
                            end
                            if ct ~= 1 then
                                local drawFunction = multiGroup[2]
                                local data = multiGroup[3]
                                c = drawFunction(svg, c, object, tPoints, data)
                            end
                        end
                        for sGC = 1, #singleGroups do
                            local singleGroup = singleGroups[sGC]
                            local p = singleGroup[1]
                            local tx, ty, tz = translate(p[1],p[2],p[3],mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
                            if tz > 0 then
                                local drawFunction = singleGroup[2]
                                local data = singleGroup[3]
                                c = drawFunction(svg,c,object,tx,ty,tz,data)
                            end
                        end
                        svg[c] = '</g>'
                        c=c+1
                    end
                    svg[c] = '</g>'
                    c=c+1
                end
                end
            end
            svg[c] = '</g></svg>'
            c = c+1
            end
        end
        return svg, c
    end
    return self
end