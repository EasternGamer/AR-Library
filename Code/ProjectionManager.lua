function Projector(camera)
    local isClicked = false
    -- Localize frequently accessed data
    local utils = require("cpml.utils")

    --local library=library
    local core, system, manager = core, system, getManager()

    -- Localize frequently accessed functions
    --- Library-based function calls
    --local solve=library.systemResolution3

    --- System-based function calls
    local getWidth, getHeight, getFov, getMouseDeltaX, getMouseDeltaY, print =
        system.getScreenWidth,
        system.getScreenHeight,
        system.getFov,
        system.getMouseDeltaX,
        system.getMouseDeltaY,
        system.print

    --- Core-based function calls
    local getCWorldR, getCWorldF, getCWorldU, getCWorldPos =
        core.getConstructWorldRight,
        core.getConstructWorldForward,
        core.getConstructWorldUp,
        core.getConstructWorldPos

    --- Camera-based function calls
    local getCameraLocalPos = system.getCameraPos
    local getCameraWorldPos = system.getCameraWorldPos
    local getCamWorldFwd, getCamWorldRight, getCamWorldUp =
        system.getCameraWorldForward,
        system.getCameraWorldRight,
        system.getCameraWorldUp
    local getCamLocalFwd, getCamLocalRight, getCamLocalUp =
        system.getCameraForward,
        system.getCameraRight,
        system.getCameraUp

    --- Manager-based function calls
    ---- Quaternion operations
    local t3DP, rotToEuler, rotToQuat = manager.transPoint3D, manager.rotMatrixToEuler, manager.rotMatrixToQuat

    -- Localize Math functions
    local maths = math
    local sin, cos, tan, rad, deg, sqrt, atan, ceil, floor =
        maths.sin,
        maths.cos,
        maths.tan,
        maths.rad,
        maths.deg,
        maths.sqrt,
        maths.atan,
        maths.ceil,
        maths.floor
    local rnd = utils.round
    -- Projection infomation
    --- Screen Parameters
    local width, height = getWidth() * 0.5, getHeight() * 0.5

    --- FOV Paramters
    local vertFov = system.getCameraVerticalFov
    local horizontalFov = system.getCameraHorizontalFov
    local tanFov = rad(vertFov())

    --- Matrix Subprocessing
    local aspect = width / height
    local fnearDivAspect = width / tanFov
    --- Matrix Paramters
    local x0 = 1 / tanFov
    local y0 = x0 * aspect

    local objectGroups = {}

    local self = {objectGroups = objectGroups}

    function self.getSize(size, zDepth, max, min)
        local pSize = atan(size, zDepth) * (fnearDivAspect)
        local max = max or pSize
        local min = min or pSize
        if pSize >= max then
            return max
        elseif pSize <= min then
            return min
        else
            return pSize
        end
    end

    local function matrixToQuat(m11, m21, m31, m12, m22, m32, m13, m23, m33)
        local t = m11 + m22 + m33
        if t > 0 then
            local s = 0.5 / sqrt(t + 1)
            return (m32 - m23) * s, (m13 - m31) * s, (m21 - m12) * s, 0.25 / s
        elseif m11 > m22 and m11 > m33 then
            local s = 2 * sqrt(1 + m11 - m22 - m33)
            return 0.25 * s, (m12 + m21) / s, (m13 + m31) / s, (m32 - m23) / s
        elseif m22 > m33 then
            local s = 2 * sqrt(1 + m22 - m11 - m33)
            return (m12 + m21) / s, 0.25 * s, (m23 + m32) / s, (m13 - m31) / s
        else
            local s = 2 * sqrt(1 + m33 - m11 - m22)
            return (m13 + m31) / s, (m23 + m32) / s, 0.25 * s, (m21 - m12) / s
        end
    end

    function self.addObjectGroup(objectGroup, id)
        local index = id or #objectGroups + 1
        objectGroups[index] = objectGroup
        return index
    end

    function self.removeObjectGroup(id)
        objectGroups[id] = {}
    end

    local cUX, cUY, cUZ, cFX, cFY, cFZ, cRX, cRY, cRZ, sx, sy, sz, sw =
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil

    function self.getModelMatrix(mObject)
        local s, c = sin, cos
        local modelMatrices = {}

        -- Localize Object values.
        local objOri, objPos = mObject[10], mObject[12]
        local objPosX, objPosY, objPosZ = objPos[1], objPos[2], objPos[3]

        local cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ, sx, sy, sz, sw =
            cRX,
            cRY,
            cRZ,
            cFX,
            cFY,
            cFZ,
            cUX,
            cUY,
            cUZ,
            -sx,
            -sy,
            -sz,
            sw
        local wwx, wwy, wwz, www = objOri[1], objOri[2], objOri[3], objOri[4]

        local wx, wy, wz, ww = wwx, wwy, wwz, www
        if mObject[9] == 2 then
            local mx, my, mz, mw =
                wx * sw + ww * sx + wy * sz - wz * sy,
                wy * sw + ww * sy + wz * sx - wx * sz,
                wz * sw + ww * sz + wx * sy - wy * sx,
                ww * sw - wx * sx - wy * sy - wz * sz
            wx, wy, wz, ww = mx, my, mz, mw
        end
        if mObject[8] == 2 then
            return wx, wy, wz, ww, cRX * objPosX + cFX * objPosY + cUX * objPosZ, cRY * objPosX + cFY * objPosY +
                cUY * objPosZ, cRZ * objPosX + cFZ * objPosY + cUZ * objPosZ, objPosX, objPosY, objPosZ
        else
            local cWorldPos = getCWorldPos()
            local oPX, oPY, oPZ = objPosX - cWorldPos[1], objPosY - cWorldPos[2], objPosZ - cWorldPos[3]
            return wx, wy, wz, ww, oPX, oPY, oPZ, 
            cRX * oPX + cRY * oPY + cRZ * oPZ, 
            cFX * oPX + cFY * oPY + cFZ * oPZ, 
            cUX * oPX + cUY * oPY + cUZ * oPZ
        end
    end

    local function updateReferentials()
        local cU, cF, cR = getCWorldU(), getCWorldF(), getCWorldR()

        cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ = cR[1], cR[2], cR[3], cF[1], cF[2], cF[3], cU[1], cU[2], cU[3]
        sx, sy, sz, sw = matrixToQuat(cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ)
    end

    function self.getViewMatrix()
        updateReferentials()
        local id = camera.cType.id
        local fG, fL = id == 0, id == 1

        if fG or fL then -- To do and fix
            local s, c = sin, cos
            local cOrientation = camera.orientation
            local pitch, heading, roll = cOrientation[1] * 0.5, -cOrientation[2] * 0.5, cOrientation[3] * 0.5
            local sP, sR, sH = s(pitch), s(heading), s(roll)
            local cP, cR, cH = c(pitch), c(heading), c(roll)

            local cx, cy, cz, cw = sP * cR, sP * sR, cP * sR, cP * cR
            if fG then
                wx, wy, wz, ww = cx, cy, cz, cw
            else
                local mx, my, mz, mw =
                    sx * cw + sw * cx + sy * cz - sz * cy,
                    sy * cw + sw * cy + sz * cx - sx * cz,
                    sz * cw + sw * cz + sx * cy - sy * cx,
                    sw * cw - sx * cx - sy * cy - sz * cz
                wx, wy, wz, ww = mx, my, mz, mw
            end
        else
            local lEye = getCameraLocalPos()
            local lEyeX, lEyeY, lEyeZ = lEye[1], lEye[2], lEye[3]
            local lf, lr, lu, gf, gr, gu =
                getCamLocalFwd(),
                getCamLocalRight(),
                getCamLocalUp(),
                getCamWorldFwd(),
                getCamWorldRight(),
                getCamWorldUp()
            local lfx, lfy, lfz = lf[1], lf[2], lf[3]

            local dotX = lr[1] * lEyeX + lr[2] * lEyeY + lr[3] * lEyeZ
            local dotY = lfx * lEyeX + lfy * lEyeY + lfz * lEyeZ
            local dotZ = lu[1] * lEyeX + lu[2] * lEyeY + lu[3] * lEyeZ

            return gr[1], gr[2], gr[3], gf[1], gf[2], gf[3], gu[1], gu[2], gu[3], -dotX, -dotY, -dotZ, lEyeX, lEyeY, lEyeZ, lfx, lfy, lfz
        end
    end

    function self.getSVG(isvg, fc)
        local fullSVG = isvg or {}
        local fc = fc or 1

        local vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3, vw1, vw2, vw3, lCX, lCY, lCZ, VX, VY, VZ =
            self.getViewMatrix()
        local vx, vy, vz, vw = matrixToQuat(vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3)

        local atan, sort, format, unpack, concat, abs, getModelMatrix =
            atan,
            table.sort,
            string.format,
            table.unpack,
            table.concat,
            math.abs,
            self.getModelMatrix

        local function zSort(t1, t2)
            return t1[1] > t2[1]
        end

        local tanFov = tan(rad(horizontalFov() * 0.5))
        --system.print("Horizontal: " .. horizontalFov())
        --system.print("Vertical: " .. vertFov())
        --system.print("Calculated Vert: " .. math.deg(tanFov))

        --- Matrix Subprocessing
        local nearDivAspect = width / tanFov
        fnearDivAspect = nearDivAspect
        -- Localize projection matrix values
        local px1 = 1 / tanFov
        local pz3 = px1 * aspect

        local pxw = px1 * width
        local pzw = -pz3 * height
        -- Localize screen info
        local width = width
        local height = height
        local nxB, pxB, nyB, pyB = -width * 2, width * 2, -height * 2, height * 2
        local dptPercision = 1
        local objectGroups = objectGroups
        local svgBuffer = {}
        local alpha = 1
        for i = 1, #objectGroups do
            local objectGroup = objectGroups[i]
            if objectGroup.enabled == false then
                goto not_enabled
            end

            local objGTransX = objectGroup.transX or width
            local objGTransY = objectGroup.transY or height
            local objects = objectGroup.objects

            local avgZ, avgZC = 0, 0
            local zBuffer, aBuffer, aBC, zBC = {}, {}, 0, 0
            local unpackData, drawStringData, uC, dU = {}, {}, 1, 1
            local notIntersected = true
            for m = 1, #objects do
                local obj = objects[m]
                if obj[12] == nil then
                    goto is_nil
                end

                local mx, my, mz, mw, mw1, mw2, mw3, mXP, mYP, mZP = getModelMatrix(obj)

                local objStyle = obj[11]
                local vMX, vMY, vMZ, vMW =
                    mx * vw + mw * vx + my * vz - mz * vy,
                    my * vw + mw * vy + mz * vx - mx * vz,
                    mz * vw + mw * vz + mx * vy - my * vx,
                    mw * vw - mx * vx - my * vy - mz * vz

                local vMXvMX, vMYvMY, vMZvMZ = vMX * vMX, vMY * vMY, vMZ * vMZ

                local mXX, mXY, mXZ, mXW =
                    (1 - 2 * (vMYvMY + vMZvMZ)) * pxw,
                    2 * (vMX * vMY + vMZ * vMW) * pxw,
                    2 * (vMX * vMZ - vMY * vMW) * pxw,
                    (vw1 + vx1 * mw1 + vy1 * mw2 + vz1 * mw3) * pxw

                local mYX, mYY, mYZ, mYW =
                    2 * (vMX * vMY - vMZ * vMW),
                    1 - 2 * (vMXvMX + vMZvMZ),
                    2 * (vMY * vMZ + vMX * vMW),
                    (vw2 + vx2 * mw1 + vy2 * mw2 + vz2 * mw3)

                local mZX, mZY, mZZ, mZW =
                    2 * (vMX * vMZ + vMY * vMW) * pzw,
                    2 * (vMY * vMZ - vMX * vMW) * pzw,
                    (1 - 2 * (vMXvMX + vMYvMY)) * pzw,
                    (vw3 + vx3 * mw1 + vy3 * mw2 + vz3 * mw3) * pzw

                avgZ = avgZ + mYW
                avgZC = avgZC + 1

                local P0XD, P0YD, P0ZD = lCX - mXP, lCY - mYP, lCZ - mZP

                local customGroups, uiGroups = obj[4], obj[6]
                for cG = 1, #customGroups do
                    local customGroup = customGroups[cG]
                    local multiGroups = customGroup[2]
                    local singleGroups = customGroup[3]
                    for mGC = 1, #multiGroups do
                        local multiGroup = multiGroups[mGC]
                        local pts = multiGroup[1]
                        local tPoints = {}
                        local ct = 1
                        local mGAvg = 0
                        for pC = 1, #pts do
                            local p = pts[pC]
                            local x, y, z = p[1], p[2], p[3]
                            local pz = mYX * x + mYY * y + mYZ * z + mYW
                            if pz < 0 then
                                goto behindMG
                            end

                            tPoints[ct] = {
                                (mXX * x + mXY * y + mXZ * z + mXW) / pz,
                                (mZX * x + mZY * y + mZZ * z + mZW) / pz,
                                pz
                            }
                            mGAvg = mGAvg + pz
                            ct = ct + 1
                            ::behindMG::
                        end
                        if ct ~= 1 then
                            local drawFunction = multiGroup[2]
                            local data = multiGroup[3]
                            zBC = zBC + 1
                            zBuffer[zBC] = {
                                mGAvg/(ct-1),
                                tPoints,
                                data,
                                drawFunction
                            }
                        end
                    end
                    for sGC = 1, #singleGroups do
                        local singleGroup = singleGroups[sGC]
                        local p = singleGroup[1]
                        local x, y, z = p[1], p[2], p[3]
                        local pz = mYX * x + mYY * y + mYZ * z + mYW
                        if pz < 0 then
                            goto behindSingle
                        end

                        local drawFunction = singleGroup[2]
                        local data = singleGroup[3]
                        zBC = zBC + 1
                        zBuffer[zBC] = {
                            pz,
                            (mXX * x + mXY * y + mXZ * z + mXW) / pz,
                            (mZX * x + mZY * y + mZZ * z + mZW) / pz,
                            data,
                            drawFunction,
                            isCustomSingle = true
                        }
                        ::behindSingle::
                    end
                end

                for uiC = 1, #uiGroups do
                    local uiGroup = uiGroups[uiC]

                    local elements = uiGroup[2]
                    local modelElements = uiGroup[4]

                    for eC = 1, #modelElements do
                        local mod = modelElements[eC]
                        local mXO, mYO, mZO = mod[10], mod[11], mod[12]

                        local pointsInfo = mod[9]
                        local pointsX, pointsY, pointsZ = pointsInfo[1], pointsInfo[2], pointsInfo[3]
                        local tPointsX, tPointsY = {}, {}
                        local size = #pointsX
                        tPointsX[size] = false
                        tPointsY[size] = false

                        local xwAdd = mXX * mXO + mXY * mYO + mXZ * mZO + mXW
                        local ywAdd = mYX * mXO + mYY * mYO + mYZ * mZO + mYW
                        local zwAdd = mZX * mXO + mZY * mYO + mZZ * mZO + mZW

                        for index = 1, size do
                            local x, y, z = pointsX[index], pointsY[index], pointsZ[index]
                            local pz = mYX * x + mYY * y + mYZ * z + ywAdd
                            if pz > 0 then
                                tPointsX[index] = (mXX * x + mXY * y + mXZ * z + xwAdd) / pz
                                tPointsY[index] = (mZX * x + mZY * y + mZZ * z + zwAdd) / pz
                            end
                        end

                        local lX, lY, lZ = 0.26726, 0.80178, 0.53452
                        local ambience = 0.3
                        local planes = mod[13]
                        local planeNumber = #planes
                        zBuffer[zBC + planeNumber] = false
                        for p = 1, planeNumber do
                            local plane = planes[p]
                            local eXO, eYO, eZO = plane[1] + mXO, plane[2] + mYO, plane[3] + mZO
                            local eCZ = mYX * eXO + mYY * eYO + mYZ * eZO + mYW
                            if eCZ < 0 then
                                goto behindElement
                            end
                            local p0X, p0Y, p0Z = P0XD - eXO, P0YD - eYO, P0ZD - eZO

                            local NX, NY, NZ = plane[4], plane[5], plane[6]
                            local dotValue = p0X * NX + p0Y * NY + p0Z * NZ

                            if dotValue < 0 then
                                goto behindElement
                            end

                            local brightness = (lX * NX + lY * NY + lZ * NZ)
                            if brightness < 0 then
                                brightness = (brightness * 0.1) * (1 - ambience) + ambience
                            else
                                brightness = (brightness) * (1 - ambience) + ambience
                            end
                            local r, g, b = plane[8] * brightness, plane[9] * brightness, plane[10] * brightness

                            local indices = plane[7]
                            local data = {r, g, b}
                            local m = 4
                            local indexSize = #indices
                            data[m + indexSize * 2 - 1] = false

                            for i = 1, indexSize do
                                local index = indices[i]
                                local pntX = tPointsX[index]
                                if not pntX then
                                    goto behindElement
                                end

                                data[m] = pntX
                                data[m + 1] = tPointsY[index]
                                m = m + 2
                            end
                            zBC = zBC + 1
                            zBuffer[zBC] = {
                                eCZ,
                                plane[11],
                                eCZ,
                                data,
                                is3D = true
                            }

                            ::behindElement::
                        end
                    end
                    for eC = 1, #elements do
                        local el = elements[eC]
                        if not el[6] then
                            goto behindElement
                        end
                        local eO = el[10]
                        local eXO, eYO, eZO = eO[1], eO[2], eO[3]

                        local eCZ = mYX * eXO + mYY * eYO + mYZ * eZO + mYW
                        if eCZ < 0 then
                            goto behindElement
                        end
                        local eCX = mXX * eXO + mXY * eYO + mXZ * eZO + mXW
                        local eCY = mZX * eXO + mZY * eYO + mZZ * eZO + mZW
                        el[16].checkUpdate()

                        local actions = el[4]
                        local oRM = el[15]
                        local fw = -oRM[4]
                        local xxMult, xzMult, yxMult, yzMult, zxMult, zzMult

                        if fw ~= -1 then
                            local fx, fy, fz = oRM[1], oRM[2], oRM[3]
                            local rx, ry, rz, rw =
                                fx * vMW + fw * vMX + fy * vMZ - fz * vMY,
                                fy * vMW + fw * vMY + fz * vMX - fx * vMZ,
                                fz * vMW + fw * vMZ + fx * vMY - fy * vMX,
                                fw * vMW - fx * vMX - fy * vMY - fz * vMZ

                            local rxrx, ryry, rzrz = rx * rx, ry * ry, rz * rz
                            xxMult, xzMult = (1 - 2 * (ryry + rzrz)) * pxw, 2 * (rx * rz - ry * rw) * pxw
                            yxMult, yzMult = 2 * (rx * ry - rz * rw), 2 * (ry * rz + rx * rw)
                            zxMult, zzMult = 2 * (rx * rz + ry * rw) * pzw, (1 - 2 * (rxrx + ryry)) * pzw
                        else
                            xxMult, xzMult = mXX, mXZ
                            yxMult, yzMult = mYX, mYZ
                            zxMult, zzMult = mZX, mZZ
                        end

                        zBC = zBC + 1
                        if el[14] and actions[7] then
                            aBC = aBC + 1
                            local p0X, p0Y, p0Z = P0XD - eXO, P0YD - eYO, P0ZD - eZO

                            local NX, NY, NZ = el[11], el[12], el[13]

                            local t = -(p0X * NX + p0Y * NY + p0Z * NZ) / (VX * NX + VY * NY + VZ * NZ)
                            local px, py, pz = p0X + t * VX, p0Y + t * VY, p0Z + t * VZ

                            local oRM = el[15]
                            local ox, oy, oz, ow = oRM[1], oRM[2], oRM[3], oRM[4]
                            local oyoy = oy * oy
                            zBuffer[zBC] = {
                                eCZ,
                                el,
                                false,
                                eCX,
                                eCZ,
                                eCY,
                                xxMult, 
                                xzMult, 
                                yxMult, 
                                yzMult, 
                                zxMult, 
                                zzMult,
                                isUI = true
                            }
                            aBuffer[aBC] = {
                                eCZ,
                                el,
                                eCZ,
                                2 * ((0.5 - oyoy - oz * oz) * px + (ox * oy + oz * ow) * py + (ox * oz - oy * ow) * pz),
                                2 * ((ox * oz + oy * ow) * px + (oy * oz - ox * ow) * py + (0.5 - ox * ox - oyoy) * pz),
                                actions,
                                zBC
                            }
                        else
                            zBuffer[zBC] = {
                                eCZ,
                                el,
                                el[2],
                                eCX,
                                eCZ,
                                eCY,
                                xxMult, 
                                xzMult, 
                                yxMult, 
                                yzMult, 
                                zxMult, 
                                zzMult,
                                isUI = true
                            }
                        end

                        ::behindElement::
                    end
                end
                ::is_nil::
            end
            if aBC > 0 then
                local oldSelected, newSelected = uiGroups[1][3], false
                sort(aBuffer, zSort)
                for aC = aBC, 1, -1 do
                    local uiElmt = aBuffer[aC]

                    local el = uiElmt[2]

                    local hoverDraw, defaultDraw, clickDraw = el[1], el[2], el[3]
                    local drawForm = defaultDraw
                    local actions = el[4]

                    if notIntersected then
                        local eBounds = el[14]
                        if eBounds and actions[7] then
                            local pX, pZ = uiElmt[4], uiElmt[5]
                            local inside = false
                            if type(eBounds) == "function" then
                                inside = eBounds(pX, pZ, uiElmt[3])
                            else
                                local N = #eBounds + 1
                                local p1 = eBounds[1]
                                local p1x, p1y = p1[1], p1[2]
                                local offset = 0
                                for eb = 2, N do
                                    local mod = eb % N
                                    if mod == 0 then
                                        offset = 1
                                    end
                                    local p2 = eBounds[mod + offset]
                                    p1x, p1y = p1[1], p1[2]
                                    local p2x, p2y = p2[1], p2[2]
                                    local minY, maxY
                                    if p1y < p2y then
                                        minY, maxY = p1y, p2y
                                    else
                                        minY, maxY = p2y, p1y
                                    end

                                    if pZ > minY and pZ <= maxY then
                                        local maxX = p1x > p2x and p1x or p2x
                                        if pX <= maxX then
                                            if p1y ~= p2y then
                                                if p1x == p2x or pX <= (pZ - p1y) * (p2x - p1x) / (p2y - p1y) + p1x then
                                                    inside = not inside
                                                end
                                            end
                                        end
                                    end
                                    p1 = p2
                                end
                            end
                            if not inside then
                                goto broke
                            end
                            notIntersected = false
                            drawForm = hoverDraw
                            newSelected = uiElmt
                            local eO = el[10]
                            local identifier = actions[6]
                            if oldSelected == false then
                                local enter = actions[3]
                                if enter then
                                    enter(identifier, pX, pZ)
                                end
                            elseif newSelected[6] == oldSelected[6] then
                                if isClicked then
                                    drawForm = clickDraw
                                    local clickAction = actions[1]
                                    if clickAction then
                                        clickAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                        isClicked = false
                                    end
                                elseif isHolding then
                                    local holdAction = actions[2]
                                    drawForm = clickDraw
                                    if holdAction then
                                        hovered = true
                                        holdAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                    end
                                else
                                    local hoverAction = actions[5]

                                    if hoverAction then
                                        hovered = true
                                        hoverAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                    end
                                end
                            else
                                local enter = actions[3]
                                if enter then
                                    enter(identifier, pX, pY)
                                end
                                local leave = oldSelected[6][4]
                                if leave then
                                    leave(identifier, pX, pY)
                                end
                            end
                            ::broke::
                        end
                    end
                    zBuffer[uiElmt[7]][4] = drawForm
                end

                if newSelected == false and oldSelected then
                    local leave = oldSelected[6][4]
                    if leave then
                        leave()
                    end
                end
                uiGroups[1][3] = newSelected
            end
            sort(zBuffer, zSort)
            for zC = 1, zBC do
                local uiElmt = zBuffer[zC]
                if uiElmt.isUI then
                    local el = uiElmt[2]
                    local distance,el,drawForm,xwAdd,ywAdd,zwAdd,xxMult,xzMult,yxMult,yzMult,zxMult,zzMult=unpack(uiElmt)

                    local count = 1

                    local scale = el[5] or 1
                    local drawOrder = el[7]
                    local drawData = el[8]
                    local points = el[9]

                    local oUC = uC
                    if drawData then
                        local sizes = drawData["sizes"]
                        if sizes then
                            uC = uC + #sizes
                        end
                        uC = uC + #drawData
                    end

                    local broken = false
                    if not drawOrder then
                        for ePC = 1, #points, 2 do
                            local ex, ez = points[ePC] * scale, points[ePC + 1] * scale

                            local pz = yxMult * ex + yzMult * ez + ywAdd
                            if pz < 0 then
                                broken = true
                                break
                            end

                            distance = distance + pz
                            count = count + 1

                            unpackData[uC] = (xxMult * ex + xzMult * ez + xwAdd) / pz
                            unpackData[uC + 1] = (zxMult * ex + zzMult * ez + zwAdd) / pz
                            uC = uC + 2
                        end
                    else
                        for ePC = 1, #points, 2 do
                            local ex, ez = points[ePC] * scale, points[ePC + 1] * scale

                            local pz = yxMult * ex + yzMult * ez + ywAdd
                            if pz < 0 then
                                broken = true
                                break
                            end

                            distance = distance + pz
                            count = count + 1

                            local px = (xxMult * ex + xzMult * ez + xwAdd) / pz
                            local py = (zxMult * ex + zzMult * ez + zwAdd) / pz

                            local indexList = drawOrder[ePC] or {}
                            for i = 1, #indexList do
                                local index = indexList[i] + (uC - 1)
                                unpackData[index] = px
                                unpackData[index + 1] = py
                            end
                        end
                    end
                    mUC = uC
                    uC = oUC
                    if not broken and drawForm then
                        local depthFactor = distance / count
                        if drawData then
                            local drawDatCount = #drawData
                            local sizes = drawData["sizes"]
                            if sizes then
                                for i = 1, #sizes do
                                    local size = sizes[i]
                                    local tSW = type(size)
                                    if tSW == "number" then
                                        unpackData[uC] = atan(size, depthFactor) * nearDivAspect
                                    elseif tSW == "function" then
                                        unpackData[uC] = size(depthFactor, nearDivAspect)
                                    end
                                    uC = uC + 1
                                end
                            end
                            for dDC = 1, drawDatCount do
                                unpackData[uC] = drawData[dDC]
                                uC = uC + 1
                            end
                        end
                        drawStringData[dU] = drawForm
                        dU = dU + 1
                        uC = mUC
                    end
                elseif uiElmt.is3D then
                    local data = uiElmt[4]
                    for alm = 1, #data do
                        unpackData[uC] = data[alm]
                        uC = uC + 1
                    end
                    drawStringData[dU] = uiElmt[2]
                    dU = dU + 1
                elseif uiElmt.isCustomSingle then
                    local zDepth,x,y,data,drawFunction = uiElmt[1],uiElmt[2],uiElmt[3],uiElmt[4],uiElmt[5]
                    local unpackSize = #unpackData
                    drawStringData[dU] = drawFunction(x,y,zDepth,data,unpackData,uC) or '<text x=0 y=0>Error: N-CS</text>'
                    dU = dU + 1
                    local newUnpackSize = #unpackData
                    if unpackSize ~= newUnpackSize then
                        uC = newUnpackSize + 1
                    end
                else
                    local zDepth,points,data,drawFunction = uiElmt[1],uiElmt[2],uiElmt[3],uiElmt[4]
                    local unpackSize = #unpackData
                    drawStringData[dU] = drawFunction(points,data,unpackData,uC)
                    dU = dU + 1
                    local newUnpackSize = #unpackData
                    if unpackSize ~= newUnpackSize then
                        uC = newUnpackSize + 1
                    end
                end
            end
            
            local svg = {
                format(
                    '<svg viewbox="-%g -%g %g %g">',
                    objGTransX,
                    objGTransY,
                    width * 2,
                    height * 2
                ),
                format(
                    '<style> svg{width:%gpx;height:%gpx;position:absolute;top:0px;left:0px;} %s </style>',
                    width * 2,
                    height * 2,
                    objectGroup.style
                ),
                format(concat(drawStringData), unpack(unpackData)),
                '</svg>'
            }
            if avgZC > 0 then
                local dpth = avgZ / avgZC
                svgBuffer[alpha] = {dpth, concat(svg)}
                alpha = alpha + 1
                if objectGroup.glow then
                    local size
                    if objectGroup.scale then
                        size = atan(objectGroup.gRad, dpth) * nearDivAspect
                    else
                        size = objectGroup.gRad
                    end
                    svg[1] =
                        format(
                        '<svg viewbox="-%g -%g %g %g" class="blur">',
                        objGTransX,
                        objGTransY,
                        width * 2,
                        height * 2
                    )
                    svg[2] =
                        [[
                        <style> 
                            .blur {
                                filter: blur(]] ..
                        size .. [[px) saturate(3);
                            }
                        </style>]]
                    svgBuffer[alpha] = {dpth + 0.1, concat(svg)}
                    alpha = alpha + 1
                end
            end
            ::not_enabled::
        end
        sort(svgBuffer, zSort)
        local svgBufferSize = #svgBuffer
        if svgBufferSize > 0 then
            fc = fc - 1
            for dm = 1, svgBufferSize do
                fullSVG[fc + dm] = svgBuffer[dm][2]
            end
        end
        return fullSVG, fc + svgBufferSize + 1
    end
    return self
end