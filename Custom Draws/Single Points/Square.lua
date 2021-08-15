local function drawSquare(svg,c,size,fill,tx,ty,tz,opacity)
    svg[c]='<path fill="'
    svg[c+1] = fill
    svg[c+2] = '" fill-opacity="'
    svg[c+3] = opacity
    svg[c+4] = '" stroke-opacity="'
    svg[c+5] = opacity
    svg[c+6] = '" d="M'
    svg[c+7] = -size+tx
    svg[c+8] = ' '
    svg[c+9] = -size+ty
    svg[c+10] = 'L'
    svg[c+11] = size+tx
    svg[c+12] = ' '
    svg[c+13] = -size+ty
    svg[c+14] = 'L'
    svg[c+15] = size+tx
    svg[c+16] = ' '
    svg[c+17] = size+ty
    svg[c+18] = 'L'
    svg[c+19] = -size+tx
    svg[c+20] = ' '
    svg[c+21] = size+ty
    svg[c+22] = 'Z"/>'
    return c+23
end