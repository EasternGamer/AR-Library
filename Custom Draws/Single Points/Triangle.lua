local sqrt3 = math.sqrt(3)
local function drawTriangle(svg,c,size,fill,tx,ty,tz,opacity)
    svg[c]='<path fill="'
    svg[c+1] = fill
    svg[c+2] = '" fill-opacity="'
    svg[c+3] = opacity
    svg[c+4] = '" stroke-opacity="'
    svg[c+5] = opacity
    svg[c+6] = '" d="M'
    svg[c+7] = tx
    svg[c+8] = ' '
    svg[c+9] = -size+ty
    svg[c+10] = 'L'
    svg[c+11] = -size+tx
    svg[c+12] = ' '
    svg[c+13] = sqrt3*size-size+ty
    svg[c+14] = 'L'
    svg[c+15] = size+tx
    svg[c+16] = ' '
    svg[c+17] = sqrt3*size-size+ty
    svg[c+18] = 'Z"/>'
    return c+19
end