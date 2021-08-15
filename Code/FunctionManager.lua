function getManager()
    local self = {}
    -- Misc function calls
    local solve=library.systemResolution3
    local gPWP=system.getPlayerWorldPos
    local sqrt,atan,asin,print=math.sqrt,math.atan,math.asin,system.print
    --- Core-based function calls
    local gCWP=core.getConstructWorldPos
    local gCWOR,gCWOF,gCWOU,gCLOR,gCLOF,gCLOU=core.getConstructWorldOrientationRight,core.getConstructWorldOrientationForward,core.getConstructWorldOrientationUp,core.getConstructOrientationRight,core.getConstructOrientationForward,core.getConstructOrientationUp
    local gEPBI=core.getElementPositionById
    local mul,div,inv,rTQ,gTWP,gWTLC,gLTWC=nil,nil,nil,nil,nil,nil,nil
    
    local hp=core.getMaxHitPoints()
    local cOff=16
    if hp>10000 then cOff=128
    elseif hp>1000 then cOff=64
    elseif hp>150 then cOff=32
    end
    local function correct(v)
        local lr,lf,lu=gCLOR(),gCLOF(),gCLOU()
        return solve(lr,lf,lu,v)
    end
    function self.getLocalToWorldConverter()
        local s=solve
        local r,f,u=gCWOR(),gCWOF(),gCWOU()
        return function(c) c=correct(c) return s(s(r,f,u,{1,0,0}),s(r,f,u,{0,1,0}),s(r,f,u,{0,0,1}),c) end
    end

    function self.getWorldToLocalConverter()
        local lr,lf,lu,r,f,u=gCLOR(),gCLOF(),gCLOU(),gCWOR(),gCWOF(),gCWOU()

        local matrix1,matrix2={lr[1],lr[2],lr[3],0,lf[1],lf[2],lf[3],0,lu[1],lu[2],lu[3],0},{r[1],r[2],r[3],0,f[1],f[2],f[3],0,u[1],u[2],u[3],0}
        
        local ax,ay,az,aw=inv(rTQ(matrix1))
        local bx,by,bz,bw=rTQ(matrix2)
        local wx,wy,wz,ww=mul(ax,ay,az,aw,bx,by,bz,bw)
        
        local wxwx,wxwy,wxwz,wxww,wywy,wywz,wyww,wzwz,wzww=wx*wx,wx*wy,wx*wz,wx*ww,wy*wy,wy*wz,wy*ww,wz*wz,wz*ww
        return function(w) return solve({1-2*(wywy+wzwz),2*(wxwy-wzww),2*(wxwz+wyww)},{2*(wxwy+wzww),1-2*(wxwx+wzwz),2*(wywz-wxww)},{2*(wxwz-wyww),2*(wywz+wxww),1-2*(wxwx+wywy)},w) end
    end
    function self.getTrueWorldPos()
        local cal1=gLTWC()
        local cal2=gWTLC()
        local cWP=gCWP()
        local p=gEPBI(1)
        local offsetPosition={p[1]-cOff,p[2]-cOff,p[3]-cOff}
        local adj=cal1(offsetPosition)
        local adjPos={cWP[1]-adj[1],cWP[2]-adj[2],cWP[3]-adj[3]}
        return adjPos
    end
    function self.getPlayerLocalPos(playerId)
        local c=gWTLC()
        local cWP=gTWP()
        local pWP=gPWP(playerId)
        local adjPos=c({pWP[1]-cWP[1],pWP[2]-cWP[2],pWP[3]-cWP[3]})
        adjPos={-adjPos[1],adjPos[2],adjPos[3]}
        return adjPos
    end
    function self.rotMatrixToQuat(rM)
        local m11,m21,m31,m12,m22,m32,m13,m23,m33=rM[1],rM[5],rM[9],rM[2],rM[6],rM[10],rM[3],rM[7],rM[11]
        local t=m11+m22+m33
        if t>0 then
            local s=0.5/sqrt(t+1)
            return (m32-m23)*s,(m13-m31)*s,(m21-m12)*s,0.25/s
        elseif m11>m22 and m11>m33 then
            local s = 2*sqrt(1+m11-m22-m33)
            return 0.25*s,(m12+m21)/s,(m13+m31)/s,(m32-m23)/s
        elseif m22>m33 then
            local s=2*sqrt(1+m22-m11-m33)
            return (m12+m21)/s,0.25*s,(m23+m32)/s,(m13-m31)/s
        else
            local s=2*sqrt(1+m33-m11- m22)
            return (m13+m31)/s,(m23+m32)/s,0.25*s,(m21-m12)/s
        end
    end
    function self.inverse(qX,qY,qZ,qW)
        local mag=qX*qX+qY*qY+qZ*qZ+qW*qW
        return -qX/mag,-qY/mag,-qZ/mag,qW/mag
    end
    function self.multiply(ax,ay,az,aw,bx,by,bz,bw)
        return ax*bw+aw*bx+ay*bz-az*by,ay*bw+aw*by+az*bx-ax*bz,az*bw+aw*bz+ax*by-ay*bx,aw*bw-ax*bx-ay*by-az*bz
    end
    function self.divide(ax,ay,az,aw,bx,by,bz,bw)
        local cx,cy,cz,cw=inv(bx,by,bz,bw)
        return mul(ax,ay,az,aw,cx,cy,cz,cw)
    end
    mul,div,inv,rTQ,gTWP,gWTLC,gLTWC=self.multiply,self.divide,self.inverse,self.rotMatrixToQuat,self.getTrueWorldPos,self.getWorldToLocalConverter,self.getLocalToWorldConverter
    return self
end