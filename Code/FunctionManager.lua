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