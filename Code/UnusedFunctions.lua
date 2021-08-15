local far = 10000
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
    function self.rotMatrixToEuler(rM)
        local a=atan
        local m11,m21,m31,m12,m22,m32,m13,m23,m33=rM[1],rM[5],rM[9],rM[2],rM[6],rM[10],rM[3],rM[7],rM[11]
        local y=0
        
        if m13>=1 then y=asin(1)
        elseif m13<=-1 then y=asin(-1)
        else y=asin(m13) end
        if abs(m13)<0.9999999 then return {a(-m23,m33),-y,-a(-m12,m11)}
        else return {a(m32, m22),-y,-0}
        end
    end
	local function translate(x,y,z,mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
            local x,y,z=x,-y,-z
            local pz = mYX*x+mYY*y+mYZ*z+mYW
            if pz>0 then
                return 0,0,-1
            end
            local px=mXX*x+mXY*y+mXZ*z+mXW
            local py=mZX*x+mZY*y+mZZ*z+mZW
            local pw=-pz
            -- Convert to window coordinates after W-Divide
            local wx=px/pw
            local wy=py/pw
            return wx,wy,pw
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