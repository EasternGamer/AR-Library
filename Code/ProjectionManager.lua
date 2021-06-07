--[[
This is the heart of the entire program... it's not well commented but here if you really want to take a look.
]]

function Projector(core, camera)
    
    -- Localize frequently accessed data
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
    local getConstructWorldPos = core.getConstructWorldPos
    local getConstructWorldOrientationRight = core.getConstructWorldOrientationRight
    local getConstructWorldOrientationForward = core.getConstructWorldOrientationForward
    local getConstructWorldOrientationUp = core.getConstructWorldOrientationUp
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
    local inverse = manager.inverse
    local multiply = manager.multiply
    local divide = manager.divide
    
    -- Localize Math functions
    local sin, cos, tan = math.sin, math.cos, math.tan
    local rad, deg, sqrt = math.rad, math.deg, math.sqrt
    local atan = math.atan

    -- Projection infomation
    --- Screen Parameters
    local width = getWidth()/2
    local height = getHeight()/2

    --- FOV Paramters
    local hfovRad = rad(getFov());
    local fov = 2*atan(tan(hfovRad/2)*height,width)

    --- Matrix Subprocessing
    local tanFov = tan(fov/2)
    local aspect = width/height
    local near = width/tanFov
    local top = near * tanFov
    local bottom = -top;
    local left = bottom * aspect
    local right = top * aspect

    local near = width/tanFov
    local far = 10000
    local aspect = width/height

    --- Matrix Paramters
    local x0 = 2 * near / (right - left)
    local y0 = 2 * near / (top - bottom)
    local a0 = (right + left) / (right - left)
    local b0 = (top + bottom) / (top - bottom)
    local c0 = -(far + near) / (far - near)
    local d0 = -2 * far * near / (far - near)


    --- What the projection matrix actually looks like.
    ---- a0 is usually 0
    ---- b0 is usually 0
    local projectionMatrix = {
        x0, 0, a0,  0,
        0, y0, b0,  0,
        0,  0, c0, d0,
        0,  0, -1,  0
    }

    -- Player-related values
    local playerId = unit.getMasterPlayerId()
    local unitId = unit.getId()
    local eye = camera.position
    
    -- Camera-Related values
    local camera = camera
    local cOrientation = camera.orientation
    local cameraType = camera.type
    local alignmentType = nil
    
    --- Mouse info
    local sensitivity = 1 -- export: Sensitivtiy
    local m = sensitivity*(width*2)*0.00104584100642898 + 0.00222458611638299
    local bottomLock = false
    local topLock = false
    local rightLock = false
    local leftLock = false

    local self = {}
    local objects = {}
    
    function self.updateProjectionMatrix()
        --- Screen Parameters
        width = getWidth()/2
        height = getHeight()/2

        --- FOV Paramters
        hfovRad = rad(getFov());
        fov = 2*atan(tan(hfovRad/2)*height,width)

        --- Matrix Subprocessing
        tanFov = tan(fov/2)
        aspect = width/height
        near = width/tanFov
        top = near * tanFov
        bottom = -top;
        left = bottom * aspect
        right = top * aspect

        near = width/tanFov
        far = 10000
        aspect = width/height

        --- Matrix Paramters
        x0 = 2 * near / (right - left)
        y0 = 2 * near / (top - bottom)
        a0 = (right + left) / (right - left)
        b0 = (top + bottom) / (top - bottom)
        c0 = -(far + near) / (far - near)
        d0 = -2 * far * near / (far - near)
    
        m = sensitivity*(width*2)*0.00104584100642898 + 0.00222458611638299
    end

    function self.updateCamera()
        if cameraType == "player" then
            
            -- Localize variables
            local atan = atan
            
            eye = getPlayerLocalPos(playerId)

            local deltaMouseY = getMouseDeltaY()
            local deltaMouseX = getMouseDeltaX()
            local width = width
            local deltaPitch = atan(-deltaMouseY/width) * m
            local deltaHeading = atan(deltaMouseX/width) * m
        
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
	function self.addObject(object)
        local index = #objects + 1
        objects[index] = object
        return index
    end

    function self.removeObject(id)
    	objects[id] = {}
    end
    
    function self.getModelMatrices(mObject)
        
        local sin = sin
        local cos = cos
        local multiply = multiply
        local inverse = inverse
        local modelMatrices = {}
        
        -- Localize Object values.
        local obj = mObject
        local objOrientationType = obj.orientationType
        local objOrientation = obj.orientation
        local objPosType = obj.positionType
        local objPos = obj.position
        local objPosX,objPosY,objPosZ = objPos[1],objPos[2],objPos[3]
        
        local cUpDir = getConstructWorldOrientationUp()
        local cUpDirX,cUpDirY,cUpDirZ = cUpDir[1],cUpDir[2],cUpDir[3]
        local cForwd = getConstructWorldOrientationForward()
        local cForwdX,cForwdY,cForwdZ = cForwd[1],cForwd[2],cForwd[3]
        local cRight = getConstructWorldOrientationRight()
        local cRightX,cRightY,cRightZ = cRight[1],cRight[2],cRight[3]
        
        local sx, sy, sz, sw = rotToQuat({
                    cRightX,cRightY,cRightZ,0,
                    cForwdX,cForwdY,cForwdZ,0,
                    cUpDirX,cUpDirY,cUpDirZ,0,
                    0,0,0,1
                })
        
        local recurse = {}
        local c = 2
        function recurse.subObjectMatrices(lx, ly, lz, lw, sObjX, sObjY, sObjZ, object, posLX, posLY, posLZ)
            local posLX, posLY, posLZ = posLX, posLY, posLZ
            local sObjX, sObjY, sObjZ = sObjX, sObjY, sObjZ
            local object = object
            local objPos = object.position
            local objRot = object.orientation
            local objRotType = object.orientationType
            local objX,objY,objZ = objPos[1],objPos[2],objPos[3]
            
            
            local objP,objH,objR = objRot[1] / 2,objRot[2] / 2,objRot[3] / 2
            local sinP,sinH,sinR = sin(objP),sin(objR),sin(objH)
            local cosP,cosH,cosR = cos(objP),cos(objR),cos(objH)
    
            local wwx = (sinP * cosH * cosR - cosP * sinH * sinR)
            local wwy = (cosP * sinH * cosR + sinP * cosH * sinR)
            local wwz = (cosP * cosH * sinR - sinP * sinH * cosR)
            local www = (cosP * cosH * cosR + sinP * sinH * sinR)
            local wx, wy, wz, ww = wwx, wwy, wwz, www
            
            
            local lix, liy, liz, liw = inverse(lx, ly, lz, lw)
            local posTX, posTY, posTZ, posTW = multiply(lx, ly, lz, lw, objX - sObjX, objY - sObjY, objZ - sObjZ, 0)
            local posIX, posIY, posIZ, posIW = multiply(posTX, posTY, posTZ, posTW, lix, liy, liz, liw)
            posIX, posIY, posIZ, posIW = -posIX, posIY, posIZ, posIW
            if object.positionType == "local" then
                local dotX = cRightX*posIX + cForwdX*posIY + cUpDirX*posIZ
                local dotY = cRightY*posIX + cForwdY*posIY + cUpDirY*posIZ
                local dotZ = cRightZ*posIX + cForwdZ*posIY + cUpDirZ*posIZ
                posIX = dotX
                posIY = dotY
                posIZ = dotZ
            end
            posIX, posIY, posIZ = posIX + posLX, posIY + posLY, posIZ + posLZ
            if objRotType == "local" then
                wx, wy, wz, ww = multiply(wx, wy, wz, ww, sx, sy, sz, sw)
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
            
            modelMatrices[c] = {
                object,
                {
                    a1, -d1, -g1, posIX,
                    -b1, e1, h1, -posIY,
                    -c1, f1, i1, -posIZ,
                    0, 0, 0, 1
                }

            }
            c = c + 1
            
            local subObjects = object.subObjects
            if #subObjects > 0 then
                for k = 1, #subObjects do
                    recurse.subObjectMatrices(wwx, wwy, wwz, www, objX, objY, objZ, subObjects[k], posIX, posIY, posIZ)
                end
            end
        end
        local pitch,heading,roll = objOrientation[1] / 2,objOrientation[2] / 2,objOrientation[3] / 2
        
        --- Quaternion of object rotations
        local sinP,sinH,sinR = sin(pitch),sin(roll),sin(heading)
        local cosP,cosH,cosR = cos(pitch),cos(roll),cos(heading)
    
        local wwx = -(sinP * cosH * cosR - cosP * sinH * sinR)
        local wwy = -(cosP * sinH * cosR + sinP * cosH * sinR)
        local wwz = -(cosP * cosH * sinR - sinP * sinH * cosR)
        local www = -(cosP * cosH * cosR + sinP * sinH * sinR)
        local wx, wy, wz, ww = wwx, wwy, wwz, www
        
        
        if objOrientationType == "local" then
            wx, wy, wz, ww = multiply(wx, wy, wz, ww, sx, sy, sz, sw)
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
            local dotX = cRightX*objPosX + cForwdX*objPosY + cUpDirX*objPosZ
            local dotY = cRightY*objPosX + cForwdY*objPosY + cUpDirY*objPosZ
            local dotZ = cRightZ*objPosX + cForwdZ*objPosY + cUpDirZ*objPosZ
            objPosX = dotX
            objPosY = dotY
            objPosZ = dotZ
        else
            local cWorldPos = getTrueWorldPos()
            objPosX = objPosX - cWorldPos[1]
            objPosY = objPosY - cWorldPos[2]
            objPosZ = objPosZ - cWorldPos[3]
        end
        local subObjects = obj.subObjects
        if #subObjects > 0 then
            for k = 1, #subObjects do
                recurse.subObjectMatrices(wwx, wwy, wwz, www,objPos[1], objPos[2], objPos[3], subObjects[k], objPosX, objPosY, objPosZ)
            end
        end
        modelMatrices[1] = {
            obj,
            {
                a2, -d2, -g2, objPosX,
                -b2, e2, h2, -objPosY,
                -c2, f2, i2, -objPosZ,
                0, 0, 0, 1
            }
        }
        return modelMatrices
    end

    function self.getViewMatrix()
        local multiply = multiply
        
        local board = getElementRotationById(unitId)
        local ax,ay,az,aw = board[1],board[2],board[3],board[4]
        
        local body = getRelativeOrientation()
        local bx,by,bz,bw = body[1],body[2],body[3],body[4]

        local vc1 = getConstructWorldOrientationRight()
        local vc2 = getConstructWorldOrientationForward()
        local vc3 = getConstructWorldOrientationUp()
        local vc1t = solve(vc1, vc2, vc3, {1,0,0})
        local vc2t = solve(vc1, vc2, vc3, {0,1,0})
        local vc3t = solve(vc1, vc2, vc3, {0,0,1})
        
        local sx, sy, sz, sw = rotToQuat({
        vc1t[1],vc1t[2],vc1t[3],0,
        vc2t[1],vc2t[2],vc2t[3],0,
        vc3t[1],vc3t[2],vc3t[3],0,
        0,0,0,1})

        local eye = eye
        local eyeX,eyeY,eyeZ = eye[1],eye[2],eye[3]
        local dotX, dotY, dotZ = eyeX, eyeY, eyeZ
        local wx, wy, wz, ww = 0,0,0,1
        local sin = sin
        local cos = cos
        
        local px, py, pz, pw = multiply(ax, ay, az, aw, bx, by, bz, bw)
        local alignment = getAlignmentType(px, py, pz, pw, eyeX, eyeY, eyeZ)
        alignmentType = alignment
        local pix, piy, piz, piw = inverse(px, py, pz, pw)
        local shift = alignment.shift
            
        local eyeTX, eyeTY, eyeTZ, eyeTW = multiply(px, py, pz, pw, shift[1], shift[2], shift[3], 0)
        local eyeIX, eyeIY, eyeIZ, eyeIW = multiply(eyeTX, eyeTY, eyeTZ, eyeTW, pix, piy, piz, piw)
        
        local alignmentName = alignment.name
        local orientation = cOrientation
        local pitch,roll,heading = orientation[1] / 2,0,orientation[2] / 2,0
        if pitch ~= 0 or heading ~= 0 or roll ~= 0 or alignmentName == "fixed" then
            local sinP,sinH,sinR = sin(pitch),sin(roll),sin(heading)
            local cosP,cosH,cosR = cos(pitch),cos(roll),cos(heading)
            
            local cx = (sinP * cosH * cosR - cosP * sinH * sinR)
            local cy = -(cosP * sinH * cosR + sinP * cosH * sinR)
            local cz = -(cosP * cosH * sinR - sinP * sinH * cosR)
            local cw = (cosP * cosH * cosR + sinP * sinH * sinR)
            if alignmentName ~= "fixed" then
                px, py, pz, pw = multiply(px, py, pz, pw, cx, cy, cz, cw)
            else
                wx, wy, wz, ww = cx, cy, cz, cw
            end
        end
        
        if alignmentName ~= "fixed" then
        
            local a1 = 1 - 2*(py*py + pz*pz)
            local b1 = 2*(px*py - pz*pw)
            local c1 = 2*(px*pz + py*pw)
    
            local d1 = 2*(px*py + pz*pw)
            local e1 = 1 - 2*(px*px + pz*pz)
            local f1 = 2*(py*pz - px*pw)
    
            local g1 = 2*(px*pz - py*pw)
            local h1 = 2*(py*pz + px*pw)
            local i1 = 1 - 2*(px*px + py*py)
            eyeX = eyeX - eyeIX
            eyeY = eyeY + eyeIY
            eyeZ = eyeZ + eyeIZ
        
            dotX = a1*eyeX + (-d1)*eyeY + (-g1)*eyeZ
            dotY = (-b1)*eyeX + e1*eyeY + (h1)*eyeZ
            dotZ = (-c1)*eyeX + (f1)*eyeY + i1*eyeZ
            wx, wy, wz, ww = multiply(sx, sy, sz, sw, px, py, pz, pw)
        end
        -- Camera rotation determination
        --- Directly input euler angles in radians
        
        local wxwx = wx*wx
        local wxwy = wx*wy
        local wxwz = wx*wz
        local wxww = wx*ww
        
        local wywy = wy*wy
        local wywz = wy*wz
        local wyww = wy*ww
        
        local wzwz = wz*wz
        local wzww = wz*ww
        
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

        return { -- View Matrix
                a2, -d2, -g2, dotX,
                -b2, e2, h2, dotY,
                -c2, f2, i2, dotZ,
                0, 0, 0, 1}
    
    end
	    
    function self.getSVG()
        local svg = {  }
        local c = 1

        local view = self.getViewMatrix()

        local vx1,vy1,vz1,vw1 = view[1],view[2],view[3],view[4]
        local vx2,vy2,vz2,vw2 = view[5],view[6],view[7],view[8]
        local vx3,vy3,vz3,vw3 = view[9],view[10],view[11],view[12]

        local masterXX,masterXY,masterXZ,masterXW = 0,0,0,0
        local masterYX,masterYY,masterYZ,masterYW = 0,0,0,0
        local masterZX,masterZY,masterZZ,masterZW = 0,0,0,0
        
        local function translate(x, y, z)
            local x,y,z = x,y,z

            local px = masterXX * x + masterXY * y + masterXZ * z + masterXW
            local py = masterYX * x + masterYY * y + masterYZ * z + masterYW
            local pz = masterZX * x + masterZY * y + masterZZ * z + masterZW
            local pw = -py
                
            -- Convert to window coordinates after W-Divide
            local wx = (px / pw) * width
            local wy = (pz / pw) * height
            return wx, wy, pw
        end
        
        -- Localize projection matrix values
        local px1 = x0
        local py2 = 1 --c0
        local pz3 = y0
        
        -- Localize screen info
        local width = width
        local height = height

        for i = 1, #objects do
            
            local object = objects[i]
            svg[c] = [[<svg viewBox="0 0 ]]
            svg[c + 1] = width*2
            svg[c + 2] = [[ ]]
            svg[c + 3] = height*2
            svg[c + 4] = [[" class="]]
            svg[c + 5] = object.style
            svg[c + 6] = '"><g transform="translate('
            svg[c + 7] = width
            svg[c + 8] = ','
            svg[c + 9] = height
            svg[c + 10] = ')">'
            c = c + 11
            local models = self.getModelMatrices(object)
            
            -- Localize model matrix values
            for k = 1, #models do
                local modelObj = models[k]
                local object = modelObj[1]
                local model = modelObj[2]
                
                local mx1,my1,mz1,mw1 = model[1],model[2],model[3],model[4]
                local mx2,my2,mz2,mw2 = model[5],model[6],model[7],model[8]
                local mx3,my3,mz3,mw3 = model[9],model[10],model[11],model[12]
            
                masterXX = px1*(vx1*mx1 + vy1*mx2 + vz1*mx3)
                masterXY = px1*(vx1*my1 + vy1*my2 + vz1*my3)
                masterXZ = px1*(vx1*mz1 + vy1*mz2 + vz1*mz3)
                masterXW = px1*(vw1 + vx1*mw1 + vy1*mw2 + vz1*mw3)
        
                masterYX = (vx2*mx1 + vy2*mx2 + vz2*mx3)
                masterYY = (vx2*my1 + vy2*my2 + vz2*my3)
                masterYZ = (vx2*mz1 + vy2*mz2 + vz2*mz3)
                masterYW = (vw2 + vx2*mw1 + vy2*mw2 + vz2*mw3)
        
                masterZX = pz3*(vx3*mx1 + vy3*mx2 + vz3*mx3)
                masterZY = pz3*(vx3*my1 + vy3*my2 + vz3*my3)
                masterZZ = pz3*(vx3*mz1 + vy3*mz2 + vz3*mz3)
                masterZW = pz3*(vw3 + vx3*mw1 + vy3*mw2 + vz3*mw3)

                local polylineGroups = object.polylineGroups
                local circleGroups = object.circleGroups
                local curvesGroups = object.curvesGroups
                local customGroups = object.customGroups
            
                -- Polylines for-loop
                for d = 1, #polylineGroups do
                    local polylineGroup = polylineGroups[d]
                    svg[c] = '<path class="'
                    svg[c + 1] = polylineGroup[1]
                    svg[c + 2] = '" d="'
                    c = c + 3
                    for f = 2, #polylineGroup do
                        local line = polylineGroup[f]
                        svg[c] = 'M '
                        local lineCount = 0
                        local startPoint = {}
                        local endPoint = {}
                        c = c + 1
                        for h = 1, #line do
                            local point = line[h]
                            local wx, wy, ww = translate(point[1],point[2],point[3])

                            -- If PW is negative, it means the point is behind you
                            if ww > 0 then
                                if lineCount ~= 0 then
                                    svg[c] = ' L '
                                    c = c + 1
                                    endPoint = {wx, wy}
                                else
                                    startPoint = {wx, wy}
                                end
                                svg[c] = wx
                                svg[c + 1] = ' '
                                svg[c + 2] = wy
                                c = c + 3
                                lineCount = lineCount + 1
                            end
                        end
                        if lineCount < 2 then
                            if lineCount == 1 then
                                svg[c - 4] = ''
                                svg[c - 3] = ''
                                svg[c - 2] = ''
                                svg[c - 1] = ''
                                c = c - 4
                            else
                                svg[c - 1] = ''
                                c = c - 1
                            end
                        else
                            if endPoint[1] == startPoint[1] and endPoint[2] == startPoint[2] then
                                svg[c - 4] = ' Z '
                                svg[c - 3] = ''
                                svg[c - 2] = ''
                                svg[c - 1] = ''
                                c = c - 3
                            end
                        end
                    end
                    svg[c] = '"/>'
                    c = c + 1
                end
                for cG = 1, #circleGroups do
                    local circleGroup = circleGroups[cG]
                    svg[c] = '<g class="'
                    svg[c + 1] = circleGroup[1]
                    svg[c + 2] = '">'
                    c = c + 3
                    for l = 2, #circleGroup do
                        local circle = circleGroup[l]
                        local point = circle[1]
            
                        local wx, wy, wz = translate(point[1],point[2],point[3])

                        -- If PW is negative, it means the point is behind you
                        if wz > 0 then
                            local radius = circle[2]
                            local fill = circle[3]
                            local label = circle[4]
                            local action = circle[5]
                            svg[c] = '<circle cx="'
                            svg[c+1] = wx
                            svg[c+2] = '" cy="'
                            svg[c+3] = wy
                            svg[c+4] = '" r="'
                            svg[c+5] = radius
                            svg[c+6] = '" fill="'
                            svg[c+7] = fill
                            svg[c+8] = '"/>'
                            c = c + 9
                            if label ~= nil then
                                svg[c] = '<text x="'
                                svg[c+1] = wx
                                svg[c+2] = '" y="'
                                svg[c+3] = wy
                                svg[c+4] = '">'
                                svg[c+5] = label
                                svg[c+6] = '</text>'
                                c = c + 7
                            end
                            if action ~= nil then
                                svg, c = action(svg, c, object, wx, wy, wz)
                            end
                        end
                    end
                    svg[c] = '</g>'
                    c = c + 1
                end
                for cG = 1, #customGroups do
                    local customGroup = customGroups[cG]
                    local multiGroups = customGroup[2]
                    local singleGroups = customGroup[3]
                    svg[c] = '<g class="'
                    svg[c + 1] = customGroup[1]
                    svg[c + 2] = '">'
                    c = c + 3
                    for mGC = 1, #multiGroups do
                        local multiGroup = multiGroups[mGC]
                        local points = multiGroup[1]
                        local tPoints = {}
                        local count = 1
                        for pCount = 1, #points do
                            local point = points[pCount]
                            local tx, ty, tz = translate(point[1],point[2],point[3])
                            if tz > 0 then
                                tPoints[count] = {tx, ty, tz}
                                count = count + 1
                            end
                        end
                        if count ~= 1 then
                            local drawFunction = multiGroup[2]
                            local data = multiGroup[3]
                            svg, c = drawFunction(svg, c, object, tPoints, data)
                        end
                    end
                    for sGC = 1, #singleGroups do
                        local singleGroup = singleGroups[sGC]
                        local point = singleGroup[1]
                        local tx, ty, tz = translate(point[1],point[2],point[3])
                        if tz > 0 then
                            local drawFunction = singleGroup[2]
                            local data = singleGroup[3]
                            svg, c = drawFunction(svg, c, object, tx, ty, tz, data)
                        end
                    end
                    svg[c] = '</g>'
                    c = c + 1
                end
            end
            svg[c] = '</g></svg>'
            c = c + 1
        end
        return svg, (c)
    end
    return self
end