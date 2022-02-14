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

local TEXT_ARRAY = {
    [10] = {{}, 16,'',10},--new line
    [32] = {{}, 10,'',32}, -- space
    [33] = {{4, 0, 3, 2, 5, 2, 4, 4, 4, 12}, 10, 'M%g %gL%g %gL%g %gZ M%g %gL%g %g',33}, -- !
    [34] = {{2, 10, 2, 6, 6, 10, 6, 6}, 6,'M%g %gL%g %g M%g %gL%g %g',34}, -- "
    [35] = {{0, 4, 8, 4, 6, 2, 6, 10, 8, 8, 0, 8, 2, 10, 2, 2},  10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',35}, -- #
    [36] = {{6, 2, 2, 6, 6, 10, 4, 12, 4, 0}, 6,'M%g %gL%g %gL%g %g M%g %gL%g %g',36}, --$
    [37] = {{0, 0, 8, 12, 2, 10, 2, 8, 6, 4, 6, 2}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',37}, -- %
    [38] = {{8, 0, 4, 12, 8, 8, 0, 4, 4, 0, 8, 4}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',38}, --&
    [39] = {{0, 8, 0, 12}, 2,'M%g %gL%g %g',39}, --'
    
    [40] = {{6, 0, 2, 4, 2, 8, 6, 12}, 8,'M%g %gL%g %gL%g %gL%g %g',40}, --(
    [41] = {{2, 0, 6, 4, 6, 8, 2, 12}, 8,'M%g %gL%g %gL%g %gL%g %g',41}, --)
    [42] = {{0, 0, 4, 12, 8, 0, 0, 8, 8, 8, 0, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',42}, --*
    [43] = {{1, 6, 7, 6, 4, 9, 4, 3}, 10,'M%g %gL%g %gM%g %gL%g %g',43}, -- +
    [44] = {{-1, -2, 1, 1}, 4,'M%g %gL%g %g',44}, -- ,
    [45] = {{2, 6, 6, 6}, 10,'M%g %gL%g %g',45}, -- -
    [46] = {{0, 0, 1, 0}, 3,'M%g %gL%g %g',46}, -- .
    [47] = {{0, 0, 8, 12}, 10,'M%g %gL%g %g',47}, -- /
    [48] = {{0, 0, 8, 0, 8, 12, 0, 12, 0, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',48}, -- 0
    [49] = {{5, 0, 5, 12, 3, 10}, 10,'M%g %gL%g %gL%g %g',49}, -- 1

    
    [50] = {{0, 12, 8, 12, 8, 7, 0, 5, 0, 0, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',50}, -- 2
    [51] = {{0, 12, 8, 12, 8, 0, 0, 0, 0, 6, 8, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',51}, -- 3
    [52] = {{0, 12, 0, 6, 8, 6, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',52}, -- 4
    [53] = {{0, 0, 8, 0, 8, 6, 0, 7, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',53}, -- 5
    [54] = {{0, 12, 0, 0, 8, 0, 8, 5, 0, 7}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',54}, -- 6
    [55] = {{0, 12, 8, 12, 8, 6, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %g',55}, -- 7
    [56] = {{0, 0, 8, 0, 8, 12, 0, 12, 0, 6, 8, 6}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',56}, -- 8
    [57] = {{8, 0, 8, 12, 0, 12, 0, 7, 8, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',57}, -- 9
    [58] = {{4, 9, 4, 7, 4, 5, 4, 3}, 2,'M%g %gL%g %g M%g %gL%g %g',58}, -- :
    [59] = {{4, 9, 4, 7, 4, 5, 1, 2}, 5,'M%g %gL%g %g M%g %gL%g %g',59}, -- ;
    
    [60] = {{6, 0, 2, 6, 6, 12}, 6,'M%g %gL%g %gL%g %g',60}, -- <
    [61] = {{1, 4, 7, 4, 1, 8, 7, 8}, 8,'M%g %gL%g %g M%g %gL%g %g',61}, -- =
    [62] = {{2, 0, 6, 6, 2, 12}, 6,'M%g %gL%g %gL%g %g',62}, -- >
    [63] = {{0, 8, 4, 12, 8, 8, 4, 4, 4, 1, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',63}, -- ?
    [64] = {{8, 4, 4, 0, 0, 4, 0, 8, 4, 12, 8, 8, 4, 4, 3, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',64}, -- @
    [65] = {{0, 0, 0, 8, 4, 12, 8, 8, 8, 0, 0, 4, 8, 4}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',65}, -- A
    [66] = {{0, 0, 0, 12, 4, 12, 8, 10, 4, 6, 8, 2, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gZ',66}, --B
    [67] = {{8, 0, 0, 0, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',67}, -- C
    [68] = {{0, 0, 0, 12, 4, 12, 8, 8, 8, 4, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gZ',68}, -- D 
    [69] = {{8, 0, 0, 0, 0, 12, 8, 12, 0, 6, 6, 6}, 10, 'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',69}, -- E
    
    
    [70] = {{0, 0, 0, 12, 8, 12, 0, 6, 6, 6}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',70}, -- F
    [71] = {{6, 6, 8, 4, 8, 0, 0, 0, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',71}, -- G
    [72] = {{0, 0, 0, 12, 0, 6, 8, 6, 8, 12, 8, 0}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',72}, -- H
    [73] = {{0, 0, 8, 0, 4, 0, 4, 12, 0, 12, 8, 12}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',73}, -- I
    [74] = {{0, 4, 4, 0, 8, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',74}, -- J
    [75] = {{0, 0, 0, 12, 8, 12, 0, 6, 6, 0}, 10,'M%g %gL%g %g M%g %gL%g %gL%g %g',75}, -- K
    [76] = {{8, 0, 0, 0, 0, 12}, 10,'M%g %gL%g %gL%g %g',76}, -- L
    [77] = {{0, 0, 0, 12, 4, 8, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',77}, -- M
    [78] = {{0, 0, 0, 12, 8, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',78}, -- N
    [79] = {{0, 0, 0, 12, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gZ',79}, -- O
    
    [80] = {{0, 0, 0, 12, 8, 12, 8, 6, 0, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',80}, -- P
    [81] = {{0, 0, 0, 12, 8, 12, 8, 4, 4, 4, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',81}, -- Q
    [82] = {{0, 0, 0, 12, 8, 12, 8, 6, 0, 5, 4, 5, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',82}, -- R
    [83] = {{0, 2, 2, 0, 8, 0, 8, 5, 0, 7, 0, 12, 6, 12, 8, 10}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',83}, -- S
    [84] = {{0, 12, 8, 12, 4, 12, 4, 0}, 10,'M%g %gL%g %g M%g %gL%g %g',84}, -- T
    [85] = {{0, 12, 0, 2, 4, 0, 8, 2, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',85}, -- U
    [86] = {{0, 12, 4, 0, 8, 12}, 10,'M%g %gL%g %gL%g %g',86}, -- V
    [87] = {{0, 12, 2, 0, 4, 4, 6, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',87}, -- W
    [88] = {{0, 0, 8, 12, 0, 12, 8, 0}, 10,'M%g %gL%g %g M%g %gL%g %g',88}, -- X
    [89] = {{0, 12, 4, 6, 8, 12, 4, 6, 4, 0}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',89}, -- Y
    
    [90] = {{0, 12, 8, 12, 0, 0, 8, 0, 2, 6, 6, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',90}, -- Z
    [91] = {{6, 0, 2, 0, 2, 12, 6, 12}, 6,'M%g %gL%g %gL%g %gL%g %g',91}, -- [
    [92] = {{0, 12, 8, 0}, 10,'M%g %gL%g %g',92}, -- \
    [93] = {{2, 0, 6, 0, 6, 12, 2, 12}, 6,'M%g %gL%g %gL%g %gL%g %g',93}, -- ]
    [94] = {{2, 6, 4, 12, 6, 6}, 6,'M%g %gL%g %gL%g %g',94}, -- ^
    [95] = {{0, 0, 8, 0}, 10,'M%g %gL%g %g',95}, -- _
    [96] = {{2, 12, 6, 8}, 6,'M%g %gL%g %g',96}, -- `
    
    [123] = {{6, 0, 4, 2, 4, 10, 6, 12, 2, 6, 4, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',123}, -- {
    [124] = {{4, 0, 4, 5, 4, 6, 4, 12}, 6,'M%g %gL%g %g M%g %gL%g %g',124}, -- |
    [125] = {{4, 0, 6, 2, 6, 10, 4, 12, 6, 6, 8, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',125}, -- }
    [126] = {{0, 4, 2, 8, 6, 4, 8, 8}, 10,'M%g %gL%g %gL%g %gL%g %g',126}, -- ~
}

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
            local sC=sC+1
            local outArr = {false,false,false,false,false,false}
            singlePoint[sC]= outArr
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
    function self.setUIElements(style, groupId)
        groupId = groupId or 1
        local sqrt,s,c,remove,unpack = math.sqrt, math.sin, math.cos, table.remove,table.unpack

        local function createNormal(points, rx, ry, rz, rw)
            if #points < 3 then
                print("Invalid Point Set!")
                do
                    return
                end
            end
            return 2*(rx*ry-rz*rw),1-2*(rx*rx+rz*rz),2*(ry*rz+rx*rw)
        end
        local function createBounds(pointsX,pointsY)
            
            local size = #pointsX
            if size >= 60 then
                return false
            end
            return {{unpack(pointsX)},{unpack(pointsY)}}
        end
        
        local elements = {}
        local modelElements = {}
        local elementClasses = {}
        local selectedElement = false
        
        local group = {style, elements, selectedElement,modelElements}

        self[6][groupId] = group

        local self = {}
        local pC, eC = 0, 0

        local function createUITemplate(x,y,z)
            
            local user = {}
            local raw = {}
            
            local huge = math.huge
            local maxX,minX,maxY,minY = -huge,huge,-huge,huge
            
            local pointSetX,pointSetY = {},{}
            local actions = {false,false,false,false,false,false,false}
            local mainRotation = {0,0,0,1}
            local resultantPos = {x,y+rand()*0.000001,z}
            local mRot = RotationHandler(mainRotation,resultantPos)
            
            --system.print(string.format('UI Create {%.2f,%.2f,%.2f}', resultantPos[1],resultantPos[2],resultantPos[3]))
            local elementData = {false, false, false, actions, false, true, false, false, pointSetX, pointSetY, resultantPos, false,false,false,false, mainRotation,mRot}
            local subElements = {}
            local elementIndex = eC + 1
            elements[elementIndex] = elementData
            eC = elementIndex
           
            function user.addSubElement(element)
                local index = #subElements + 1
                if element then
                    subElements[index] = element
                    mRot.addSubRotation(element.getRotationManager())
                end
                return index
            end
            function user.removeSubElement(index)
                remove(subElements, index)
            end
            function user.getId()
                return elementIndex
            end
            function elementData.getId()
                return elementIndex
            end
            local function handleBound(x,y)
                if x > maxX then
                    maxX = x
                end
                if x < minX then
                    minX = x
                end
                if y > maxY then
                    maxY = y
                end
                if y < minY then
                    minY = y
                end
            end
            function user.addPoint(x,y)
                local pC = #pointSet+1
                if x and y then
                    handleBound(x,y)
                    pointSetX[pC] = x
                    pointSetY[pC] = y
                else
                    if type(x) == 'table' and #x > 0 then
                        local x,y = x[1], x[2]
                        handleBound(x,y)
                        pointSetX[pC] = x
                        pointSetY[pC] = y
                    else
                        print('Invalid format for point.')
                    end
                end
            end
            function user.addPoints(points,override)
                local pntsX,pntsY
                if override then
                    pntsX,pntsY = {},{}
                    elementData[9],elementData[10] = pntsX,pntsY
                    pointSetX,pointSetY = pntsX,pntsY
                else
                    pntsX,pntsY = elementData[9],elementData[10]
                    pointSetX,pointSetY = pntsX,pntsY
                end
                if points then
                    local pointCount = #points
                    if pointCount > 0 then
                        local pType = type(points[1])
                        if pType == 'number' then
                            local startIndex = #pntsX
                            for i = 1, pointCount,2 do
                                local index = startIndex + i
                                
                                local x,y = points[i],points[i+1]
                                handleBound(x,y)
                                
                                pntsX[index] = x
                                pntsY[index] = y
                            end
                        elseif pType == 'table' then
                            
                            local startIndex = #pntsX
                            for i = 1, pointCount do
                                local index = startIndex + i
                                
                                local point = points[i]
                                local x,y = point[1],point[2]
                                handleBound(x,y)
                                
                                pntsX[index] = x
                                pntsY[index] = y
                            end
                        else
                            print('No compatible format found.')
                        end
                    end
                end
            end
                
            function user.getRotationManager()
                return mRot
            end
            
            local function updateNormal()
                if elementData[15] then
                    user.setNormal(createNormal(pointSetX, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4]))
                end
            end
            
            mRot.assignFunctions(user, updateNormal)

            local function drawChecks()
                local defaultDraw = elementData[2]
                if defaultDraw then
                    if not elementData[3] then
                        elementData[3] = elementData[2]
                    end
                    if not elementData[1] then
                        elementData[1] = elementData[2]
                    end
                end
            end
            local function actionCheck()
                actions[7] = true
            end
            
            function user.setHoverDraw(hDraw) elementData[1] = hDraw; drawChecks() end
            function user.setDefaultDraw(dDraw) elementData[2] = dDraw; drawChecks() end
            function user.setClickDraw(cDraw) elementData[3] = cDraw; drawChecks() end
            
            function user.setClickAction(action) actions[1] = action; actionCheck() end
            function user.setHoldAction(action) actions[2] = action; actionCheck() end
            function user.setEnterAction(action) actions[3] = action; actionCheck() end
            function user.setLeaveAction(action) actions[4] = action; actionCheck() end
            function user.setHoverAction(action) actions[5] = action; actionCheck() end
            function user.setIdentifier(identifier) actions[6] = identifier; end
            
            function user.setScale(scale) 
                elementData[5] = scale
            end
            
            function user.getMaxValues()
                return maxX,minX,maxY,minY
            end
            
            function user.hide() elementData[6] = false end
            function user.show() elementData[6] = true end
            function user.isShown() return elementData[6] end  
            
            function user.remove() 
                remove(elements,elementIndex)
                remove(elementClasses,elementIndex)
                for i = elementIndex, eC do
                    elementClasses[i].setElementIndex(i)
                end
            end
            local psX,psY = 0,0
            function user.move(sx,sy,indices,updateHitbox)
                if not indices then
                    for i = 1, #pointSet do
                        pointSetX[i] = pointSetX[i] - psX + sx
                        pointSetY[i] = pointSetY[i] - psY + sy
                    end
                    maxX,minX,maxY,minY = maxX+sx,minX+sx,maxY+sy,minY+sy
                else
                    for i=1,#indices do
                        local index = indices[i]
                        pointSetX[index] = pointSetX[index] - psX + sx
                        pointSetY[index] = pointSetY[index] - psY + sy
                    end
                    -- TODO: Check min-max values and update accordingly
                end
                psX = sx
                psY = sy
                
                if updateHitbox then
                    user.setBounds(createBounds(pointSetX))
                end
            end
            local ogPointSetX,ogPointSetY
            function user.moveTo(sx,sy,indices,updateHitbox,useOG)
                if not indices then
                    print('ERROR: No indices specified!')
                else
                    if not ogPointSetX then
                        ogPointSetX = {table.unpack(pointSetX)}
                        ogPointSetY = {table.unpack(pointSetY)}
                    end
                    for i=1,#indices do
                        local index = indices[i]
                        if not useOG then
                            pointSetX[index] = sx
                            pointSetY[index] = sy
                        else
                            pointSetX[index] = ogPointSetX[index] + sx
                            pointSetY[index] = ogPointSetY[index] + sy
                        end
                    end
                end
                if updateHitbox then
                    user.setBounds(createBounds(pointSetX,pointSetY))
                end
            end
            
            function user.setDrawOrder(indices)
                local drawOrder = {}
                for i=1, #indices do
                    local index = indices[i]
                    
                    local order = drawOrder[index]
                    if not order then
                        order = {}
                        drawOrder[index] = order
                    end
                    order[#order+1] = i
                end
                elementData[7] = drawOrder
            end
            
            function user.setDrawData(drawData) elementData[8] = drawData end
            function user.getDrawData() return elementData[8] end
            function user.setSizes(sizes) 
                if not elementData[8] then
                     elementData[8] = {['sizes'] = sizes}
                else
                    elementData[8].sizes = sizes
                end
            end
            function user.getDrawOrder() return elementData[7] end
            
            function user.getPoints() return elementData[9],elementData[10] end
            
            function user.setDrawOrder(drawOrder) elementData[7] = drawOrder end
            function user.setDrawData(drawData) elementData[8] = drawData end
            
            function user.setPoints(pointsX,pointsY) 
                if not pointsY then 
                    user.addPoints(pointsX,true)
                else
                    pointSetX,pointSetY = pointsX,pointsY
                    elementData[9],elementData[10] = pointsX,pointsY
                end
            end
            
            function user.setElementIndex(eI) elementIndex = eI end
            function user.getElementIndex(eI) return elementIndex end
            
            function user.setNormal(nx,ny,nz)
                elementData[12] = nx
                elementData[13] = ny
                elementData[14] = nz
            end
            
            function user.setBounds(bounds)
                elementData[15] = bounds
            end
            
            function user.build(force, hasBounds)
                
                local nx, ny, nz = createNormal(pointSetX, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4])
                if nx then
                    if elementData[2] then
                        user.setNormal(nx,ny,nz)
                        if not force then
                            if hasBounds or hasBounds == nil then
                                user.setBounds(createBounds(pointSetX,pointSetY))
                            else
                                user.setBounds(false)
                            end
                        end
                    else
                        print("Element Malformed: No default draw.")
                    end
                else
                    print("Element Malformed: Insufficient points.")
                end
            end
            return user, elementData
        end

        function self.createText(tx, ty, tz)
            local concat,byte,upper = table.concat,string.byte,string.upper
            
            local userFunc, textArr = createUITemplate(tx, ty, tz)
            
            local textCache,offsetCacheX,offsetCacheY,txt = {},{},0,''
            local drawData = {['sizes']={0.08333333333},'white',1}
            local alignmentX,alignmentY = 'middle','middle'
            local wScale = 1
            local mx,my = 0,0
            local maxX,minX,maxY,minY = userFunc.getMaxValues()
            
            userFunc.setDrawData(drawData)
            
            function userFunc.getMaxValues()
                return maxX,minX,maxY,minY
            end
            function userFunc.getText()
                return txt
            end
            local function buildTextCache(text)
                txt = text
                local result = {byte(upper(text), 1, #text)}
                textCache = {}
                for k = 1, #result do
                    local charCode = result[k]
                    textCache[k] = TEXT_ARRAY[charCode]
                end
            end
            local function buildOffsetCache()
                offsetCacheX = {0}
                local offsetXCounter = 1
                local tmpX,tmpY = 0,0
                local fontSize = drawData.sizes[1] / wScale
                
                for k = 1, #textCache do
                    local char = textCache[k]
                    if char[4] == 10 then
                        tmpY = tmpY + char[2] * fontSize
                        if alignmentX == "middle" then
                            tmpX = -tmpX * 0.5
                        elseif alignmentX == "end" then
                            tmpX = -tmpX
                        elseif alignmentX == "start" then
                            tmpX = 0
                        end
                        offsetCacheX[offsetXCounter] = tmpX
                        offsetXCounter = offsetXCounter + 1
                        tmpX = 0
                    else
                        tmpX = tmpX + char[2] * fontSize
                    end
                end
                if alignmentX == "middle" then
                    tmpX = -tmpX * 0.5
                elseif alignmentX == "end" then
                    tmpX = -tmpX
                elseif alignmentX == "start" then
                    tmpX = 0
                end
                if alignmentY == 'middle' then
                    tmpY = tmpY + 12 * fontSize
                    offsetCacheY = -tmpY * 0.5
                elseif alignmentY == 'top' then
                    tmpY = tmpY + 12 * fontSize
                    offsetCacheY = -tmpY
                elseif alignmentY == 'bottom' then
                    offsetCacheY = 0
                end
                offsetCacheX[offsetXCounter] = tmpX
            end
            
            local function handleBound(x,y)
                if x > maxX then
                    maxX = x
                end
                if x < minX then
                    minX = x
                end
                if y > maxY then
                    maxY = y
                end
                if y < minY then
                    minY = y
                end
            end
            
            local function buildPoints()
                local offsetY = offsetCacheY
                local woffsetX,offsetXCounter = offsetCacheX[1],1
                local fontSize = drawData.sizes[1] / wScale

                local pointsX,pointsY,drawStrings = {},{},{'<path stroke-width="%gpx" stroke="%s" stroke-opacity="%g" fill="none" d="'}
                local count = 1
                
                local textCacheSize = #textCache
                
                for k = 1, textCacheSize do
                    local char = textCache[k]
                    drawStrings[k + 1] = char[3]
                    
                    local charPoints, charSize = char[1], char[2]
                    for m = 1, #charPoints, 2 do
                        local x,y = charPoints[m] * fontSize + woffsetX + mx, charPoints[m + 1] * fontSize + offsetY + my
                        
                        handleBound(x,y)
                        
                        pointsX[count] = x
                        pointsY[count] = y
                        count = count + 1
                    end
                    woffsetX = woffsetX + charSize * fontSize
                    if char[4] == 10 then
                        offsetXCounter = offsetXCounter + 1
                        woffsetX = offsetCacheX[offsetXCounter]
                        offsetY = offsetY - charSize * fontSize
                    end
                end

                drawStrings[textCacheSize+2] = '"/>'
                local d = concat(drawStrings)
                userFunc.setDefaultDraw(d)
                userFunc.setClickDraw(d)
                userFunc.setPoints(pointsX,pointsY)
            end
            
            function userFunc.setText(text)
                buildTextCache(text)
                buildOffsetCache()
                
                buildPoints()
            end
            
            function userFunc.setWeight(scale)
                local sizes = drawData.sizes
                sizes[1] = sizes[1] / wScale
                wScale = scale or wScale
                sizes[1] = sizes[1] * wScale
                if #textCache > 0 then
                    buildPoints()
                end
            end
            local oldUserFunc = userFunc.move
            function userFunc.move(x,y)
                mx = mx + x
                my = my + y
                oldUserFunc(x,y)
            end
            function userFunc.setFontSize(size)
                local sizes = drawData.sizes
                sizes[1] = size * 0.08333333333
                if #textCache > 0 then
                    buildOffsetCache()
                    buildPoints()
                end
            end
            function userFunc.setAlignmentX(alignX)
                alignmentX = alignX
                if #textCache > 0 then
                    buildOffsetCache()
                    buildPoints()
                end
            end
            function userFunc.setAlignmentY(alignY)
                alignmentY = alignY
                if #textCache > 0 then
                    buildOffsetCache()
                    buildPoints()
                end
            end
            function userFunc.setFontColor(color)
                drawData[1] = color
            end
            function userFunc.setOpacity(opacity)
                drawData[2] = opacity
            end
            
            return userFunc,textTemplate
        end

        function self.createButton(bx, by, bz)
            local userFunc,button = createUITemplate(bx, by, bz)
            local txtFuncs
            function userFunc.setText(text,rx, ry, rz)
                rx,ry,rz = rx or 0, ry or -0.01, rz or 0
                if not txtFuncs then
                    txtFuncs = self.createText(bx+rx, by+ry, bz+rz)
                    userFunc.addSubElement(txtFuncs)
                else
                    txtFuncs.setPosition(bx+rx, by+ry, bz+rz)
                end
                local maxX,minX,maxY,minY = userFunc.getMaxValues()
                local cheight = maxY-minY
                local cwidth = maxX-minX
                txtFuncs.setText(text)
                
                local tMaxX,tMinX,tMaxY,tMinY = txtFuncs.getMaxValues()
                local theight = tMaxY-tMinY
                local twidth = tMaxX-tMinX
                local r1,r2 = theight/cheight,twidth/cwidth
                if r1 < r2 then
                    local size = theight/r2
                    txtFuncs.setFontSize((size)*0.75)
                else
                    local size = theight/r1
                    txtFuncs.setFontSize((size)*0.75)
                end
                return txtFuncs
            end
            return userFunc
        end
        
        function self.createProgressBar(ex, ey, ez)
            
            local userFuncOut,outline = createUITemplate(ex, ey, ez)
            local userFuncFill,fill = createUITemplate(0, 0, 0)
            userFuncFill.setPositionIsRelative(true)
            userFuncOut.addSubElement(userFuncFill)

            local sPointIndices = {}
            local ePointIndices = {}
            local intervals = {}
            local progress = 100
            
            function userFuncOut.getIntervals()
                return intervals
            end
            
            function userFuncOut.getProgress(pX)
                local points = userFuncFill.getPoints()
                if pX then
                    local c = intervals[1]
                    local xC = c[1]
                    
                    local prog = (pX - points[sPointIndices[1]])/xC
                    if prog < 0 then 
                        return 0.001 
                    elseif prog > 100 then 
                        return 100 
                    else 
                        return prog 
                    end
                end
                return progress
            end
            
            local function makeIntervals()
                
                local sPCount = #sPointIndices
                local ePCount = #ePointIndices
                
                local pointsX,pointsY = userFuncFill.getPoints()
                if #pointsX > 0 then
                    if sPCount == ePCount and sPCount > 0 then
                        for i=1, sPCount do
                            local sPI = sPointIndices[i]
                            local ePI = ePointIndices[i]
                            local xChangePercent = (pointsX[ePI]-pointsX[sPI]) * 0.01
                            local yChangePercent = (pointsY[ePI]-pointsY[sPI]) * 0.01
                            intervals[i] = {xChangePercent,yChangePercent}
                        end
                    end
                end
            end
            
            function userFuncOut.setStartIndices(indices)
                sPointIndices = indices
                makeIntervals()
            end
            
            function userFuncOut.setEndIndices(indices)
                ePointIndices = indices
                makeIntervals()
            end
            
            local addPointsOld = userFuncOut.addPoints
            function userFuncOut.addPoints(points)
                addPointsOld(points)
                makeIntervals()
            end
            
            function userFuncOut.setProgress(prog)
                progress = prog or 0
                if progress < 0 then
                    progress = 0
                end
                if progress > 100 then
                    progress = 100
                end
                local pointsX,pointsY = userFuncFill.getPoints()
                for i=1, #ePointIndices do
                    local c = intervals[i]
                    local sPI = sPointIndices[i]
                    local ePI = ePointIndices[i]
                    pointsX[ePI] = pointsX[sPI] + c[1] * progress
                    pointsY[ePI] = pointsY[sPI] + c[2] * progress
                end
            end
            function userFuncOut.setFillPoints(points)
                userFuncFill.addPoints(points)
            end
            function userFuncOut.getFillDrawData()
               return userFuncFill.getDrawData() 
            end
            function userFuncOut.setFillDrawData(drawData)
                userFuncFill.setDrawData(drawData)
            end
            function userFuncOut.setFillDraw(draw)
                userFuncFill.setDefaultDraw(draw)
            end
            function userFuncOut.setFillOffsetPosition(tx,ty,tz)
                userFuncFill.setPosition(tx,ty,tz)
            end
            
            return userFuncOut
        end
        self.createCustomDraw = createUITemplate
        
        local mElementIndex = 0
        function self.create3DObject(x,y,z)
            local userFunc = {}
            local pointSet = {{},{},{},{}}
            local drawStrings = {}
            local faces = {}
            
            local actions = {false,false,false,false,false,false}
            local elementData = {is3D = true, false, false, false, actions, false, true, false, false, pointSet, x, y, z,faces}
            local eC = mElementIndex + 1
            mElementIndex = eC
            local mElementIndex = eC
            modelElements[eC] = elementData
            
            function userFunc.addPoints(points,ref)
                local pntX,pntY,pntZ,rotation = pointSet[1],pointSet[2],pointSet[3],pointSet[4]
                local s1,s2 = #pntX, #points
                local total = s1+s2
                pntX[total] = false
                pntY[total] = false
                pntZ[total] = false
                
                for i=s1+1, total do
                    local pnt = points[i]
                    pntX[i] = pnt[1]
                    pntY[i] = pnt[2]
                    pntZ[i] = pnt[3]
                end
            end
            
            
            function userFunc.setFaces(newFaces,r,g,b)
                local concat,remove = table.concat,table.remove
                local pntX,pntY,pntZ = pointSet[1],pointSet[2],pointSet[3]
                
                local function getData(pointIndices)
                    local pntCount = #pointIndices
                    if pntCount > 2 then
                        local p1i,p2i,p3i = pointIndices[1],pointIndices[2],pointIndices[3]
                        local p1x,p1y,p1z,p2x,p2y,p2z,p3x,p3y,p3z = pntX[p1i],pntY[p1i],pntZ[p1i],pntX[p2i],pntY[p2i],pntZ[p2i],pntX[p3i],pntY[p3i],pntZ[p3i]
                        
                        local v1x,v1y,v1z = p2x-p1x,p2y-p1y,p2z-p1z
                        local v2x,v2y,v2z = p3x-p1x,p3y-p1y,p3z-p1z
                        local nx,ny,nz = v1y*v2z-v1z*v2y,v1z*v2x-v1x*v2z,v1x*v2y-v2x*v1y
                        local mag = (nx*nx+ny*ny+nz*nz)^(0.5)
                        nx,ny,nz = nx/mag,ny/mag,nz/mag
                        local pX,pY,pZ = p1x+p2x+p3x,p1y+p2y+p3y,p1z+p2z+p3z
                        local oData = nil
                        if pntCount == 4 then
                            local tmpOData = getData({pointIndices[4],pointIndices[1],pointIndices[3]})
                            if not (tmpOData[4] == nx and tmpOData[5] == ny and tmpOData[6] == nz) then
                                remove(pointIndices,4)
                                oData = tmpOData
                            end
         
                        end
                        local count = 3
                        local string = {'<path color=rgb(%.f,%.f,%.f) d="M%.1f %.1fL%.1f %.1f %.1f %.1f'}
                        local sCount = 2
                        for i=4, #pointIndices do
                            local pi = pointIndices[i]
                            pX,pY,pZ = pX + pntX[pi],pY+ pntY[pi],pZ+ pntZ[pi] 
                            count = count + 1
                            string[sCount] = ' %.1f %.1f'
                            sCount = sCount + 1
                        end
                        string[sCount] = 'Z"/>'
                        --local pn1 = pointIndices[1]
                        
                        return {pX/count,pY/count,pZ/count,nx,ny,nz,pointIndices,r,g,b,concat(string)},oData
                    end
                end
                local m = 1
                for i=1, #newFaces do
                    local data,oData = getData(newFaces[i])
                    faces[m] = data
                    m=m+1
                    if oData then
                        faces[m] = oData
                        m=m+1
                    end
                end
            end
            
            function userFunc.setScale()
            end
            function userFunc.setDrawData(drawData) elementData[8] = drawData end
            
            return userFunc
        end
        function self.createSlider(uiElement, center)
            local self = {}
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
    local sx,sy,sz,sw
    function self.getModelMatrix(mObject)
        local s, c = sin, cos
        local modelMatrices = {}

        -- Localize Object values.
        local objOri, objPos = mObject[10], mObject[12]
        local objPosX, objPosY, objPosZ = objPos[1], objPos[2], objPos[3]

        if mObject[9] == 1 then
            local wx, wy, wz, ww = objOri[1], objOri[2], objOri[3], objOri[4]
            local sx,sy,sz,sw = matrixToQuat(cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ)
            local mx, my, mz, mw =
                wx*sw + ww*sx + wy*sz - wz*sy,
                wy*sw + ww*sy + wz*sx - wx*sz,
                wz*sw + ww*sz + wx*sy - wy*sx,
                ww*sw - wx*sx - wy*sy - wz*sz
            wx, wy, wz, ww = mx, my, mz, mw
        end
        if mObject[8] == 2 then -- If Local
            return objOri[1], objOri[2], objOri[3], objOri[4], 
            objPosX, -- Convert this to 
            objPosY, 
            objPosZ
        else
            local cWorldPos = getCWorldPos()
            local oPX, oPY, oPZ = objPosX - cWorldPos[1], objPosY - cWorldPos[2], objPosZ - cWorldPos[3]
            return wx, wy, wz, ww, 
            cRX * oPX + cRY * oPY + cRZ * oPZ, 
            cFX * oPX + cFY * oPY + cFZ * oPZ, 
            cUX * oPX + cUY * oPY + cUZ * oPZ
        end
    end

    function self.getViewMatrix()
        local cU, cF, cR = getCWorldU(), getCWorldF(), getCWorldR()
        sx,sy,sz,sw = matrixToQuat(cR[1], cR[2], cR[3], cF[1], cF[2], cF[3], cU[1], cU[2], cU[3])
        
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
                for uiC = 1, #uiGroups do
                    local uiGroup = uiGroups[uiC]

                    local elements = uiGroup[2]
                    local modelElements = uiGroup[4]

                    for eC = 1, #modelElements do
                        local mod = modelElements[eC]
                        local mXO, mYO, mZO = mod[10], mod[11], mod[12]

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
                            local x, y, z = pointsX[index], pointsY[index], pointsZ[index]
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
                            local r, g, b = plane[8] * brightness, plane[9] * brightness, plane[10] * brightness

                            local indices = plane[7]
                            local data = {r, g, b}
                            local m = 4
                            local indexSize = #indices
                            data[m + indexSize * 2 - 1] = false

                            for i = 1, indexSize do
                                local index = indices[i]
                                local pntX = tPointsX[index]
                                if not pntX then
                                    goto behindElement
                                end

                                data[m] = pntX
                                data[m + 1] = tPointsY[index]
                                m = m + 2
                            end
                            zBC = zBC + 1
                            zSorter[zBC] = eCZ
                            zBuffer[eCZ] = {
                                plane[11],
                                data,
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
                        
                        local eCZ = mYX * eXO + mYY * eYO + mYZ * eZO + mYW
                        if eCZ < 0 then
                            goto behindElement
                        end
                        
                        local eCX = mXX * eXO + mXY * eYO + mXZ * eZO + mXW
                        local eCY = mZX * eXO + mZY * eYO + mZZ * eZO + mZW

                        local actions = el[4]
                        local oRM = el[16]
                        local fw = -oRM[4]
                        local xxMult, xzMult, yxMult, yzMult, zxMult, zzMult

                        if fw ~= -1 then
                            local fx, fy, fz = oRM[1], oRM[2], oRM[3]
                            local rx, ry, rz, rw =
                                fx * vMW + fw * vMX + fy * vMZ - fz * vMY,
                                fy * vMW + fw * vMY + fz * vMX - fx * vMZ,
                                fz * vMW + fw * vMZ + fx * vMY - fy * vMX,
                                fw * vMW - fx * vMX - fy * vMY - fz * vMZ

                            local rxrx, ryry, rzrz = rx * rx, ry * ry, rz * rz
                            xxMult, xzMult = (1 - 2 * (ryry + rzrz)) * pxw, 2 * (rx * rz - ry * rw) * pxw
                            yxMult, yzMult = 2 * (rx * ry - rz * rw), 2 * (ry * rz + rx * rw)
                            zxMult, zzMult = 2 * (rx * rz + ry * rw) * pzw, (1 - 2 * (rxrx + ryry)) * pzw
                        else
                            xxMult, xzMult = mXX, mXZ
                            yxMult, yzMult = mYX, mYZ
                            zxMult, zzMult = mZX, mZZ
                        end

                        zBC = zBC + 1
                        if el[15] and actions[7] then
                            aBC = aBC + 1
                            local p0X, p0Y, p0Z = P0XD - eXO, P0YD - eYO, P0ZD - eZO

                            local NX, NY, NZ = el[12], el[13], el[14]
                            local t = -(p0X * NX + p0Y * NY + p0Z * NZ) / (vx2 * NX + vy2 * NY + vz2 * NZ)
                            local px, py, pz = p0X + t * vx2, p0Y + t * vy2, p0Z + t * vz2

                            local ox, oy, oz, ow = oRM[1], oRM[2], oRM[3], oRM[4]
                            local oyoy = oy * oy
                            zSorter[zBC] = eCZ
                            zBuffer[eCZ] = {
                                el,
                                false,
                                eCX,
                                eCY,
                                xxMult, 
                                xzMult, 
                                yxMult, 
                                yzMult, 
                                zxMult, 
                                zzMult,
                                isUI = true
                            }
                            aSorter[aBC] = eCZ
                            aBuffer[eCZ] = {
                                el,
                                2 * ((0.5 - oyoy - oz * oz) * px + (ox * oy + oz * ow) * py + (ox * oz - oy * ow) * pz),
                                2 * ((ox * oz + oy * ow) * px + (oy * oz - ox * ow) * py + (0.5 - ox * ox - oyoy) * pz),
                                actions
                            }
                        else
                            zSorter[zBC] = eCZ
                            zBuffer[eCZ] = {
                                el,
                                false,
                                eCX,
                                eCY,
                                xxMult, 
                                xzMult, 
                                yxMult, 
                                yzMult, 
                                zxMult, 
                                zzMult,
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
                            local pX, pZ = uiElmt[2], uiElmt[3]
                            local inside = false
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
                            if oldSelected == false then
                                local enter = actions[3]
                                if enter then
                                    enter(identifier, pX, pZ)
                                end
                            elseif newSelected[6] == oldSelected[6] then
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
                                local enter = actions[3]
                                if enter then
                                    enter(identifier, pX, pY)
                                end
                                local leave = oldSelected[4][4]
                                if leave then
                                    leave(identifier, pX, pY)
                                end
                                
                            end
                            ::broke::
                        end
                    end
                    zBuffer[zDepth][2] = drawForm
                end
                if newSelected == false and oldSelected then
                    local leave = oldSelected[4][4]
                    if leave then
                        leave()
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
                    local el,drawForm,xwAdd,zwAdd,xxMult,xzMult,yxMult,yzMult,zxMult,zzMult=unpack(uiElmt)
                    if not drawForm then
                        drawForm = el[2]
                        if not drawForm then
                            goto broken
                        end
                    end
                    local ywAdd = distance
                    local count = 1
                     
                    local scale = el[5] or 1
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
                            local ex, ez = pointsX[ePC] * scale, pointsY[ePC] * scale

                            local pz = yxMult * ex + yzMult * ez + ywAdd
                            if pz < 0 then
                                uC = oUC
                                goto broken
                            end

                            distance = distance + pz
                            count = count + 1

                            unpackData[uC] = (xxMult * ex + xzMult * ez + xwAdd) / pz
                            unpackData[uC + 1] = (zxMult * ex + zzMult * ez + zwAdd) / pz
                            uC = uC + 2
                        end
                    else
                        for ePC = 1, #pointsX do
                            local ex, ez = pointsX[ePC] * scale, pointsY[ePC] * scale

                            local pz = yxMult * ex + yzMult * ez + ywAdd
                            if pz < 0 then
                                uC = oUC
                                goto broken
                            end

                            distance = distance + pz
                            count = count + 1

                            local px = (xxMult * ex + xzMult * ez + xwAdd) / pz
                            local py = (zxMult * ex + zzMult * ez + zwAdd) / pz

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
                    local data = uiElmt[2]
                    for alm = 1, #data do
                        unpackData[uC] = data[alm]
                        uC = uC + 1
                    end
                    drawStringData[dU] = uiElmt[1]
                    dU = dU + 1
                elseif uiElmt.isCustomSingle then
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