local min = math.min
local function Slide()
    local left = {}
    local right = {}
    local up = {}
    local down = {}
    local self = {up=up,down=down,left=left,right=right}
    function left.execute(percentage, displacement)
        return displacement-displacement*percentage
    end
    function right.execute(percentage, displacement)
        return -displacement+displacement*percentage
    end
    function up.execute(percentage, displacement)
        return displacement-displacement*percentage
    end
    function down.execute(percentage, displacement)
        return -displacement+displacement*percentage
    end
    return self
end
local slideType = Slide()
local function animate(object,startFrame,endFrame,advance)
    local keyframe = object.keyframe
    if advance then
        if keyframe < endFrame and keyframe >= startFrame then
            keyframe = keyframe + 1
            object.keyframe = keyframe
        end
    else
        if keyframe > startFrame then
            keyframe = keyframe - 1
            object.keyframe = keyframe
        end
    end
    return keyframe
end
local function linearSlideFadeAnimation(object, startFrame, endFrame, slide, displace, advance)
    local keyframe = object.keyframe
    keyframe = animate(object,startFrame,endFrame,advance)
    local percentage = min((keyframe-startFrame),endFrame)/(endFrame-startFrame)
    return slide.execute(percentage, displace), percentage
end
local function linearFadeAnimation(object, startFrame, endFrame, advance)
    local keyframe = object.keyframe
    keyframe = animate(object,startFrame,endFrame,advance)
    return min((keyframe-startFrame),endFrame)/(endFrame-startFrame)
end