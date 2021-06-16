# Augmented Reality API

Hello there, I will warn you in advance, this is **not** for your average user. This is for other script developers to implement in their own scripts.

In summary, this is an **application programming interface**, API for short. This API allows a 1:1 presentation of something in the game world--i.e., it exists as if it were apart of the game world. It is an example of a high-level API. You provide it points, it does everything in the backend and produces the entire SVG for you.

  

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
|Func|A user-defined function which accepts the following functions in order: svg, c, object, x, y, z, where x, y, z are the transformed values of the point, relating to screen coordinates.

# Codex
### Object Group Functions
| Function Name | Description|
|--|--|
|ObjectGroup(style, objects, transX, transY)|How a group is made, objects, transX and transY are optional. Returns the object group|
|ObjectGroup#addObject(object, id)|Adds an object at a given index ID, the index ID is optional. Returns the index ID of the object|
|ObjectGroup#removeObject(id)|Removes an object from the group with a given ID index with an empty array.|
|Object#hide()|Halts processing of any objects within the object group, effectively "hiding" the objects.|
|Object#show()|Resumes processing of any objects within the object group, effectively "showing" the objects.|
### Object Functions
| Function Name | Description|
|--|--|
|Object(style, point, offset, orientation, positionType, orientationType, transX, transY)| Usually never used directly.|
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

#### Set Polylines

### Camera Functions

- Camera creation

- Setting a Position

- Setting Orientation

- Settings Manipulation

### Projection Functions

- Getting the view matrix

- Getting the object matices

- Getting the SVG

### Manager Functions

- Rotation matrix to quaternion

- Local to global

- Global to local

- Quaternion Multiplication, "division", inversion and subtraction.

### Simple Examples

- Rotating System

- Planet markers in the world.

- Polyline ship wireframe

### Advanced Examples

- Moons orbiting a planet with a planet orbitting a star system.

- Custom multiple point SVG addition

- Custon single point SVG addition

- Action assigned to a circle to display a label

- Damage Control (Visual example only)

### Technicals

- Mathematics

- Quaternions

- Matrices

# Object

An object represents an independent set of points. An object consists of its rotations, the point around which all the other points rotate and the point groups.

By default, you have four groups of point types: Polyline, Circle, Curve* and Custom.

As the names imply, each represents a basic SVG object.

Custom, however, is unique in that you define the entire draw function yourself.

  

There is one additional group called Sub-objects. Sub-objects have their own independent rotation. However, the point around which they rotate is affected by the main object’s rotation. Think how the Earth orbits the sun and the moon orbits the earth. The sun, the super object, will apply the “orbit rotation” to move the orbit of the earth. The earth, however, has its own rotation and thus rotated the moon around it.

I understand that may be a little hard to grasp, and the analogy doesn’t quite hold, but the basic idea is you can essentially have “linked” objects which would allow for far more complex projections.

  

# Object Functions

The object functions are the following:

- setPosition(x,y,z)

- setCircles(gId)

-

- setCustom(gId)

- addMultipointSVG()

- addSinglePointSVG()

- setCurves*

- setPolylines(gId)

- rotateHeading(heading)

- rotatePitch(pitch)

- rotateRoll(roll)

### Object Builder

### Setting the Position

### Setting Orientations

### Settings Manipulation

  

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
