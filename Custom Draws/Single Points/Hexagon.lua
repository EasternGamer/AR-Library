local cos,sin,rad = math.cos,math.sin,math.rad
local function drawHex(svg,c,size,fill,tx,ty,tz,opacity)
    svg[c]='<path fill="'
    svg[c+1] = fill
    svg[c+2] = '" fill-opacity="'
    svg[c+3] = opacity
    svg[c+4] = '" stroke-opacity="'
    svg[c+5] = opacity
    svg[c+6] = '" d="M'
    c=c+7
    for i=1,6 do
        local angle = rad(60*i-30)
        local px = tx+(size*cos(angle))*2
        local py = ty+(size*sin(angle))*2
        svg[c] = px
        svg[c+1] = ' '
        svg[c+2] = py
        svg[c+3] = 'L'
        c=c+4
    end
    svg[c-1] = 'Z"/>'
    return c
end