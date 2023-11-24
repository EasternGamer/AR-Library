
projector = Projector()
local objG1 = ObjectGroup()
objG1.setStyle([[svg{stroke-linejoin:round;stroke-linecap:round;fill:white}]])
objG1.setGlow(true, 5, false)
projector.addObjectGroup(objG1)
local objectBuilder = ObjectBuilderLinear()
UIHud = objectBuilder
    .setPositionType(positionTypes.localP)
    .setOrientationType(orientationTypes.localO)
    .build()
UIHud.setPosition(0,0,0)

t = true
local worldPos = construct.getWorldPosition()
Industry = objectBuilder
.setPositionType(positionTypes.localP)
.setOrientationType(orientationTypes.localO)
.build()

objG1.addObject(UIHud)
objG1.addObject(Industry)
pUI = UIHud.setUIElements()
unit.hideWidget()
system.showScreen(1)

local sillyBox = PathBuilder()
    .setFill('green', false)
    .setStroke('white', false)
    .setStrokeWidth(0.01, true)
    .setFillOpacity(0.4, false)
    .moveTo(-250,0)
    .cubicCurve(-300,0,-300,-200,-300,-200)
    .lineTo(300,-200)
    .smoothCubicCurve(300,0,250,0)
    .closePath()
    


box = pUI.createCustomDraw(0,0,0)
box.setPositionIsRelative(true)
box.usePathBuilder(sillyBox)
box.setScale(1/600)
box.setClickAction(function() system.print('Box Clicked') end)
box.rotateX(-30)
box.setBoundsScale(1/600)
box.build()


local box1 = pUI.createCustomDraw(0,0,0.001)
box1.usePathBuilder(sillyBox)
box1.setScale(1/600)
box1.setPositionIsRelative(true)
box1.rotateX(120)
box1.setClickAction(function() system.print('Box 1 Clicked') end)
box.addSubElement(box1)
box1.setBoundsScale(1/600)
box1.build()

box2 = pUI.createCustomDraw(0,0,-2/6)
box2.usePathBuilder(sillyBox)
box2.setScale(1/600)
box2.rotateXYZ(30,0,0)
box2.setPositionIsRelative(true)
box2.setClickAction(function() system.print('Box 2 Clicked') end)
box2.setBoundsScale(1/600)
box2.build()

box.addSubElement(box2)