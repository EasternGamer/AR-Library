local concat = table.concat
local svg, index = projector.getSVG()

local width = system.getScreenWidth()
local height = system.getScreenHeight()
svg[index] = '<style>svg{ width:'
svg[index+1] = width
svg[index+2] ='px; height:'
svg[index+3] =height
svg[index+4] ='px; position:absolute; top:0px; left:0px;}</style>'
local rendered = concat(svg)
system.setScreen(rendered)