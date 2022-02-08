function getManager()
    local self = {}
    -- Misc function calls
    local solve=library.systemResolution3
    local sqrt,atan,asin,acos,print=math.sqrt,math.atan,math.asin,math.acos,system.print
    
    --- Core-based function calls
    local gCWOR,gCWOF,gCWOU,gCLOR,gCLOF,gCLOU,gCWR,gCWF,gCWU=core.getConstructWorldOrientationRight,core.getConstructWorldOrientationForward,core.getConstructWorldOrientationUp,core.getConstructOrientationRight,core.getConstructOrientationForward,core.getConstructOrientationUp,core.getConstructWorldRight,core.getConstructWorldForward,core.getConstructWorldUp
    local gWTLC,gLTWC=nil,nil
    
    function self.getLocalToWorldConverter()
        local s=solve
        local r,f,u=gCWR(),gCWF(),gCWU()
        local tr = {r[1],f[1],u[1]}
        local tf = {r[2],f[2],u[2]}
        local tu = {r[3],f[3],u[3]}
        return function(c)
            return s(tr, tf, tu, c)  
        end
    end

    function self.getWorldToLocalConverter()
        local xM,yM,zM=gCWR(),gCWF(),gCWU()
        local s = solve
        return function(w) return solve(xM,yM,zM,w) end
    end
    function self.quatToAxisAngle(ax,ay,az,aw)
        local awaw = 1/sqrt(1-aw*aw)

        return ax*awaw, ay*awaw, az*awaw, 2*acos(aw)
    end
    local function matrixToQuat(m11,m21,m31,m12,m22,m32,m13,m23,m33)
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
    
    function self.getPlayerLocalRotation()
        local fwd = unit.getMasterPlayerForward()
        local right = unit.getMasterPlayerRight()
        local up = unit.getMasterPlayerUp()

        return matrixToQuat(right[1],right[2],right[3],fwd[1],fwd[2],fwd[3],up[1],up[2],up[3])
    end
    
    
    function self.rotMatrixToQuat(rM1,rM2,rM3)
        if rM2 and rM3 then
            return matrixToQuat(rM1[1],rM1[2],rM1[3],rM2[1],rM2[2],rM2[3],rM3[1],rM3[2],rM3[3])
        else
            return matrixToQuat(rM1[1],rM1[5],rM1[9],rM1[2],rM1[6],rM1[10],rM1[3],rM1[7],rM1[11])
        end
    end
    function self.inverse(qX,qY,qZ,qW)
        return -qX,-qY,-qZ,qW
    end
    function self.inverseMulti(ax,ay,az,aw,bx,by,bz,bw)
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        return bx*(awaw-axax-ayay-azaz)+2*aw*(ax*bw+ay*bz-az*by),2*(bx*(aw*az+ax*ay)+bz*(ay*az-aw*ax))+by*(awaw-axax+ayay-azaz),2*(bx*(ax*az-aw*ay)+by*(ax*aw+ay*az))+bz*(awaw-axax-ayay+azaz),bw*(awaw+axax+ayay+azaz)
    end
    function self.transPoint3D(ax,ay,az,aw,bx,by,bz)
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        return 
        2*(by*(ax*ay-aw*az)+bz*(ax*az+aw*ay))+bx*(awaw+axax-ayay-azaz),
        2*(bx*(aw*az+ax*ay)+bz*(ay*az-aw*ax))+by*(awaw-axax+ayay-azaz),
        2*(bx*(ax*az-aw*ay)+by*(ax*aw+ay*az))+bz*(awaw-axax-ayay+azaz)
    end
    
    function self.transPoints3D(ax,ay,az,aw,points)
        
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        
        -- What I derived
        local a,b,c = (awaw+axax-ayay-azaz), 2*(ax*ay-aw*az), 2*(ax*az+aw*ay)
        local d,f,e = 2*(aw*az+ax*ay), (awaw-axax+ayay-azaz), 2*(ay*az-aw*ax)
        local g,h,i = 2*(ax*az-aw*ay), 2*(ax*aw+ay*az), (awaw-axax-ayay+azaz)
        
        local pts={}
        for i=1,#points,3 do
            local x,y,z=points[i],points[i+1],points[i+2]
            pts[i]=x*a+y*b+z*c
            pts[i+1]=x*d+y*e+z*f
            pts[i+2]=x*g+y*h+z*i
        end
        return pts
    end
    function self.transPoints2D(ax,ay,az,aw,points)
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        local b,c=2*(ax*az+aw*ay),(awaw+axax-ayay-azaz)
        local d,e=2*(aw*az+ax*ay),2*(ay*az-aw*ax)
        local g,i=2*(ax*az-aw*ay),(awaw-axax-ayay+azaz)
        local pts={}
        for i=1,#points,3 do
            local x,z=points[i],points[i+2]
            pts[i]=x*c+z*b
            pts[i+1]=x*d+z*e
            pts[i+2]=x*g+z*i
        end
        return pts
    end
    function self.multiply(ax,ay,az,aw,bx,by,bz,bw)
        return ax*bw+aw*bx+ay*bz-az*by,ay*bw+aw*by+az*bx-ax*bz,az*bw+aw*bz+ax*by-ay*bx,aw*bw-ax*bx-ay*by-az*bz
    end
    
    function self.transPoint2D(ax,ay,az,aw,x,y)
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        return 2*z*(ax*az+aw*ay)+x*(awaw+axax-ayay-azaz),2*(x*(aw*az+ax*ay)+z*(ay*az-aw*ax)),2*x*(ax*az-aw*ay)+z*(awaw-axax-ayay+azaz)
    end
    gWTLC,gLTWC=self.getWorldToLocalConverter,self.getLocalToWorldConverter
    return self
end