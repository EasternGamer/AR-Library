positionTypes = {
    globalP=1,
    localP=2
}
orientationTypes = {
    globalO=1,
    localO=2 
}

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
    function self.setStyle(style) self.style = style end
    function self.removeObject(id) objects[id] = {} end
    function self.hide() self.enabled = false end
    function self.show() self.enabled = true end
    function self.isEnabled() return self.enabled end
    function self.setGlowStyle(gStyle) self.gStyle = gStyle end
    function self.setGlow(enable,radius,scale) self.glow = enable; self.gRad = radius or self.gRad; self.scale = scale or false end 
    return self
end

local function RotationHandler(rotArray,resultantPos)
    
    --====================--
    --Local Math Functions--
    --====================--
    local manager,rad,sin,cos,rand = getManager(),math.rad,math.sin,math.cos,math.random
    local rotMatrixToQuat = manager.rotMatrixToQuat
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
                system.print('Unsupported Rotation!')
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
    
    --=================--
    --Positional Values--
    --=================--
    local pX,pY,pZ = resultantPos[1],resultantPos[2],resultantPos[3] -- These are original values, for relative to super rotation
    local offX,offY,offZ = 0,0,0
    local wXYZ = resultantPos
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
    local function process(wx,wy,wz,ww,lX,lY,lZ,lTX,lTY,lTZ,n)
        local timeStart = system.getTime()
        
        n = n or 1
        wx,wy,wz,ww = wx or 0, wy or 0, wz or 0, ww or 1
        lX,lY,lZ = lX or pX, lY or pY, lZ or pZ
        lTX,lTY,lTZ = lTX or pX, lTY or pY, lTZ or pZ
        
        local dX,dY,dZ = pX - lX, pY - lY, pZ - lZ

        if ww ~= 1 and ww ~= -1 then
            if dX ~= 0 or dY ~= 0 or dZ ~= 0 then
                wXYZ[1],wXYZ[2],wXYZ[3] = rotatePoint(wx,wy,wz,ww,dX,dY,dZ,lTX,lTY,lTZ)
	       else
                wXYZ[1],wXYZ[2],wXYZ[3] = lTX,lTY,lTZ
            end
            if dw ~= 1 then
                wx,wy,wz,ww = multiply(wx,wy,wz,ww,dx,dy,dz,dw)
            end
            if iw ~= 1 then
                wx,wy,wz,ww = multiply(wx,wy,wz,ww,ix,iy,iz,iw)
            end
        else
            local nX,nY,nZ = lTX+dX,lTY+dY,lTZ+dZ
            wXYZ[1],wXYZ[2],wXYZ[3] = nX,nY,nZ
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
            subRotations[i].update(wx,wy,wz,ww,pX,pY,pZ,wXYZ[1],wXYZ[2],wXYZ[3],n+1)
	   end
        local endTime = system.getTime()
        needsUpdate = false
    end
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
    
    out.update = process
    
    function out.setSuperManager(rotManager)
        superManager = rotManager
    end
    
    function out.addSubRotation(rotManager)
        rotManager.setSuperManager(out)
        subRotations[#subRotations + 1] = rotManager
        process()
    end
    function out.getPosition()
        return pX,pY,pZ
    end
    function out.setPosition(tx,ty,tz)
        
        if not (tx ~= tx or ty ~= ty or tz ~= tz)  then
            
            pX,pY,pZ = tx,ty+rand()*0.00001,tz
            out.bubble()
        end
    end
    function out.bubble()
        if superManager then
            superManager.bubble()
        else
            needsUpdate = true
        end
    end
    function out.checkUpdate()
        if needsUpdate then
            local startTime = system.getTime()
            process()
            --logRotation.addValue(system.getTime() - startTime)
        end
        return needsUpdate
    end
    
    function out.rotateXYZ(rotX,rotY,rotZ,rotW)
        if rotX and rotY and rotZ then
            tix,tiy,tiz,tiw = rotX,rotY,rotZ,rotW
            rotate(false)
        else
            if type(rotX) == 'table' then
                if #rotX == 3 then
                    tix,tiy,tiz,tiw = rotX[1],rotX[2],rotX[3],nil
                    goto valid  
                end
            end
            print('Invalid format. Must be three angles, or right, forward and up vectors, or a quaternion. Use radians if angles.')
            ::valid::
        end
    end
    
    function out.rotateX(rotX) tix = rotX; tiw = nil; rotate(false) end
    function out.rotateY(rotY) tiy = rotY; tiw = nil; rotate(false) end
    function out.rotateZ(rotZ) tiz = rotZ; tiw = nil; rotate(false) end
    
    function out.rotateDefaultXYZ(rotX,rotY,rotZ,rotW)
        if rotX and rotY and rotZ then
            tdx,tdy,tdz,tdw = rotX,rotY,rotZ,rotW
            rotate(true)
        else
            if type(rotX) == 'table' then
                if #rotX == 3 then
                    tdx,tdy,tdz,tdw = rotX[1],rotX[2],rotX[3],nil
                    goto valid  
                end
            end
            print('Invalid format. Must be three angles, or right, forward and up vectors, or a quaternion. Use radians if angles.')
            ::valid::
        end
    end
    
    function out.rotateDefaultX(rotX) tdx = rotX; tdw = nil; rotate(true) end
    function out.rotateDefaultY(rotY) tdy = rotY; tdw = nil; rotate(true) end
    function out.rotateDefaultZ(rotZ) tdz = rotZ; tdw = nil; rotate(true) end
    return out
end


function Object(style, position, offset, orientation, positionType, orientationType, transX, transY)
    
    
    
    local rad,print,rand=math.rad,system.print,math.random
    
    local position=position
    local positionOffset=offset
    
    local style=style
    local customGroups,uiGroups,subObjects={},{},{}
    local positionType=positionType
    local orientationType=orientationType
    local ori = {0,0,0,1}
    local objRotationHandler = RotationHandler(ori,position)
    objRotationHandler.rotateXYZ(orientation)
    
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
        local sqrt, s, c,remove = math.sqrt, math.sin, math.cos, table.remove

        local function createNormal(points, rx, ry, rz, rw)
            if #points < 6 then
                print("Invalid Point Set!")
                do
                    return
                end
            end
            return 2*(rx*ry-rz*rw),1-2*(rx*rx+rz*rz),2*(ry*rz+rx*rw)
        end
        local function createBounds(points)
            local bounds = {}
            local size = #points
            if size >= 60 then
                return false
            end
            local delta = 1
            for i = 1, size, 2 do
                bounds[delta] = {points[i],points[i+1]}
                delta = delta + 1
            end
            return bounds
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
            
            local pointSet = {}
            local actions = {false,false,false,false,false,false,false}
            local mainRotation = {0,0,0,1}
            local resultantPos = {x,y+rand()*0.000001,z}
            local mRot = RotationHandler(mainRotation,resultantPos)
            
            --system.print(string.format('UI Create {%.2f,%.2f,%.2f}', resultantPos[1],resultantPos[2],resultantPos[3]))
            local elementData = {false, false, false, actions, false, true, false, false, pointSet, resultantPos, false,false,false,false, mainRotation,mRot}
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
                local pC = #pointSet
                if x and y then
                    handleBound(x,y)
                    pointSet[pC+1] = x
                    pointSet[pC+2] = y
                else
                    if type(x) == 'table' and #x > 0 then
                        local x,y = x[1], x[2]
                        handleBound(x,y)
                        pointSet[pC+1] = x
                        pointSet[pC+2] = y
                    else
                        print('Invalid format for point.')
                    end
                end
            end
            function user.addPoints(points)
                local pnts = elementData[9]
                pointSet = pnts
                if points then
                    local pointCount = #points
                    if pointCount > 0 then
                        local pType = type(points[1])
                        if pType == 'number' then
                            local startIndex = #pnts
                            for i = 1, pointCount,2 do
                                local index = startIndex + i
                                
                                local x,y = points[i],points[i+1]
                                handleBound(x,y)
                                
                                pnts[index] = x
                                pnts[index+1] = y
                            end
                        elseif pType == 'table' then
                            
                            local startIndex = #pnts
                            local interval = 1
                            for i = 1, pointCount do
                                local index = startIndex + interval
                                
                                local point = points[i]
                                local x,y = point[1],point[2]
                                handleBound(x,y)
                                
                                pnts[index] = x
                                pnts[index + 1] = y
                                interval=interval+2
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
                if elementData[14] then
                    user.setNormal(createNormal(pointSet, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4]))
                end
            end
            
            function user.rotateDefaultXYZ(rX,rY,rZ,rW) mRot.rotateDefaultXYZ(rX,rY,rZ,rW); updateNormal() end
            function user.rotateDefaultX(rX) mRot.rotateDefaultX(rX); updateNormal() end
            function user.rotateDefaultY(rY) mRot.rotateDefaultY(rY); updateNormal() end
            function user.rotateDefaultZ(rZ) mRot.rotateDefaultZ(rZ); updateNormal() end
            
            function user.rotateXYZ(rX,rY,rZ,rW) mRot.rotateXYZ(rX,rY,rZ,rW); updateNormal() end
            function user.rotateX(rX) mRot.rotateX(rX); updateNormal() end
            function user.rotateY(rY) mRot.rotateY(rY); updateNormal() end
            function user.rotateZ(rZ) mRot.rotateZ(rZ); updateNormal() end
            

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
                    for i = 1, #pointSet, 2 do
                        pointSet[i] = pointSet[i] - psX + sx
                        pointSet[i+1] = pointSet[i+1] - psY + sy
                    end
                    maxX,minX,maxY,minY = maxX+sx,minX+sx,maxY+sy,minY+sy
                else
                    for i=1,#indices do
                        local index = indices[i]*2-1
                        pointSet[index] = pointSet[index] - psX + sx
                        pointSet[index+1] = pointSet[index+1] - psY + sy
                    end
                    -- TODO: Check min-max values and update accordingly
                end
                psX = sx
                psY = sy
                
                if updateHitbox then
                    user.setBounds(createBounds(pointSet))
                end
            end
            local ogPointSet = nil
            function user.moveTo(sx,sy,indices,updateHitbox,useOG)
                if not indices then
                    print('ERROR: No indices specified!')
                else
                    if not ogPointSet then
                        ogPointSet = {table.unpack(pointSet)}
                    end
                    for i=1,#indices do
                        local index = indices[i]*2-1
                        if not useOG then
                            pointSet[index] = sx
                            pointSet[index+1] = sy
                        else
                            pointSet[index] = ogPointSet[index] + sx
                            pointSet[index+1] = ogPointSet[index+1] + sy
                        end
                    end
                    -- TODO: Check min-max values and update accordingly
                end
                if updateHitbox then
                    user.setBounds(createBounds(pointSet))
                end
            end
            
            function user.setDrawOrder(indices)
                local drawOrder = {}
                for i=1, #indices do
                    local index = indices[i]
                    
                    local order = drawOrder[index*2-1]
                    if not order then
                        order = {}
                        drawOrder[index*2-1] = order
                    end
                    order[#order+1] = i*2-1
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
            
            function user.getPoints() return elementData[9] end
            
            function user.setDrawOrder(drawOrder) elementData[7] = drawOrder end
            function user.setDrawData(drawData) elementData[8] = drawData end
            
            function user.setPoints(points) pointSet = points; elementData[9] = pointSet end
            
            function user.setElementIndex(eI) elementIndex = eI end
            function user.getElementIndex(eI) return elementIndex end
            
            function user.setPosition(sx,sy,sz)
                mRot.setPosition(sx,sy,sz)
            end
            
            function user.setNormal(nx,ny,nz)
                elementData[11] = nx
                elementData[12] = ny
                elementData[13] = nz
            end
            
            function user.setBounds(bounds)
                elementData[14] = bounds
            end
            function user.getPosition() return mRot.getPosition() end
            
            function user.build(force, hasBounds)
                
                local nx, ny, nz = createNormal(pointSet, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4])
                if nx then
                    if elementData[2] then
                        user.setNormal(nx,ny,nz)
                        if not force then
                            if hasBounds or hasBounds == nil then
                                user.setBounds(createBounds(pointSet))
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
            
            local userFunc, text = createUITemplate(tx, ty, tz)
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

                local points,drawStrings = {},{'<path stroke-width="%gpx" stroke="%s" stroke-opacity="%g" fill="none" d="'}
                local count = 1
                
                local textCacheSize = #textCache
                
                for k = 1, textCacheSize do
                    local char = textCache[k]
                    drawStrings[k + 1] = char[3]
                    
                    local charPoints, charSize = char[1], char[2]
                    for m = 1, #charPoints, 2 do
                        local x,y = charPoints[m] * fontSize + woffsetX + mx, charPoints[m + 1] * fontSize + offsetY + my
                        
                        handleBound(x,y)
                        
                        points[count] = x
                        points[count + 1] = y
                        count = count + 2
                    end
                    woffsetX = woffsetX + charSize * fontSize
                    if char[4] == 10 then
                        offsetXCounter = offsetXCounter + 1
                        woffsetX = offsetCacheX[offsetXCounter]
                        offsetY = offsetY - charSize * fontSize
                    end
                end

                drawStrings[textCacheSize+2] = '"/>'
                
                userFunc.setDefaultDraw(concat(drawStrings))
                userFunc.setPoints(points)
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
            local userFuncFill,fill = createUITemplate(ex, ey, ez, 1)

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
                
                local points = userFuncFill.getPoints()
                if #points > 0 then
                    if sPCount == ePCount and sPCount > 0 then
                        for i=1, sPCount do
                            local sPI = sPointIndices[i]
                            local ePI = ePointIndices[i]
                            
                            local xChangePercent = (points[ePI]-points[sPI]) * 0.01
                            local yChangePercent = (points[ePI+1]-points[sPI+1]) * 0.01
                            intervals[i] = {xChangePercent,yChangePercent}
                        end
                    end
                end
            end
            
            function userFuncOut.setStartIndices(indices)
                for i=1, #indices do
                    local index = indices[i]*2-1
                    sPointIndices[i]=index
                end
                makeIntervals()
            end
            
            function userFuncOut.setEndIndices(indices)
                for i=1, #indices do
                    local index = indices[i]*2-1
                    ePointIndices[i]=index
                end
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
                local points = userFuncOut.getPoints()
                
                for i=1, #ePointIndices do
                    local c = intervals[i]
                    local xC,yC = c[1],c[2]
                    local sPI = sPointIndices[i]
                    local ePI = ePointIndices[i]
                    
                    points[ePI] = points[sPI] + xC * progress
                    points[ePI+1] = points[sPI+1] + yC * progress
                    
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
                userFuncFill.setOffsetPosition(tx,ty,tz)
            end
            
            return userFuncOut
        end
        function self.createCustomDraw(x,y,z)
            return createUITemplate(x,y,z)
        end
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
    
    function self.setPosition(posX, posY, posZ) self[11] = {posX, posY, posZ} end
    
    function self.rotateDefaultXYZ(rX,rY,rZ,rW) objRotationHandler.rotateDefaultXYZ(rX,rY,rZ,rW); end
    function self.rotateDefaultX(rX) objRotationHandler.rotateDefaultX(rX); end
    function self.rotateDefaultY(rY) objRotationHandler.rotateDefaultY(rY); end
    function self.rotateDefaultZ(rZ) objRotationHandler.rotateDefaultZ(rZ); end
            
    function self.rotateXYZ(rX,rY,rZ,rW) objRotationHandler.rotateXYZ(rX,rY,rZ,rW); end
    function self.rotateX(rX) objRotationHandler.rotateX(rX); end
    function self.rotateY(rY) objRotationHandler.rotateY(rY); end
    function self.rotateZ(rZ) objRotationHandler.rotateZ(rZ); end
    
    function self.addSubObject(object, id)
        local id=id or #self[6]+1
        self[6][id]=object
        return id
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