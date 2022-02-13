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
    
    function self.rotMatrixToQuat(rM1,rM2,rM3)
        if rM2 and rM3 then
            return matrixToQuat(rM1[1],rM1[2],rM1[3],rM2[1],rM2[2],rM2[3],rM3[1],rM3[2],rM3[3])
        else
            return matrixToQuat(rM1[1],rM1[5],rM1[9],rM1[2],rM1[6],rM1[10],rM1[3],rM1[7],rM1[11])
        end
    end
    self.matrixToQuat = matrixToQuat
    return self
end