local svg, index = projector.getSVG()

local width = system.getScreenWidth()
local height = system.getScreenHeight()

svg[index] =
[[
<style>
svg{ width:]]..width ..[[px; height:]]..height ..[[px; position:absolute; top:0px; left:0px;}
.Player{stroke: red; fill: white; text-align: center;}
.PlanetGroup{filter: drop-shadow(0 0 0.5rem black);}
.planets{ stroke: #defff0; fill: white; text-align: center;}
</style>]]
local rendered = table.concat(svg)
system.setScreen(rendered)