--==================================--
--==========Screen Update===========--
--==================================--
local timeStart = system.getArkTime()
local svg, deltaPreProcessing, deltaDrawProcessing, deltaEvent, deltaZSort, deltaZBufferCopy, deltaPostProcessing = projector.getSVG()
local delta = system.getArkTime() - timeStart
local floor = math.floor
local function WriteDelta(name, delta, suffix)
    return '<div>'.. name .. ':'.. floor((delta*100000))/100 .. suffix .. '</div>'
end
collectgarbage('collect')
if svg then
    system.setScreen(table.concat({
            svg,
            '<div>CPU Instructions: ', system.getInstructionCount() .. '/' .. system.getInstructionLimit() .. '</div>',
            WriteDelta('Memory',collectgarbage('count')/1000, 'kb'), 
            WriteDelta('Total',delta, 'ms'), 
            WriteDelta('Pre-Processing', deltaPreProcessing, 'ms'),
            WriteDelta('Draw Processing', deltaDrawProcessing, 'ms'),
            WriteDelta('Event', deltaEvent, 'ms'),
            WriteDelta('Z-Sorting', deltaZSort, 'ms'),
            WriteDelta('Z-Buffer Copy', deltaZBufferCopy, 'ms'),
            WriteDelta('Post Processing', deltaPostProcessing, 'ms')
        }))
end
--==================================--