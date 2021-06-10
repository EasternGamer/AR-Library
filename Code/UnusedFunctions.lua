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
