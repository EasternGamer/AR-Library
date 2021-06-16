local sqrt, len, max, print = math.sqrt, string.len, math.max, system.print

local freelook = true --export: Enable freelook in first person mode.
local loadWaypoints = true --export: Enable to load waypoints from Archaegeo's HUD's DB.
local displayWarpCells = true --export: To display warp cells or not.
local archHudWaypointSize = 2 --export: The size in meters of an ArchHud waypoint
local archHudWPRender = 400 --export: The size in kilometers at which point ArchHud Waypoints do not render.
local maxWaypointSize = 800 --export: The Max Size of a waypoint in pixels.
local minWaypointSize = 15 --export: The min size of a waypoint in pixels.
local infoHighlight = 200 --export: The number of pixels within info is displayed.
fontsize = 20 --export: font size
colorWarp = "#ADD8E6" --export: Colour of warpable waypoints
nonWarp = "#FFA500" --export: Colour of non-warpable waypoints

waypoint = false
local waypointInfo = {
  {name = "Madis", center = {17465536,22665536,-34464}, radius=44300},
  {name = "Alioth", center = {-8,-8,-126303}, radius=126068},
  {name = "Thades", center = {29165536,10865536,65536}, radius=49000},
  {name = "Talemai", center = {-13234464,55765536,465536}, radius=57450},
  {name = "Feli", center = {-43534464,22565536,-48934464}, radius=60000},
  {name = "Sicari", center = {52765536,27165538,52065535}, radius=51100},
  {name = "Sinnen", center = {58665538,29665535,58165535}, radius=54950},
  {name = "Teoma", center = {80865538,54665536,-934463.94}, radius=62000},
  {name = "Jago", center = {-94134462,12765534,-3634464}, radius=61590},
  {name = "Lacobus", center = {98865536,-13534464,-934461.99}, radius=55650},
  {name = "Symeon", center = {14165536,-85634465,-934464.3}, radius=49050},
  {name = "Symeon", center = {14165536,-85634465,-934464.3}, radius=49050},
  {name = "ME", center ={2515342.2058,-99129540.3141,-1117557.9816}, radius=archHudWaypointSize},
  {name = "Ion", center = {2865536.7,-99034464,-934462.02}, radius=44950}
}

local function bTW(bool)
    if bool then
        return "enabled"
    else
        return "disabled"
    end
end

print("=======================")
print("DU AR Waypoint System")
print("=======================")
print("Concept: Archaegeo")
print("Coder  : EasternGamer")
print("=======================")
print("Settings")
print("=======================")
print("Freelook        : " .. bTW(freelook))
print("Disp. Warp Cells: " .. bTW(displayWarpCells))
print("Load saved WP   : " .. bTW(loadWaypoints))
print("Font Size       : " .. fontsize .. "px")
print("Max WP Render   : " .. archHudWPRender .. "km")
print("Max WP Size     : " .. maxWaypointSize .. "px")
print("Min WP Size     : " .. minWaypointSize .. "px")
print("ArchHUD WP Size : " .. archHudWaypointSize .. "m")
print("Info HL Distance: " .. infoHighlight .. "px")
print("=======================")

if loadWaypoints then
    if databank ~= nil then
        local getString = databank.getStringValue
        if getString ~= nil then
            local dbInfo = json.decode(getString("SavedLocations"))
            if dbInfo ~= nil then
                local size = #waypointInfo
                local dbInfoSize = #dbInfo
                local c = 0
                print("Found " .. dbInfoSize .. " waypoints in databank.")
                for i=1, #dbInfo do
                    local dbEntry = dbInfo[i]
                    local pos=dbEntry.position
                    waypointInfo[size+c+1] = {name=dbEntry.name, center={pos.x, pos.y, pos.z}, radius=archHudWaypointSize}
                    c=c+1
                end
                print("Loaded " .. c .. " waypoints.")
            else
                print('ERROR! No data to read.')
            end
        else
            print('ERROR! Incorrect slot used for databank.')
        end
    else
        print("ERROR! No slot connected to databank slot.")
    end
end

local position = {0,0,0}
local offsetPos = {0,0,0}
local orientation = {0,0,0}
local width = system.getScreenWidth() / 2
local height = system.getScreenHeight() / 2
local objectBuilder = ObjectBuilderLinear()

local camera = Camera(cameraTypes.player.construct, {0,0,0}, {0,0,0})

camera.setViewLock(not freelook)
projector = Projector(core, camera)

waypoints = {}

local warp = ObjectGroup("Warp")
local notwarp = ObjectGroup("NotWarp")
projector.addObjectGroup(warp)
projector.addObjectGroup(notwarp)

local function drawText(svg, c, x, y, text, opacity)
    svg[c] = '<text x="'
    svg[c+1] = x
    svg[c+2] = '" y="'
    svg[c+3] = y
    svg[c+4] = '" fill-opacity="'
    svg[c+5] = opacity
    svg[c+6] = '" stroke-opacity="'
    svg[c+7] = opacity
    svg[c+8] = '">'
    svg[c+9] = text
    svg[c+10] = '</text>'
    return c+11
end
local function drawHorizontalLine(svg, c, x, y, length, thickness)
    svg[c] = '<path fill="none" stroke-width="'
    svg[c+1] = thickness
    svg[c+2] = '" d="M'
    svg[c+3] = x
    svg[c+4] = ' '
    svg[c+5] = y
    svg[c+6] = ' h '
    svg[c+7] = length
    svg[c+8] = '"/>'
    return c+9
end
local maxD = sqrt(width*width + height*height)
local function drawInfo(svg, c, tx, ty, data)
    local distanceToMouse = sqrt(tx*tx + ty*ty)
    local font = fontsize
    local name,distance,warpCost,disKM,disM = data.getWaypointInfo()
    local keyframe = data.keyframe

    if distance > 500 then
        local id = data.subId
        local d = notwarp.addObject(waypoints[id][2], id)
        warp.removeObject(id)
    else
        local id = data.subId
        warp.addObject(waypoints[id][2], id)
        notwarp.removeObject(id)
    end
    c = drawHorizontalLine(svg, c, tx, ty + 3, len(name)*(font*0.7), 2)
    c = drawText(svg, c, tx, ty, name, 1)
    
    if distanceToMouse <= infoHighlight then
        if keyframe < 6 then
            data.keyframe = keyframe + 1
        end
    else
        if keyframe ~= 0 then
            data.keyframe = keyframe - 1
        end
    end
    local opacity = keyframe/6
    if distanceToMouse < 25 and waypoint then
        system.setWaypoint('::pos{0,0,' .. data.x ..',' .. data.y .. ',' .. data.z ..'}')
        waypoint = false
    end
    if keyframe > 0 then
        local disText = ''
        if disM <=1000 then
            disText = disM .. ' M'
        elseif disKM <= 200 then
            disText = disKM .. ' KM'
        else
            disText = distance .. ' SU'
        end
        c = drawText(svg, c, tx + 60 - keyframe*10, ty+font+5, disText, opacity)
        if displayWarpCells then
            c = drawText(svg, c, tx + 60 - keyframe*10, ty+(font+5)*2, warpCost .. ' Warp Cells', opacity)
        end
    end
    return c
end
local function draw(svg,c,object,tx,ty,tz,data)
    local distanceToMouse = sqrt(tx*tx + ty*ty)
    local r = data.radius
    local off = (((tz/1000)/200))/100
    local size = max(projector.getSize(r, tz, 100000000, minWaypointSize) - off, 5)
    if size >= maxWaypointSize or distanceToMouse > maxD or (r==archHudWaypointSize*1.25 and tz>archHudWPRender) then -- Don't display
        return c
    end
    svg[c] = '<circle cx="'
    svg[c+1] = tx
    svg[c+2] = '" cy="'
    svg[c+3] = ty
    svg[c+4] = '" r="'
    if r==archHudWaypointSize*1.25 then
        size = size /2
        svg[c+5] = size
        svg[c+6] = '" fill="' .. colorWarp .. '"/>'
    else
        svg[c+5] = size
        svg[c+6] = '" fill="none"/>'
    end
    c=c+7
    c=drawInfo(svg, c, tx + size + 5, ty - size + 5, data)
    return c
end

for ii = 1, #waypointInfo do
    local wDat = waypointInfo[ii]
    local wCenter = wDat.center
    local wName = wDat.name
    local wRadius = wDat.radius
    local waypoint = objectBuilder
				.setStyle(wName)
				.setPosition({0,0,0})
				.setOffset({0,0,0})
				.setOrientation({0,0,0})
				.setPositionType(positionTypes.globalP)
				.setOrientationType(orientationTypes.globalO)
				.build()
    
    local subId = warp.addObject(waypoint)
    local nsubId = notwarp.addObject(waypoint)
    notwarp.removeObject(nsubId)
    local waypointObject = Waypoint(wCenter[1],wCenter[2],wCenter[3], wRadius * 1.25, wName, subId)
    local customSVG = waypoint.setCustomSVGs(1, wName).addSinglePointSVG()
    waypoints[ii] = {wCenter, waypoint}
    customSVG.setPosition({wCenter[1], wCenter[2], wCenter[3]})
    	    .setData(waypointObject)
    	    .setDrawFunction(draw)
    	    .build()
end

unit.setTimer("fixed_1", 1/1000) --The timer to update the camera
unit.setTimer("update", 1/1000) -- The timer to update the screen
system.showScreen(1)
unit.hide()