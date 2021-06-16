local concat = table.concat
local svg, index = projector.getSVG()

local width = system.getScreenWidth()
local height = system.getScreenHeight()
local fontsize = fontsize
svg[index] = '<style>svg{ width:'
svg[index+1] = width
svg[index+2] ='px; height:'
svg[index+3] =height
svg[index+4] ='px; position:absolute; top:0px; left:0px;}.NotWarp{filter: drop-shadow(0 0 0.5rem '
svg[index+5] =nonWarp
svg[index+6] ='); stroke: '
svg[index+7] =nonWarp
svg[index+8] ='; stroke-width: 3; vertical-align:middle; text-anchor:start; fill: white; font-family: Helvetica; font-size: '
svg[index+9] =fontsize
svg[index+10] ='px;}.Warp{filter: drop-shadow(0 0 0.5rem '
svg[index+11] =colorWarp
svg[index+12] ='); stroke: '
svg[index+13] =colorWarp
svg[index+14] ='; stroke-width: 3; vertical-align:middle; text-anchor:start; fill: white; font-family: Helvetica; font-size: '
svg[index+15] =fontsize
svg[index+16] ='px;}</style>'
local rendered = concat(svg)
system.setScreen(rendered)
--slot3.setHTML(rendered)