local position = {0,0,0}
local offsetPos = {0,0,0}
local orientation = {0,0,0}
local width = system.getScreenWidth() / 2
local height = system.getScreenHeight() / 2
local objectBuilder = ObjectBuilderLinear()

local camera = Camera(cameraTypes.player.construct, {0,0,0}, {0,0,0})
projector = Projector(core, camera)

local objG1 = ObjectGroup("ObjectGroup")
projector.addObjectGroup(objG1)

local rectangles = objectBuilder
				.setStyle("rectangles")
				.setPosition({0,0,0})
				.setOffset({0,0,0})
				.setOrientation({0,0,0})
				.setPositionType(positionTypes.localP)
				.setOrientationType(orientationTypes.localO)
				.build()
objG1.addObject(rectangles)

local utils = require("cpml.utils")
local round = utils.round
    
function toInteger(number)
    return math.floor(tonumber(number) or error("Could not cast '" .. tostring(number) .. "' to number.'"))
end

function getColourForProgressBar(progress)
    local convertedProgress = progress * 400
    local green = 0
    local red = 200
    if convertedProgress < 201 then
       green = toInteger(convertedProgress)
    elseif convertedProgress < 401 then
        green = 200
        red = 200 - (toInteger(convertedProgress) - 200)
    end
    return "rgb(" .. red .. "," .. green .. ",0)"
end

local function createRectangle3DXZ(center, length, height)
    local cX, cY, cZ = center[1], center[2], center[3]
    local height = height / 2
    local length = length / 2
    local p1 = {cX - length, cY, cZ + height}
    local p2 = {cX - length, cY, cZ - height}
    local p3 = {cX + length, cY, cZ - height}
    local p4 = {cX + length, cY, cZ + height}
    return {p1, p2, p3, p4}
end

function drawRectangle3D(svg, c, object, points, data)
    local svg = svg
    local c = c
    
    local points = points
    if #points == 4 then
        local p1 = points[1]
        local p2 = points[2]
        local p3 = points[3]
        local p4 = points[4]
        svg[c] = '\n<path fill="'
        svg[c + 1] = data
        svg[c + 2] = '" d="M'
        svg[c + 3] = p1[1]
        svg[c + 4] = ' '
        svg[c + 5] = p1[2]
        svg[c + 6] = ' L '
        svg[c + 7] = p2[1]
        svg[c + 8] = ' '
        svg[c + 9] = p2[2]
        svg[c + 10] = ' L '
        svg[c + 11] = p3[1]
        svg[c + 12] = ' '
        svg[c + 13] = p3[2]
        svg[c + 14] = ' L '
        svg[c + 15] = p4[1]
        svg[c + 16] = ' '
        svg[c + 17] = p4[2]
        svg[c + 18] = ' Z"/>'
        c = c + 19
    end
    return c
end

local customs = rectangles.setCustomSVGs(1, "rects", 1)
for i = 1, 10 do
    local multiPointSVG = customs.addMultiPointSVG()
    local rect = createRectangle3DXZ({0, i * 5, 0}, 5, 5)
    local draw = drawRectangle3D
    multiPointSVG.addPoint(rect[1])
    		   .addPoint(rect[2])
    		   .addPoint(rect[3])
    		   .addPoint(rect[4])
    		   .setData(getColourForProgressBar((i * 10) / 100))
    		   .setDrawFunction(draw)
    		   .build()
end

unit.setTimer("fixed_1", 1/1000)
unit.setTimer("update", 1/1000)
system.showScreen(1)
unit.hide()