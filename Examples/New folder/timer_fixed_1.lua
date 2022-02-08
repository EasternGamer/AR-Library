projector.updateCamera()
planets.rotateHeading(0.5)
local position = core.getConstructWorldPos()
local scale = 50000000
-- Sets the position of the ship, but since our previous version was scaled, so too should our position.
-- Additionally, we do need to move the position 5 meters forward because we moved our planet group 5 meters forward earlier.
ship.setPosition(position[1] / scale, position[2] / scale, position[3] / scale)