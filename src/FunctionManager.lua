function LinkedList(name, prefix)
    local functions = {}
    local internalDataTable = {}
    local internalTableSize = 0
    local removeKey,addKey,indexKey,refKey = prefix .. 'Remove',prefix .. 'Add',prefix..'index',prefix..'ref'
    
    functions[removeKey] = function (node)
        local tblSize,internalDataTable = internalTableSize,internalDataTable
        if tblSize > 1 then
            if node[indexKey] == -1 then return end
            local lastElement,replaceNodeIndex = internalDataTable[tblSize],node[indexKey]
            internalDataTable[replaceNodeIndex] = lastElement
            internalDataTable[tblSize] = nil
            lastElement[indexKey] = replaceNodeIndex
            internalTableSize = tblSize - 1
            node[indexKey] = -1
            node[refKey] = nil
        elseif tblSize == 1 then
            internalDataTable[1] = nil
            internalTableSize = 0
            node[indexKey] = -1
            node[refKey] = nil
        end
    end

    functions[addKey] = function (node, override)
        local indexKey,refKey = indexKey,refKey
        if node[indexKey] and node[indexKey] ~= -1 then
            if not node[refKey] == functions or override then
                node[refKey][removeKey](node)
            else
                return
            end
        end
        local tblSize = internalTableSize + 1
        
        internalDataTable[tblSize] = node
        node[indexKey] = tblSize
        node[refKey] = functions
        internalTableSize = tblSize
    end

    functions[prefix .. 'GetData'] = function ()
        return internalDataTable, internalTableSize
    end

    return functions
end

local math = math
local sin, cos, rad, type = math.sin,math.cos,math.rad, type

function RotMatrixToQuat(m1,m2,m3)
    local m11,m22,m33 = m1[1],m2[2],m3[3]
    local t=m11+m22+m33
    if t>0 then
        local s=0.5/(t+1)^(0.5)
        return (m2[3]-m3[2])*s,(m3[1]-m1[3])*s,(m1[2]-m2[1])*s,0.25/s
    elseif m11>m22 and m11>m33 then
        local s = 1/(2*(1+m11-m22-m33)^(0.5))
        return 0.25/s,(m2[1]+m1[2])*s,(m3[1]+m1[3])*s,(m2[3]-m3[2])*s
    elseif m22>m33 then
        local s=1/(2*(1+m22-m11-m33)^(0.5))
        return (m2[1]+m1[2])*s,0.25/s,(m3[2]+m2[3])*s,(m3[1]-m1[3])*s
    else
        local s=1/(2*(1+m33-m11-m22)^(0.5))
        return (m3[1]+m1[3])*s,(m3[2]+m2[3])*s,0.25/s,(m1[2]-m2[1])*s
    end
end

function GetQuaternion(x,y,z,w)
    if type(x) == 'number' then
        if w == nil then
            if x == x and y == y and z == z then
                local rad,sin,cos = rad,sin,cos
                x,y,z = -rad(x * 0.5),rad(y * 0.5),-rad(z * 0.5)
                local sP,sH,sR=sin(x),sin(y),sin(z)
                local cP,cH,cR=cos(x),cos(y),cos(z)
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
function QuaternionMultiply(ax,ay,az,aw,bx,by,bz,bw)
    return ax*bw+aw*bx+ay*bz-az*by,
    ay*bw+aw*by+az*bx-ax*bz,
    az*bw+aw*bz+ax*by-ay*bx,
    aw*bw-ax*bx-ay*by-az*bz
end

function RotatePoint(ax,ay,az,aw,oX,oY,oZ,wX,wY,wZ)
    local t1,t2,t3 = 2*(ay*oZ - az*oY), 2*(az*oX - ax*oZ), 2*(ax*oY - ay*oX)
    
    return 
    oX + aw*t1 + ay*t3 - az*t2 + wX,
    oY + (aw - ax)*t2 + az*t1 + wY,
    oZ + aw*t3 + ax*t2 - ay*t1 + wZ
end
function getRotationManager(out_rotation,wXYZ, name)
    --====================--
    --Local Math Functions--
    --====================--
    local print,type,unpack,multiply,rotatePoint,getQuaternion = DUSystem.print,type,table.unpack,QuaternionMultiply,RotatePoint,GetQuaternion

    local superManager,needsUpdate,needNormal = nil,false,false
    local outBubble = nil
    --=================--
    --Positional Values--
    --=================--
    local pX,pY,pZ = wXYZ[1],wXYZ[2],wXYZ[3] -- These are original values, for relative to super rotation
    local isRelativePosition = false
    local posY = math.random()*0.00001

    --==================--
    --Orientation Values--
    --==================--
    local tix,tiy,tiz,tiw = 0,0,0,1 -- temp intermediate rotation values

    local ix,iy,iz,iw = 0,0,0,1 -- intermediate rotation values
    local nx,ny,nz = 0,1,0

    local subRotQueue = {}
    local subRotations = LinkedList(name, 'sub')

    --==============--
    --Function Array--
    --==============--
    local out = {}

    --=======--
    --=Cache=--
    --=======--
    local cache = {0,0,0,1,pX,pY,pZ,pX,pY,pZ}
    --============================--
    --Primary Processing Functions--
    --============================--
    local function process(wx,wy,wz,ww,lX,lY,lZ,lTX,lTY,lTZ)
        if not wx then
            wx,wy,wz,ww,lX,lY,lZ,lTX,lTY,lTZ = unpack(cache)
        else
            cache = {wx,wy,wz,ww,lX,lY,lZ,lTX,lTY,lTZ}
        end

        local dX,dY,dZ
        if not isRelativePosition then
            dX,dY,dZ = pX - lX, pY - lY, pZ - lZ
        else
            dX,dY,dZ = pX,pY,pZ
        end
        if ww ~= 1 and ww ~= -1 then
            wXYZ[1],wXYZ[2],wXYZ[3] = RotatePoint(wx,wy,wz,-ww,dX,dY,dZ,lTX,lTY,lTZ)
            if iw ~= 1 then
                wx,wy,wz,ww = multiply(wx,wy,wz,ww,ix,iy,iz,iw)
            end
        else
            wXYZ[1],wXYZ[2],wXYZ[3] = lTX+dX,lTY+dY,lTZ+dZ
            if iw ~= 1 then
                wx,wy,wz,ww = ix,iy,iz,iw
            end
        end
        out_rotation[1],out_rotation[2],out_rotation[3],out_rotation[4] = wx,wy,wz,ww
        if needNormal then
            nx,ny,nz = 2*(wx*wy+wz*ww),1-2*(wx*wx+wz*wz),2*(wy*wz-wx*ww)
        end
        local subRots,subRotsSize = subRotations.subGetData()
        for i=1, subRotsSize do
            subRots[i].update(wx,wy,wz,ww,pX,pY,pZ,wXYZ[1],wXYZ[2],wXYZ[3])
        end
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
    local function rotate()
        local tx,ty,tz,tw = getQuaternion(tix,tiy,tiz,tiw)
        if tx ~= ix or ty~= iy or tz ~= iz or tw ~= iw then
            ix, iy, iz, iw = tx, ty, tz, tw
            validate()
            out.bubble()
            return true
        end
        return false
    end
    function out.enableNormal()
        needNormal = true
    end
    function out.disableNormal()
        needNormal = false
    end
    function out.setSuperManager(rotManager)
        superManager = rotManager
        if not rotManager then
            cache = {0,0,0,1,pX,pY,pZ,pX,pY,pZ}
            needsUpdate = true
        end
    end
    function out.addToQueue(func)
        if not needsUpdate then
            subRotQueue[#subRotQueue+1] = func
        end
    end

    function out.addSubRotation(rotManager)
        rotManager.setSuperManager(out)
        subRotations.subAdd(rotManager, true)
        out.bubble()
    end
    function out.remove()
        if superManager then
            superManager.removeSubRotation(out)
            out.setSuperManager(false)
            out.bubble()
        end
    end
    function out.removeSubRotation(sub)
        sub.setSuperManager(false)
        subRotations.subRemove(sub)
    end
    function out.bubble()
        if superManager and not needsUpdate then
            subRotQueue = {}
            needsUpdate = true
            superManager.addToQueue(process)
        else
            needsUpdate = true
        end
    end

    function out.checkUpdate()
        local neededUpdate = needsUpdate
        if neededUpdate then
            process()
            subRotQueue = {}
        else
            for i=1, #subRotQueue do
                subRotQueue[i]()
            end
            subRotQueue = {}
        end
        return neededUpdate
    end
    local outBubble = out.bubble
    local function assignFunctions(inFuncArr,specialCall)
        inFuncArr.update = process
        function inFuncArr.getPosition() return pX,pY,pZ end
        function inFuncArr.getRotationManger() return out end
        function inFuncArr.getSubRotationData() return subRotations.subGetData() end
        inFuncArr.checkUpdate = out.checkUpdate
        function inFuncArr.setPosition(tx,ty,tz)
            if not (tx ~= tx or ty ~= ty or tz ~= tz)  then
                local tmpY = ty+posY
                if pX ~= tx or pY ~= tmpY or pZ ~= tz then
                    pX,pY,pZ = tx,tmpY,tz
                    outBubble()
                    return true
                end
            end
            return false
        end
        function inFuncArr.getNormal()
            return nx,ny,nz
        end
        function inFuncArr.rotateXYZ(rotX,rotY,rotZ,rotW)
            if rotX and rotY and rotZ then
                tix,tiy,tiz,tiw = rotX,rotY,rotZ,rotW
                rotate()
                if specialCall then specialCall() end
            else
                if type(rotX) == 'table' then
                    if #rotX == 3 then
                        tix,tiy,tiz,tiw = rotX[1],rotX[2],rotX[3],nil
                        local result = rotate()
                        if specialCall then specialCall() end
                        goto valid  
                    end
                end
                print('Invalid format. Must be three angles, or right, forward and up vectors, or a quaternion. Use radians if angles.')
                ::valid::
                return false
            end

        end

        function inFuncArr.rotateX(rotX) tix = rotX; tiw = nil; rotate(); if specialCall then specialCall() end end
        function inFuncArr.rotateY(rotY) tiy = rotY; tiw = nil; rotate(); if specialCall then specialCall() end end
        function inFuncArr.rotateZ(rotZ) tiz = rotZ; tiw = nil; rotate(); if specialCall then specialCall() end end

        function inFuncArr.setPositionIsRelative(isRelative) isRelativePosition = isRelative; outBubble() end
        function inFuncArr.getRotation() return ix, iy, iz, iw end
    end
    out.assignFunctions = assignFunctions

    return out
end