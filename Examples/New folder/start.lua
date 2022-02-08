local position = {0,0,0}
local offsetPos = {0,0,0}
local safeZones = {
  {id = 1, name = "Madis", center = {17465536,22665536,-34464}, 
        satellites = {
            {id = 10, name = "Madis Moon 1", center = {17448118.224,22966846.286,143078.82}},
            {id = 11, name = "Madis Moon 2", center = {17194626,22243633.88,-214962.81}},
            {id = 12, name = "Madis Moon 3", center = {17520614,22184730,-309989.99}}
        }
  },
  {id = 2, name = "Alioth", center = {-8,-8,-126303}, 
        satellites = {
            {id = 21, name = "Alioth Moon 1", center = {457933,-1509011,115524}},
            {id = 22, name = "Alioth Moon 4", center = {-1692694,729681,-411464}},
            {id = 26, name = "Sanctuary Moon", center = {-1404835,562655,-285074}}
        }
  },
  {id = 3, name = "Thades", center = {29165536,10865536,65536}, 
        satellites = {
            {id = 30, name = "Thades Moon 1", center = {29214402,10907080.695,433858.2}},
            {id = 31, name = "Thades Moon 2", center = {29404193,10432768,19554.131}}
        }
  },
  {id = 4, name = "Talemai", center = {-13234464,55765536,465536}, 
        satellites = {
            {id = 42, name = "Talemai Moon 1", center = {-13058408,55781856,740177.76}},
            {id = 40, name = "Talemai Moon 2", center = {-13503090,55594325,769838.64}},
            {id = 41, name = "Talemai Moon 3", center = {-12800515,55700259,325207.84}}
        }
  },
  {id = 5, name = "Feli", center = {-43534464,22565536,-48934464}, 
        satellites = {
            {id = 50, name = "Feli Moon 1", center = {-43902841.78,22261034.7,-48862386}}
        }
  },
  {id = 6, name = "Sicari", center = {52765536,27165538,52065535}},
  {id = 7, name = "Sinnen", center = {58665538,29665535,58165535}, 
        satellites = {
            {id = 70, name = "Sinnen Moon 1", center = {58969616,29797945,57969449}}
        }
  },
  {id = 8, name = "Teoma", center = {80865538,54665536,-934463.94}},
  {id = 9, name = "Jago", center = {-94134462,12765534,-3634464}},
  {id = 100, name = "Lacobus", center = {98865536,-13534464,-934461.99}, 
        satellites = {
            {id = 102, name = "Lacobus Moon 1", center = {99180968,-13783862,-926156.4}},
            {id = 103, name = "Lacobus Moon 2", center = {99250052,-13629215,-1059341.4}},
            {id = 101, name = "Lacobus Moon 3", center = {98905288.17,-13950921.1,-647589.53}} 
        }
  },
  {id = 110, name = "Symeon", center = {14165536,-85634465,-934464.3}},
  {id = 120, name = "Ion", center = {2865536.7,-99034464,-934462.02}, 
        satellites = {
            {id = 121, name = "Ion Moon 1", center = {2472916.8,-99133747,-1133582.8}},
            {id = 122, name = "Ion Moon 2", center = {2995424.5,-99275010,-1378480.7}}
        }
  },
  {name = "Tutorial Planet", center = {84000000016.5690,92999999983.4165,54000000022.9705}}
}

local orientation = {0,0,0}
local width = system.getScreenWidth() / 2
local height = system.getScreenHeight() / 2
local objectBuilder = ObjectBuilderLinear()

local camera = Camera(cameraTypes.player.construct, {0,0,0}, {0,0,0})
projector = Projector(core, camera)

local planetGroup = ObjectGroup("PlanetGroup")
projector.addObjectGroup(planetGroup)

planets = objectBuilder
   			.setStyle("obj")
   			.setPosition({0,5,0}) --x,y,z
   			.setOffset({0,0,0}) --x,y,z
   			.setOrientation({0,0,0}) --pitch,heading,roll
   			.setPositionType(positionTypes.localP)
   			.setOrientationType(orientationTypes.localO)
   			.build()
ship = objectBuilder
				.setStyle("ship") -- Sets the class of this graphic
				.setPosition(position) -- Sets the position of the object, around which it rotates
				.setOffset(offsetPos) -- Sets the offset, usually not used but sometimes useful
				.setOrientation(orientation) -- Sets the default pitch, heading and roll (in degrees)
				.setPositionType(positionTypes.localP) -- Sets how the position relates to the world.
				.setOrientationType(orientationTypes.localO) -- Sets how the orientation relates to the world.
				.build() -- creates the object
planetGroup.addObject(planets)
-- Now to actually add data to the planets, we do the following.
local scale = 50000000 -- i.e. 1:50000000
local planetCircles = planets.setCircles(1, "planets", scale)
-- We use "set circles" because we we don't really care about scaling the object.
-- It also is just simpler this way.
for ii = 1, #safeZones do
    local safeZone = safeZones[ii]
    planetCircles --Position, size and fill respectively
    	.addCircle(safeZone.center, 5, "orange") -- I can add a circle in a chain like this.
    	.setLabel(safeZone.name) -- Adds the label to it. Labels are basic at the moment.
    	.build() -- Tells the program you are done with creating it and adds it.
end

ship.setCircles(1, "Player", 50000000).addCircle({0,0,0}, 3, "green").setLabel("Me").build()
-- ^ Adds a a green circle at 0,0,0 of the *object* with a radius of 3.
planets.addSubObject(ship)

unit.setTimer("fixed_1", 1/1000)
unit.setTimer("update", 1/1000)
system.showScreen(1)
unit.hide()