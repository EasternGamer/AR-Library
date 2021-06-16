# Augmented Reality API

Hello there, I will warn you in advance, this is **not** for your average user. This is for other script developers to implement in their own scripts.

In summary, this is an **application programming interface**, API for short. This API allows a 1:1 presentation of something in the game world—i.e., it exists as if it were apart of the game world. It is an example of a high-level API. You provide it points, it does everything in the backend and produces the entire SVG for you.

  

That being said, you **can** do some pretty advanced stuff.

# Definitions
|Name/Variable| Meaning |
|--|--|
|svg| The table of the current SVG content|
|c| A counter variable holding the next index value for the SVG table|
|Object| An object is essentially a collection of point groups who's transformed positions rely on the object's rotations and position.|
|Group|A collection of points with its own graphic class|
|Group ID| A unique ID which is equilvent to the index number used to store the group.
|Style|The name of the class used for use in CSS|
|Scale|A value used to scale points for any particular group. It divides each point by the said scale. Think "1:scale"|
|Point| An array of three variables in the order x, y, z, with indices respectively 1, 2, 3, NOT VEC3!!!|
|Offset|Uses the same array structure as a point. Used to offset pre-calculated variables|
|Position Type|There are two types of positions, globalP and localP. This defines in what relation a position is. If it is local, it refers to construct coordinates. If it is global, it refers to world coordinates.|
|Orientation Type|There are two types of orientations, globalO and localO. This defines in what relation the object's rotation is in. If it is local, the rotation is in respect to the constuct. If it is global, it is in respect to the world.|
|TransX|The translation of the X value, primarily used for moving fixed camera views to the corner of your screen.|
|TransY|The translation of the Y value, primarily used for moving fixed camera views to the corner of your screen.|
|Resize|If text should automatically scale using perspective scalling|
|Size|The size of text in meters. *Not affected by scaling parameter*|
|Func|A user-defined function which accepts the following parameters in order: *svg, c, object, x, y, z*, where x, y, z are the transformed values of the point, relating to screen coordinates.
|Data|Literally anything. An object, a function, a number, a string, you name it, it can be it.|
|mDraw|A user-defined function which accepts the following parameters in order: *svg, c, object, points, data*|
|sDraw|A user-defined function which accepts the following parameters in order: *svg, c, object, x, y, z, data*|

# Codex
### Object Functions
| *Function Name* | *Description*|
|--|--|
|**Object(style, point, offset, orientation, positionType, orientationType, transX, transY)**| Usually never used directly.|
|Object#setPolylines(groupId, style, points, scale) |Sets a group of polylines|
|Object#setCircles(groupId, style, scale)|Initiates the circle builder|
|CircleBuilder#addCircle(point, radius, fill)|Adds a circle at the point with a given radius and fill colour|
|CircleBuilder#setLabel(label, resize, size, offX, offY)|Adds a label to the circle
|CircleBuilder#setActionFunction(func)|Adds a user defined function to be executed each time the point transformed point is calculated
|CircleBuilder#build()|Adds the circle to the circle group. Returns the circle object with its array index within the group
|Object#setCurves(groupId, style, scale)|Initiates the curve builders|
|CurveBuilder#circleBuilder()|Initiates the perspective circular curve builder. Returns CurveCircleBuilder|
|CurveCircleBuilder#createCircle(point, radius)|Creates a perspective circle at a given center point with a radius in meters. Returns PersCircle|
|PersCircle#setLabel(label, resize, size)|Adds a label at +X, -X, +Y and -Y with the given text.|
|PersCircle#build()|Adds the perspective circle to the curve group. Returns the array of the perspecitive circle and the index within the curve group|
|CurveBuilder#bezierBuilder()|Initiates the perspective bezier curve builder|
|BezierBuilder#TBD|TBD|
|BezierBuilder#TBD|TBD|
|BezierBuilder#TBD|TBD|
|BezierBuilder#TBD|TBD|
|BezierBuilder#build()|Adds the curve to the curve group|
|Object#setCustomSVGs(groupId, style, scale)|Initiates the custom SVG builders and returns CustomSVG|
|CustomSVG#addMultiPointSVG()|Initiates the multi-point SVG builder. Useful for anything that needs to be transformed and linked together. Think a box, or rectangle. Returns MPSVG|
|MPSVG#addPoint(point)|Adds a point, in order of addition, to the multipoint group|
|MPSVG#bulkSetPoints(points)|Overrides points. *No processing is done using this function. (No offset and no scaling)*
|MPSVG#setData(data)|Sets data associated with the points|
|MPSVG#setDrawFuncton(mDraw)|Sets a draw function to be called to send the processed points to|
|MPSVG#build()|Adds the point group, if valid, to the multipoint group
|CustomSVG#addSinglePointSVG()|Initiates the single point SVG builder. Useful for anything that needs only a point location. Think of pre-baked SVGs you just want to move around in the world. Returns SPSVG|
|SPSVG#setPosition(point)|Sets the point in the world to add it to.|
|SPSVG#setData(data)|Sets data associated with the points|
|SPSVG#setDrawFuncton(sDraw)|Sets a draw function to be called to send the processed point to|
|SPVG#build()|Adds the point, if valid, to the single point group.|
|Object#rotateHeading(heading)|Rotates the heading, i.e. the z-axis, of the object around the object's position. *Note: Heading is in degrees.*|
|Object#rotatePitch(pitch)|Rotates the pitch, i.e. the x-axis, of the object around the object's position. *Note: Pitch is in degrees.*|
|Object#rotateRoll(roll)|Rotates the roll, i.e. the y-axis, of the object around the object's position. *Note: Roll is in degrees.*|
|Object#setPosition(point)|Sets the position of an object.|
|Object#addSubObject(object, id)|Adds a sub object at a given ID, or if no ID is present, it will add it to end of the sub object array. Returns the index, ID.|
|Object#removeSubObject(id)|Replaces a sub object with an empty array at the given index, id.|
|Object#setSubObjects()|Initiates the sub object builder, essentially overriding the current sub objects. Returns the SubObjectBuilder|
|SubObjectBuilder#addSubObject(object)|Adds the sub object to the sub object array|

### ObjectBuilderLinear
This is a special way to build an object in which it must be built in a specific order.
The codex will list them in order of execution. For brevity, ObjectBuilderLinear will be listed as OBL.
|*Function*|*Description*|
|--|--|
|**OBL()**|Initiates the linear object builder.|
|OBL#setStyle(style)|Sets the style class of the object.|
|OBL#setPosition(point)|Sets the initial position of the object|
|OBL#setOffset(offset)|Sets the offset of the object's points|
|OBL#setOrientation(orientation)|Sets the default orientation of the object|
|OBL#setPositionType(positionType)|Sets the position type of the object|
|OBL#setOrientationType(orientationType)|Sets the orientation type of the object|
|OBL#setTranslation(transX,transY)|[Optional] Sets the translated position of the projection.|
|OBL#build()|Constructs the object.|
#### Example
 ```lua
 local objectBuilder = ObjectBuilderLinear()
 local waypoint = objectBuilder
				.setStyle(wName)
				.setPosition({0,0,0}) --x,y,z
				.setOffset({0,0,0}) --x,y,z
				.setOrientation({0,0,0}) --pitch,heading,roll
				.setPositionType(positionTypes.globalP)
				.setOrientationType(orientationTypes.globalO)
				.build()
 ```
### Object Group Functions
| *Function Name* | *Description*|
|--|--|
|**ObjectGroup(style, objects, transX, transY)**|How a group is made, objects, transX and transY are optional. Returns the object group|
|ObjectGroup#addObject(object, id)|Adds an object at a given index ID, the index ID is optional. Returns the index ID of the object|
|ObjectGroup#removeObject(id)|Removes an object from the group with a given ID index with an empty array.|
|Object#hide()|Halts processing of any objects within the object group, effectively "hiding" the objects.|
|Object#show()|Resumes processing of any objects within the object group, effectively "showing" the objects.|
#### Example
```lua
local warpable = ObjectGroup("Warp")
warpable.addObject(waypoint, 1)
```

### Camera Functions
There are two main types of camera, fixed and player. 
Each are broken down further with different behaviours and functions.
```lua
fixed = {
	fLocal,
	fGlobal
}
player = {
	jetpack,
    planet,
    construct,
    chair = {
       firstPerson = {
            mouseControlled,
            freelook
       },
       secondPerson, --Currently not supported
       thirdPerson --Currently not supported
    }
}
```
|*Functions*|*Description*|
|--|--|
|**Camera(camType, position, orientation)**|Camera type is any one of the above types, position is the point in space it is initially and orientation is an array in the order pitch, heading, roll.|
|Camera#rotateHeading(heading)|Rotates the heading, i.e. the z-axis, of the camera around the camera's position. *Note: Heading is in degrees.*|
|Camera#rotatePitch(pitch)|Rotates the pitch, i.e. the x-axis, of the camera around the camera's position. *Note: Pitch is in degrees.*|
|Camera#rotateRoll(roll)|Rotates the roll, i.e. the y-axis, of the camera around the camera's position. *Note: Roll is in degrees.*|
|Camera#setAlignmentType(camType)|Sets the camera type. Usually useful if you want to switch between a fixed camera view and a player camera view depending on a toggle.|
|Camera#setPosition(position)|Sets the camera's position relative to the type of camera it is.|
|Camera#setViewLock(isViewLocked)|This sets if the camera's angle should be moved by the mouse inside a seat. Useful for switching this on if you pilot using the mouse.|
|Camera#getAlignmentType(ax, ay, az, aw, bodyX, bodyY, bodyZ)|The quaternion x, y, z and w values of your rotation and the position of your body. Returns the camera type. *Not intended for external usage.*|
#### Example
```lua
local camera = Camera(cameraTypes.player.construct, {0,0,0}, {0,0,0})

camera.setViewLock(not freelook)
projector = Projector(core, camera)
```
### Projector Functions
Some of the functions provided here are not useful for the end user.
|*Functions*|*Description*|
|--|--|
|**Projector(core, camera)**|Creates the projector object.|
|Projector#getSize(size, zDepth, max, min)|Gets the physically projected radius of a given size, assuming the object was not rotated. Max is the max value in pixels and min is the min value of pixels. Both are optional|
|Projector#updateCamera()|This call updates the camera parameters if the camera type is of the player|
|Projector#addObjectGroup(objectGroup, id)|Adds an object group at a given index ID, or if no index ID is given, it will place it at the end of the array. Returns the ID of the object group.|
|Projector#removeObjectGroup(id)|Replaces the object group at the given index with an empty array.|
|Projector#getModelMatrices(object)|Gets the model matrices associated with the object. *Not intended for external use.* Returns an array of model matrices.|
|Projector#getViewMatrix()|Gets the view matrix of your camera. *Not intended for external use.*|
|Projector#getSVG()|Gets the SVG table and the latest index of autogenerated SVG content. **Critical for operation of this script.**|
#### Example
```lua
-- Defined in unit.start()
projector = Projector(core, camera)
projector.addObjectGroup(warpable)

system.showScreen(1)
unit.setTimer("fixed_1", 1/1000)
unit.setTimer("update", 1/1000)

-- In fixed_1
projector.updateCamera()

-- In update
local concat = table.concat
local svg, index = projector.getSVG()

local width = system.getScreenWidth()
local height = system.getScreenHeight()

svg[index] = [[
<style>
	svg{ 
		width:]] .. width .. [[px; 
		height:]] .. height .. [[px; 
		position:absolute; 
		top:0px; 
		left:0px;
	}
	.Warp{
		filter: drop-shadow(0 0 0.5rem red); 
		stroke: red;
		stroke-width: 3; 
		vertical-align:middle; 
		text-anchor:start; 
		fill: white; 
		font-family: Helvetica; 
		font-size: 20px;
	 }
</style>]]
local rendered = concat(svg)
system.setScreen(rendered)
```

### Manager Functions
Most people will not be using these functions.
|*Functions*|*Description*|
|--|--|
|**Manager()**|Creates the manager object|
|Manager#getLocalToWorldConverter()|Gets the function to convert local coordinates to world coordinates|
|Manager#getWorldToLocalConverter()|Gets the function to convert world coordinates to local coordinates.|
|Manager#getTrueWorldPos()|Gets the true world position of 0,0,0 in the construct. Returns x,y,z|
|Manager#getPlayerLocalPos(playerId)|Gets the local position of any given player ID, if in view. Returns x,y,z|
|Manager#rotationMatrixToQuaternion(rotM)|Gets the quaternion of a rotation matrix. Returns x,y,z,w|
|Manager#rotationMatrixToEuler(rotM)|Gets euler angles from a rotation matrix.|
|Manager#inverse(qX, qY, qZ, qW)|Gets the inverse of a quaternion.|
|Manager#multiply(ax, ay, az, aw, bx, by, bz, bw)|Multiplies two quaternions together.|
|Manager#divide(ax, ay, az, aw, bx, by, bz, bw)|Multiplies the inverse of ``b`` quaternion with the ``a`` quaternion to "divide" the ``a`` quaternion by the ``b`` quaternion.|
# Object

An object represents an independent set of points. An object consists of its rotations, the point around which all the other points rotate and the point groups.

By default, you have four groups of point types: Polyline, Circle, Curve* and Custom.

As the names imply, each represents a basic SVG object.

Custom, however, is unique in that you define the entire draw function yourself.

  

There is one additional group called Sub-objects. Sub-objects have their own independent rotation. However, the point around which they rotate is affected by the main object’s rotation. Think how the Earth orbits the sun and the moon orbits the earth. The sun, the super object, will apply the “orbit rotation” to move the orbit of the earth. The earth, however, has its own rotation and thus rotated the moon around it.

I understand that may be a little hard to grasp, and the analogy doesn’t quite hold, but the basic idea is you can essentially have “linked” objects which would allow for far more complex projections.

# Camera

The camera is a simple object used to process what type of camera you use or if you want to manually manipulate it in some way.

There are two super types of camera, fixed and player. If a camera is of type player, it means that the camera is linked directly to the player and will behave like AR.

Uses:

- For Augmented reality

- Walking around

- In first person in a seat

- Does not work in third person free-look

Fixed, on the other hand, is fixed to the point you designate it at, however, you can still move the camera using other camera functions.

There are two subtypes of fixed camera, global and local. A global camera refers to a camera in the world. A local camera refers to a camera fixed on a point in local construct coordinates.

Applications:

- “Static” views of a specific location. (Maps, solar systems etc, placed on your screen)

- Static HUD elements

- Virtual “CCTV” via screens.

  

# Camera Functions

### Getting perspective size

The function Projector#getSize(zDepth, size, max, min), where zDepth is the z parameter of a particular point, size is the size of the point in meters, max is the max size in pixels and min is the minimum size in pixels it will allow.

An example would be for a circle, if you want a circle’s size to change based on distance, but don’t want it to fill your entire screen or become so small you can’t see it, but still scale when you’re at the right distance, this is the perfect function. Another is for text. You want to change change the size text.

The value return of this is in pixels.

  

### Getting the model matrix

This function is called using Projector#getModelMatrix(object).

Where object is the object built using the object builder. This function is entirely for debugging purposes. It returns an array of 4x4 model matrices, where the first model matrix is the main object and any further entries are of sub objects. Matrices of Sub objects of sub objects do not form an array themselves within the original model matrices array, everything is “one dimensional”.

  

### Getting the view matrix

The function is called using Projector#getViewMatrix()

Like the model matrix function, this is almost exclusively for debugging purposes, but it essentially gives you the global 4x4 view matrix of your camera.

### Getting the SVG

The function Projector#getSVG() returns a table of the current generated SVG content and the current index value so you can continue the chain to add the CSS styling.

This function is required to display the projected code, of course, and it is the most computationally demanding function.

# Projector

The projector is the heart and soul of the entire API. It handles practically all the computations as efficiently as humanly practical. There are some places in which it can be improved, but code length is also a factor to consider.

The projector has multiple functions all exposed to you if you want to analyse information in depth.

For the projection to work, you need to update the camera in most cases. Updating the camera only refers to updating the camera orientation and position in the world if and only if it is a player-type camera. Otherwise, you manipulate it using the camera object in your own code.

  

# Projection Functions

  

# Manager

The manager is a basic object used to store functions such as the quaternion multiplication, matrix to quaternion and other misc. functions used in projection.

It’s mostly not important to use it.

  

# Manager Functions

###

# Examples

Since code by itself is difficult to understand, I've made a few simple examples and a few advanced examples to show you how you would code. Videos of each will be provided under each example.

## Simple Examples

### Rotating System

### Solar System Waypoints

## Advanced Examples

  

### Interactive AR Progress Bars

### Damage Control
