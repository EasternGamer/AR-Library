local far = 10000
local a0 = (right + left) / (right - left)
local b0 = (top + bottom) / (top - bottom)
local c0 = -(far + near) / (far - near)
local d0 = -2 * far * near / (far - near)
--- What the projection matrix actually looks like.
    ---- a0 is usually 0
    ---- b0 is usually 0
    local projectionMatrix = {
        x0, 0, a0,  0,
        0, y0, b0,  0,
        0,  0, c0, d0,
        0,  0, -1,  0
    }
function self.updateProjectionMatrix()
        --- Screen Parameters
        width = getWidth()/2
        height = getHeight()/2

        --- FOV Paramters
        hfovRad = rad(getFov());
        fov = 2*atan(tan(hfovRad/2)*height,width)

        --- Matrix Subprocessing
        tanFov = tan(fov/2)
        aspect = width/height
        near = width/tanFov
        top = near * tanFov
        bottom = -top;
        left = bottom * aspect
        right = top * aspect

        near = width/tanFov
        far = 10000
        aspect = width/height

        --- Matrix Paramters
        x0 = 2 * near / (right - left)
        y0 = 2 * near / (top - bottom)
        a0 = (right + left) / (right - left)
        b0 = (top + bottom) / (top - bottom)
        c0 = -(far + near) / (far - near)
        d0 = -2 * far * near / (far - near)
    
        m = sensitivity*(width*2)*0.00104584100642898 + 0.00222458611638299
end
    function self.rotMatrixToEuler(rM)
        local a=atan
        local m11,m21,m31,m12,m22,m32,m13,m23,m33=rM[1],rM[5],rM[9],rM[2],rM[6],rM[10],rM[3],rM[7],rM[11]
        local y=0
        
        if m13>=1 then y=asin(1)
        elseif m13<=-1 then y=asin(-1)
        else y=asin(m13) end
        if abs(m13)<0.9999999 then return {a(-m23,m33),-y,-a(-m12,m11)}
        else return {a(m32, m22),-y,-0}
        end
    end
	local function translate(x,y,z,mXX,mXY,mXZ,mXW,mYX,mYY,mYZ,mYW,mZX,mZY,mZZ,mZW)
            local x,y,z=x,-y,-z
            local pz = mYX*x+mYY*y+mYZ*z+mYW
            if pz>0 then
                return 0,0,-1
            end
            local px=mXX*x+mXY*y+mXZ*z+mXW
            local py=mZX*x+mZY*y+mZZ*z+mZW
            local pw=-pz
            -- Convert to window coordinates after W-Divide
            local wx=px/pw
            local wy=py/pw
            return wx,wy,pw
        end
        local function createCurve(svg,c,mx,my,cx1,cy1,cx2,cy2,ex,ey)
            svg[c]='M'
            svg[c+1]=mx
            svg[c+2]=' '
            svg[c+3]=my
            svg[c+4]='C'
            svg[c+5]=cx1
            svg[c+6]=' '
            svg[c+7]=cy1
            svg[c+8]=','
            svg[c+9]=cx2
            svg[c+10]=' '
            svg[c+11]=cy2
            svg[c+12]=','
            svg[c+13]=ex
            svg[c+14]=' '
            svg[c+15]=ey
            return c+16
        end
		 --[[
            local drawString = {"M"}
            local cC = 2
            local charFirst = charPI[1]

            for j = 1, length do
                local charPIn1, charPIn2 = charPI[j], charPI[j + 1]
                if j == 1 then
                    drawString[cC] = "%g %gL"
                elseif charPIn1 and charPIn2 and charPIn2 ~= charFirst and charPIn1 ~= charFirst then
                    drawString[cC] = "%g %gL"
                elseif charPIn1 == charFirst and j ~= 1 then
                    drawString[cC] = "Z"
                elseif charPIn1 then
                    drawString[cC] = "%g %g"
                else
                    drawString[cC] = " M"
                end
                cC = cC + 1
                if j == length then
                    if charPIn2 == charFirst then
                        drawString[cC] = "Z"
                    else
                        drawString[cC] = "%g %g"
                    end
                end
            end
            local t = concat(drawString) .. '\n'
            ]]
            --print(char[1])
	function self.setTriangles(groupId,style,scale)
        local points,normals,colors,triangles={},{},{},{}
        local group={style,points,normals,colors,triangles}
        local scale=(1/scale or 1)
        local vC,nC,cC,tC=1,1,1,1
        self[5][groupId]=group
        local offset=positionOffset
        local offsetX,offsetY,offsetZ=positionOffset[1],positionOffset[2],positionOffset[3]
        local self={}
        function self.bulkAddNormals(normalIn)
            local length=#normalIn
            for i=1,length,3 do
                normals[i]=normalIn[i]
                normals[i+1]=normalIn[i+1]
                normals[i+2]=normalIn[i+2]
            end
            return length*0.25
        end
        function self.bulkAddVertices(verts)
            local length=#verts
            local vrtC=1
            for i=1,length/3*4,4 do
                points[i]=verts[vrtC]*scale+offsetX
                points[i+1]=verts[vrtC+1]*scale+offsetY
                points[i+2]=verts[vrtC+2]*scale+offsetZ
                points[i+3]={2}
                vrtC=vrtC+3
            end
            vC=length+1
            return length*0.25
        end
        function self.bulkAddColors(colorIn)
            local length=#colorIn
            for i=1,#colorIn do
                colors[i]=colorIn[i]
            end
            return length
        end
        function self.bulkAddTriangles(trigs)
            local length=#trigs
            local points=points
            local triC=1
            local off=0
            for i=1,length,5 do
                local p1=trigs[i+1]*4
                local p2=trigs[i+2]*4
                local p3=trigs[i+3]*4

                local pI1,pI2,pI3=points[p1],points[p2],points[p3]
                pI1[pI1[1]],pI2[pI2[1]],pI3[pI3[1]]=triC,triC,triC
                pI1[1],pI2[1],pI3[1]=pI1[1]+1,pI2[1]+1,pI3[1]+1

                triangles[triC]=trigs[i]*3
                triangles[triC+1]=trigs[i+4]
                triC=triC+2

            end
            return length*0.2
        end
        function self.addVertex(x,y,z)
            points[vC]=x*scale+offsetX
            points[vC+1]=y*scale-offsetY
            points[vC+2]=z*scale-offsetZ
            points[vC+3]={}
            vC=vC+4
            return (vC-1)*0.25
        end
        function self.addNormal(x,y,z)
            normals[nC]=x
            normals[nC+1]=y
            normals[nC+2]=z
            nC=nC+3
            return (nC-1)*0.333333333
        end
        function self.addColor(color)
            colors[cC]=color
            cC=cC+1
            return cC-1
        end
        function self.addTriangle(pointIndices,normalIndex,colorIndex)
            local points=points
            local normalIndex=normalIndex*4
            for i=1,3 do
                local index=pointIndices[i]*4
                local pointInfo=points[index+3]
                pointInfo[#pointInfo+1]=tC
            end
            
            triangles[tC]=normalIndex
            triangles[tC+1]=pointIndices[1]
            triangles[tC+2]=pointIndices[2]
            triangles[tC+3]=pointIndices[3]
            triangles[tC+4]=colorIndex
            tC=tC+5
        end
        return self
    end
					for tG=1,#triangleGroups do
                        local trigGroup=triangleGroups[tG]
                        svg[c]='<g class="'
                        svg[c+1]=trigGroup[1]
                        svg[c+2]='">'
                        c=c+3
                        local points,normals,colors,trigs=trigGroup[2],trigGroup[3],trigGroup[4],trigGroup[5]
                        local tN,tI,tT={},{},{}
                        local cI=0

                        for nI=1,#normals,3 do
                            local x,y,z=normals[nI],normals[nI+1],normals[nI+2]
                            local nV=gWTLC({(mx1*x+my1*y+mz1*z),(mx2*x+my2*y+mz2*z),(mx3*x+my3*y+mz3*z)})
                            tN[nI]=nV[1]
                            tN[nI+1]=nV[2]
                            tN[nI+2]=nV[3]
                        end

                        for pI=1,#points,4 do
                            local x,y,z=points[pI],points[pI+1],points[pI+2]
                            local pz=mYX*x+mYY*y+mYZ*z+mYW
                            if pz<0 then goto behindTrig end
                            local px=(mXX*x+mXY*y+mXZ*z+mXW)/pz
                            if pxB<px or nxB>px then goto behindTrig end
                            local py=(mZX*x+mZY*y+mZZ*z+mZW)/pz
                            if pyB<py or nyB>py then goto behindTrig end
                            
                            local tIndices=points[pI+3]
                            local trans=gWTLC({(mx1*x+my1*y+mz1*z),mx2*x+my2*y+mz2*z,mx3*x+my3*y+mz3*z})
                            local tX,tY,tZ=trans[1],trans[2],trans[3]
                            for ctI=2,#tIndices do
                                local tIdx=tIndices[ctI]
                                local trig=tT[tIdx]
                                if trig==nil then

                                    local nI,cC=trigs[tIdx],trigs[tIdx+1]
                                    local nX,nY,nZ=tN[nI-2],tN[nI-1],tN[nI]
                                    
                                    local eyeX,eyeY,eyeZ=eyeX+tX,eyeY-tY,eyeZ-tZ
                                    local dot=eyeX*nX+eyeY*nY+eyeZ*nZ
                                    
                                    if dot>0 then
                                        cI=cI+1
                                        tT[tIdx]=cI
                                        tI[cI]={pz,px,py,0,0,0,0,4,colors[cC]}
                                    else
                                        tT[tIdx]=false
                                    end
                                elseif trig then
                                    local tDat=tI[trig]
                                    local tDI=tDat[8]
                                    tDat[1]=tDat[1]+pz
                                    tDat[tDI]=px
                                    tDat[tDI+1]=py
                                    tDat[8]=tDI+2
                                    --print(tDI+2)
                                end
                            end
                            
                            ::behindTrig::
                        end
                        --print("Point End")
                        zSort(tI,trigSort)
                        --print("Sort End")
                        for tIdx=1,cI do
                            local trigDat=tI[tIdx]

                            if trigDat[8]~=8 then goto invalid end
                            svg[c]='<path fill="'
                            svg[c+1]=trigDat[9]
                            svg[c+2]='" d="M'
                            svg[c+3]=trigDat[2]
                            svg[c+4]=' '
                            svg[c+5]=trigDat[3]
                            svg[c+6]=' L '
                            svg[c+7]=trigDat[4]
                            svg[c+8]=' '
                            svg[c+9]=trigDat[5]
                            svg[c+10]=' L '
                            svg[c+11]=trigDat[6]
                            svg[c+12]=' '
                            svg[c+13]=trigDat[7]
                            svg[c+14]=' V"/>'
                            c=c+15
                            ::invalid::
                        end
                        --print("SVG End")
                        svg[c]='</g>'
                        c=c+1
                    end
					--local pmXX,pmXY,pmXZ,pmXW=(vx1*mx1+vy1*mx2+vz1*mx3),(vx1*my1+vy1*my2+vz1*my3),(vx1*mz1+vy1*mz2+vz1*mz3),(vw1+vx1*mw1+vy1*mw2+vz1*mw3)
					--local pmZX,pmZY,pmZZ,pmZW=(vx3*mx1+vy3*mx2+vz3*mx3),(vx3*my1+vy3*my2+vz3*my3),(vx3*mz1+vy3*mz2+vz3*mz3),(vw3+vx3*mw1+vy3*mw2+vz3*mw3)
					
			--local a1,b1,c1 = 1-2*(ayay+azaz), 2*(ax*ay-az*aw), 2*(ax*az+ay*aw)
            --local d1,e1,f1 = 2*(ax*ay+az*aw), 1-2*(axax+azaz), 2*(ay*az-ax*aw)
            --local g1,h1,i1 = 2*(ax*az-ay*aw), 2*(ay*az+ax*aw), 1-2*(axax+ayay)
			
	    --local a2,b2,c2 = 1-2*(wywy+wzwz), 2*(wx*wy-wz*ww), 2*(wx*wz+wy*ww)
        --local d2,e2,f2 = 2*(wx*wy+wz*ww), 1-2*(wxwx+wzwz), 2*(wy*wz-wx*ww)
        --local g2,h2,i2 = 2*(wx*wz-wy*ww), 2*(wy*wz+wx*ww), 1-2*(wxwx+wywy)
			
			--print(string.format('{%.2f, %.2f,%.2f}', eyeIX, eyeIY, eyeIZ))
logCamUpdate = cL("Camera Update", "time")
logRefentialsUpdate = cL("Referentials", "time")

logMMatrices = cL("Model Matrices", "time")
logVMatrix = cL("View Matrix", "time")
logPreRead = cL("Pre-Read", "time")
logPreCalc = cL("Math Pre-Calc.", "time")

logUITotal = cL("UI Total", "time")
logUICompute = cL("UI Compute", "time")
logUISort = cL("UI Sort", "time")
logUIPost = cL("UI Post Proc.", "time")
logUIFormat = cL("UI Format", "time")

logLineTotal = cL("Line Total", "time")
logCircleTotal = cL("Circle Total", "time")
logCurveTotal = cL("Curve Total", "time")

logCustomTotal = cL("CTotal", "time")
logSingleTotal = cL("CS. Total", "time")
logSingleFunction = cL("CS. Function", "time")
logMultiTotal = cL("CM. Total", "time")
logMultiFunction = cL("CM. Function", "time")

logTriTotal = cL("Triangle Total", "time")
--logTriCompute = cL("Triangle Compute", "time")
--logTriSort = cL("Triangle Sort", "time")
--logTriFormat = cL("Triangle Format", "time")
function self.createTableDraw(tx, ty, tz)
            local tableTemplate = createUITemplate(tx, ty, tz)
            
            local userFuncOut = tableTemplate.user
            local rawFuncOut = tableTemplate.raw
            
            local heightOffset = 0
            local wO = 0
            local selectedButton = self.createButton(tx,ty,tz)
            
            local entry = {text, x, y, data, hoverAction, clickAction}
            local tableData = {
                entries = {
                    [1] = {
                        [1] = entry,
                        [2] = entry,
                        [3] = entry
                    },
                    [2] = {
                        [1] = entry,
                        [2] = entry,
                        [3] = entry
                    },
                    [3] = {
                        [1] = entry,
                        [2] = entry,
                        [3] = entry
                    }
                },
                columnSizes = {
                    [1] = 10,
                    [2] = 20,
                    [3] = 40
                },
                rowSizes = {
                    [1] = 10,
                    [2] = 5,
                    [3] = 10
                }
            }
            local function hoverEntry()
            end
            local function getTablePoints()
                local columnSizes = tableData.columnSizes
                local rowSizes = tableData.rowSizes
                
                local colSize = #columnSizes
                local rSize = #rowSizes
                
                local points = {}
                local pntIndex = 1
                
                local leftBar = {}
                local xPosMin = columnSizes[1]
                for rowIndex = 1, rSize do
                    points[pntIndex] = {xPosMin, rowSizes[rowIndex]}
                    leftBar[rowIndex] = pntIndex
                    pntIndex = pntIndex + 1
                end
                
                local rightBar = {}
                local xPosMax = columnSizes[colSize]
                for rowIndex = 1, rSize do
                    points[pntIndex] = {xPosMax, rowSizes[rowIndex]}
                    rightBar[rowIndex] = pntIndex
                    pntIndex = pntIndex + 1
                end
                
                
                local path = {'<path d="M%g %gL%g %gL%g %gL%g %g Z'}
                local drawOrder = {leftBar[1],leftBar[rSize],rightBar[rSize],rightBar[1]}
                local dOC = 5
                
                local topBar = {}
                local yPosMin = rowSizes[1]
                for colIndex = 2, colSize-1 do
                    points[pntIndex] = {columnSizes[colIndex], yPosMin}
                    topBar[colIndex-1] = pntIndex
                    pntIndex = pntIndex + 1
                end
                
                local yPosMax = rowSizes[rSize]
                for colIndex = 2, colSize-1 do
                    points[pntIndex] = {columnSizes[colIndex], yPosMax}
                    drawOrder[dOC] = pntIndex
                    drawOrder[dOC+1] = topBar[colIndex-1]
                    pntIndex = pntIndex + 1
                    dOC = dOC + 2
                    path[colIndex] = 'M%g %gL%g %g'
                end
                local lastPosition = colSize - 1
                for i=2, #rightBar-1 do
                    path[lastPosition + i] = 'M%g %gL%g %g'
                    drawOrder[dOC] = rightBar[i]
                    drawOrder[dOC+1] = leftBar[i]
                    dOC = dOC + 2
                end
                
                path[#path + 1] = '"/>'
                
            end
            
            --selectedButton.
            local function createEntry(x, y, w, h, text, fontSize, data, hA,cA)
                local txt = Text(text,fontSize,textAlignments.middle, textAlignments.middle)
                local button = self.createButton(x, y, tz)
                
                button.setDefaultDraw('<path stroke-width="%gpx" stroke="%s" fill="%s" d="M%g %g L%g %g L%g %g L%g %g Z"/>')
                button.setHoverAction(hA)
                button.setClickAction(cA)
                button.setText(text,0,-0.005,0)
                button.setDrawData(data)
                button.addPoints(getRectangle(w, h))
                button.build()
                return button
            end
            
            function columns.addColumn(name, w, h)
                columns[c] = {name, w, h, {}}
                c=c+1
                createEntry(tx+wO,ty,tz,w,h,name,h*0.9,{0.01, 'black', 'green'},hoverAction,clickAction)
                if heightOffset == 0 then
                    heightOffset = heightOffset - h*0.5
                end
                wO = wO + w
            end
            local notAdded = true
            function columns.addRow(row, h, stroke, strokeWidth, fill, clickAction, hoverAction)
                local widthOffset = 0
                local visible = true
                if notAdded then
                heightOffset = heightOffset - h*0.5
                    notAdded = false
                end
                for i=1, #columns do
                    local entry = row[i]
                    local column = columns[i]
                    local w = column[2]
                    
                    local rows = column[4]
                    rows[#rows+1] = {createEntry(tx+widthOffset,ty,tz+heightOffset,w,h,entry,h*0.9,{strokeWidth, stroke, fill},hoverAction,clickAction), w, h}
                    widthOffset = widthOffset + w
                end
                heightOffset = heightOffset - h
                function row.hide()
                    if visible then
                    end
                end
                function row.show()
                    if not visible then
                    end
                end
            end
            return columns
        end
		local function buildIndex()
                local drawOrder = {}
                local drawStrings = {'<path stroke-width="%gpx" stroke="%s" stroke-opacity="%g" fill="none" d="'}
                local indexOffset = 0
                local indexInput = 1
                for k = 1, #textCache do
                    local char = textCache[k]
                    local charIndex = char[2]
                    for m = 1, #charIndex do
                        local index = charIndex[m]
                        local order = drawOrder[index * 2 - 1 + indexOffset]
                        if not order then
                            order = {}
                            drawOrder[index * 2 - 1 + indexOffset] = order
                        end
                        order[#order + 1] = indexInput
                        indexInput = indexInput + 2
                    end
                    indexOffset = indexOffset + #char[1]
                    drawStrings[k + 1] = char[4]
                end
                rawFunc.setDrawOrder(drawOrder)
                drawStrings[#drawStrings+1] = '"/>'
                --system.print('Draw String Num: '..#drawStrings)
                userFunc.setDefaultDraw(concat(drawStrings))
            end
			local TEXT_ARRAY = {
    [10] = {{},{},16,'',10},--new line
    [32] = {{}, {}, 10,'',32}, -- space
    [33] = {{4, 0, 3, 2, 5, 2, 4, 4, 4, 12}, {1, 2, 3, 4, 5}, 10, 'M%g %gL%g %gL%g %gZ M%g %gL%g %g',33}, -- !
    [34] = {{2, 10, 2, 6, 6, 10, 6, 6}, {1, 2, 3, 4}, 6,'M%g %gL%g %g M%g %gL%g %g',34}, -- "
    [35] = {{0, 4, 8, 4, 6, 2, 6, 10, 8, 8, 0, 8, 2, 10, 2, 2}, {1, 2, 3, 4, 5, 6, 7, 8}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',35}, -- #
    [36] = {{6, 2, 2, 6, 6, 10, 4, 12, 4, 0}, {1, 2, 3, 4, 5}, 6,'M%g %gL%g %gL%g %g M%g %gL%g %g',36}, --$
    [37] = {{0, 0, 8, 12, 2, 10, 2, 8, 6, 4, 6, 2}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',37}, -- %
    [38] = {{8, 0, 4, 12, 8, 8, 0, 4, 4, 0, 8, 4}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',38}, --&
    [39] = {{0, 8, 0, 12}, {1, 2}, 2,'M%g %gL%g %g',39}, --'
    
    [40] = {{6, 0, 2, 4, 2, 8, 6, 12}, {1, 2, 3, 4}, 8,'M%g %gL%g %gL%g %gL%g %g',40}, --(
    [41] = {{2, 0, 6, 4, 6, 8, 2, 12}, {1, 2, 3, 4}, 8,'M%g %gL%g %gL%g %gL%g %g',41}, --)
    [42] = {{0, 0, 4, 12, 8, 0, 0, 8, 8, 8, 0, 0}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',42}, --*
    [43] = {{1, 6, 7, 6, 4, 9, 4, 3}, {1, 2, 3, 4}, 10,'M%g %gL%g %gM%g %gL%g %g',43}, -- +
    [44] = {{-1, -2, 1, 1}, {1, 2}, 4,'M%g %gL%g %g',44}, -- ,
    [45] = {{2, 6, 6, 6}, {1, 2}, 10,'M%g %gL%g %g',45}, -- -
    [46] = {{0, 0, 1, 0}, {1, 2}, 3,'M%g %gL%g %g',46}, -- .
    [47] = {{0, 0, 8, 12}, {1, 2}, 10,'M%g %gL%g %g',47}, -- /
    [48] = {{0, 0, 8, 0, 8, 12, 0, 12}, {1, 2, 3, 4, 1, 3}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',48}, -- 0
    [49] = {{5, 0, 5, 12, 3, 10}, {1, 2, 3}, 10,'M%g %gL%g %gL%g %g',49}, -- 1

    
    [50] = {{0, 12, 8, 12, 8, 7, 0, 5, 0, 0, 8, 0}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',50}, -- 2
    [51] = {{0, 12, 8, 12, 8, 0, 0, 0, 0, 6, 8, 6}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',51}, -- 3
    [52] = {{0, 12, 0, 6, 8, 6, 8, 12, 8, 0}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',52}, -- 4
    [53] = {{0, 0, 8, 0, 8, 6, 0, 7, 0, 12, 8, 12}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',53}, -- 5
    [54] = {{0, 12, 0, 0, 8, 0, 8, 5, 0, 7}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',54}, -- 6
    [55] = {{0, 12, 8, 12, 8, 6, 4, 0}, {1, 2, 3, 4}, 10,'M%g %gL%g %gL%g %gL%g %g',55}, -- 7
    [56] = {{0, 0, 8, 0, 8, 12, 0, 12, 0, 6, 8, 6}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',56}, -- 8
    [57] = {{8, 0, 8, 12, 0, 12, 0, 7, 8, 5}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',57}, -- 9
    [58] = {{4, 9, 4, 7, 4, 5, 4, 3}, {1, 2, 3, 4}, 2,'M%g %gL%g %g M%g %gL%g %g',58}, -- :
    [59] = {{4, 9, 4, 7, 4, 5, 1, 2}, {1, 2, 3, 4}, 5,'M%g %gL%g %g M%g %gL%g %g',59}, -- ;
    
    [60] = {{6, 0, 2, 6, 6, 12}, {1, 2, 3}, 6,'M%g %gL%g %gL%g %g',60}, -- <
    [61] = {{1, 4, 7, 4, 1, 8, 7, 8}, {1, 2, 3, 4}, 8,'M%g %gL%g %g M%g %gL%g %g',61}, -- =
    [62] = {{2, 0, 6, 6, 2, 12}, {1, 2, 3}, 6,'M%g %gL%g %gL%g %g',62}, -- >
    [63] = {{0, 8, 4, 12, 8, 8, 4, 4, 4, 1, 4, 0}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',63}, -- ?
    [64] = {{8, 4, 4, 0, 0, 4, 0, 8, 4, 12, 8, 8, 4, 4, 3, 6}, {1, 2, 3, 4, 5, 6, 7, 8}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',64}, -- @
    [65] = {{0, 0, 0, 8, 4, 12, 8, 8, 8, 0, 0, 4, 8, 4}, {1, 2, 3, 4, 5, 6, 7}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',65}, -- A
    [66] = {{0, 0, 0, 12, 4, 12, 8, 10, 4, 6, 8, 2, 4, 0}, {1, 2, 3, 4, 5, 6, 7}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gZ',66}, --B
    [67] = {{8, 0, 0, 0, 0, 12, 8, 12}, {1, 2, 3, 4}, 10,'M%g %gL%g %gL%g %gL%g %g',67}, -- C
    [68] = {{0, 0, 0, 12, 4, 12, 8, 8, 8, 4, 4, 0}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gZ',68}, -- D 
    [69] = {{8, 0, 0, 0, 0, 12, 8, 12, 0, 6, 6, 6}, {1, 2, 3, 4, 5, 6}, 10, 'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',69}, -- E
    
    
    [70] = {{0, 0, 0, 12, 8, 12, 0, 6, 6, 6}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',70}, -- F
    [71] = {{6, 6, 8, 4, 8, 0, 0, 0, 0, 12, 8, 12}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',71}, -- G
    [72] = {{0, 0, 0, 12, 0, 6, 8, 6, 8, 12, 8, 0}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',72}, -- H
    [73] = {{0, 0, 8, 0, 4, 0, 4, 12, 0, 12, 8, 12}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',73}, -- I
    [74] = {{0, 4, 4, 0, 8, 0, 8, 12}, {1, 2, 3, 4}, 10,'M%g %gL%g %gL%g %gL%g %g',74}, -- J
    [75] = {{0, 0, 0, 12, 8, 12, 0, 6, 6, 0}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %g M%g %gL%g %gL%g %g',75}, -- K
    [76] = {{8, 0, 0, 0, 0, 12}, {1, 2, 3}, 10,'M%g %gL%g %gL%g %g',76}, -- L
    [77] = {{0, 0, 0, 12, 4, 8, 8, 12, 8, 0}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',77}, -- M
    [78] = {{0, 0, 0, 12, 8, 0, 8, 12}, {1, 2, 3, 4}, 10,'M%g %gL%g %gL%g %gL%g %g',78}, -- N
    [79] = {{0, 0, 0, 12, 8, 12, 8, 0}, {1, 2, 3, 4}, 10,'M%g %gL%g %gL%g %gL%g %gZ',79}, -- O
    
    [80] = {{0, 0, 0, 12, 8, 12, 8, 6, 0, 5}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',80}, -- P
    [81] = {{0, 0, 0, 12, 8, 12, 8, 4, 4, 4, 8, 0}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',81}, -- Q
    [82] = {{0, 0, 0, 12, 8, 12, 8, 6, 0, 5, 4, 5, 8, 0}, {1, 2, 3, 4, 5, 6, 7}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',82}, -- R
    [83] = {{0, 2, 2, 0, 8, 0, 8, 5, 0, 7, 0, 12, 6, 12, 8, 10}, {1, 2, 3, 4, 5, 6, 7, 8}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',83}, -- S
    [84] = {{0, 12, 8, 12, 4, 12, 4, 0}, {1, 2, 3, 4}, 10,'M%g %gL%g %g M%g %gL%g %g',84}, -- T
    [85] = {{0, 12, 0, 2, 4, 0, 8, 2, 8, 12}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',85}, -- U
    [86] = {{0, 12, 4, 0, 8, 12}, {1, 2, 3}, 10,'M%g %gL%g %gL%g %g',86}, -- V
    [87] = {{0, 12, 2, 0, 4, 4, 6, 0, 8, 12}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',87}, -- W
    [88] = {{0, 0, 8, 12, 0, 12, 8, 0}, {1, 2, 3, 4}, 10,'M%g %gL%g %g M%g %gL%g %g',88}, -- X
    [89] = {{0, 12, 4, 6, 8, 12, 4, 6, 4, 0}, {1, 2, 3, 4, 5}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',89}, -- Y
    
    [90] = {{0, 12, 8, 12, 0, 0, 8, 0, 2, 6, 6, 6}, {1, 2, 3, 4, 5, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',90}, -- Z
    [91] = {{6, 0, 2, 0, 2, 12, 6, 12}, {1, 2, 3, 4}, 6,'M%g %gL%g %gL%g %gL%g %g',91}, -- [
    [92] = {{0, 12, 8, 0}, {1, 2}, 10,'M%g %gL%g %g',92}, -- \
    [93] = {{2, 0, 6, 0, 6, 12, 2, 12}, {1, 2, 3, 4}, 6,'M%g %gL%g %gL%g %gL%g %g',93}, -- ]
    [94] = {{2, 6, 4, 12, 6, 6}, {1, 2, 3}, 6,'M%g %gL%g %gL%g %g',94}, -- ^
    [95] = {{0, 0, 8, 0}, {1, 2}, 10,'M%g %gL%g %g',95}, -- _
    [96] = {{2, 12, 6, 8}, {1, 2}, 6,'M%g %gL%g %g',96}, -- `
    
    [123] = {{6, 0, 4, 2, 4, 10, 6, 12, 2, 6, 4, 6}, {1, 2, 3, 4, 5, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',123}, -- {
    [124] = {{4, 0, 4, 5, 4, 6, 4, 12}, {1, 2, 3, 4}, 6,'M%g %gL%g %g M%g %gL%g %g',124}, -- |
    [125] = {{4, 0, 6, 2, 6, 10, 4, 12, 6, 6, 8, 6}, {1, 2, 3, 4, 5, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',125}, -- }
    [126] = {{0, 4, 2, 8, 6, 4, 8, 8}, {1, 2, 3, 4}, 10,'M%g %gL%g %gL%g %gL%g %g',126}, -- ~
}

	 for d=1,#polylineGroups do
                        local polylineGroup = polylineGroups[d]
                        svg[c]=format('<path class="%s" d="%s"/>', polylineGroup[1])
                        c=c+1
                        
                        for f=2,#polylineGroup do
                            local line=polylineGroup[f]
                            svg[c]='M '
                            local lC=0
                            local sPX,sPY,ePX,ePY=nil,nil,nil,nil
                            c=c+1
                            for h=1,#line do
                                local p=line[h]
                                local x,y,z=p[1],p[2],p[3]

                                local pz=mYX*x+mYY*y+mYZ*z+mYW
                                if pz<0 then goto behindLine end

                                local wx=(mXX*x+mXY*y+mXZ*z+mXW)/pz
                                local wy=(mZX*x+mZY*y+mZZ*z+mZW)/pz
                                if lC~=0 then
                                    svg[c]=' L '
                                    c=c+1
                                    ePX,ePY=wx,wy
                                else
                                    sPX,sPY=wx,wy
                                end
                                svg[c]=wx
                                svg[c+1]=' '
                                svg[c+2]=wy
                                c=c+3
                                lC=lC+1
                                ::behindLine::
                            end
                            if lC < 2 then
                                if lC==1 then c=c-4
                                else c=c-1 end
                            else
                                if ePX==sPX and ePY==sPY then
                                    svg[c-4]=' Z '
                                    c=c-3
                                end
                            end
                        end
                        svg[c] = '"/>'
                        c=c+1
                    end
                    
                    for cG=1,#circleGroups do
                        local circleGroup=circleGroups[cG]
                        svg[c]=format('<g class="%s">', circleGroup[1])
                        c=c+1
                        for l=2,#circleGroup do
                            local cir=circleGroup[l]
                            local p=cir[1]
                            local x,y,z=p[1],p[2],p[3]
                            local pz=mYX*x+mYY*y+mYZ*z+mYW
                            if pz<0 then goto behindCircle end

                            local wx,wy=(mXX*x+mXY*y+mXZ*z+mXW)/pz,(mZX*x+mZY*y+mZZ*z+mZW)/pz
                            local radius,fill,label,offX,offY,size,resize,action=cir[2],cir[3],cir[4],cir[5],cir[6],cir[7],cir[8],cir[9]
                            svg[c]=format('<circle cx="%g" cy="%g" r="%g" fill="%s"/>',wx,wy,radius,fill);
                            c=c+1
                            if label then
                                svg[c]='<text x="';
                                svg[c+1]=wx+offX;
                                svg[c+2]='" y="';
                                svg[c+3]=wy+offY
                                c=c+4
                                if size then
                                    if resize==true then
                                        svg[c]='" font-size="';
                                        svg[c+1]=getSize(size,wz)
                                    else
                                        svg[c]='" font-size="';
                                        svg[c+1]=size
                                    end
                                    c=c+2
                                end
                                svg[c]='">';
                                svg[c+1]=label;
                                svg[c+2]='</text>'
                                c=c+3
                            end
                            if action then
                                c=action(svg,c,object,wx,wy,pz)
                            end
                            ::behindCircle::
                        end
                        svg[c]='</g>'
                        c=c+1
                    end
                    
                    for cuG=1,#curvesGroups do
                        
                        local curveG=curvesGroups[cuG]
                        local curves=curveG[2]
                        local sLabelDat={}
                        local sLDC=0

                        svg[c]=format('<g class="%s"><path d="',curveG[1])
                        c=c+1
                        for cCt=1,#curves do
                            local curve=curves[cCt]
                            if curve[1]==1 then
                                local pts=curve[2]
                                local labelDat=curve[3]
                                local tPts={}
                                for i=1,12 do
                                    local p=pts[i]
                                    local x,y,z=p[1],p[2],p[3]
                                    local pz=mYX*x+mYY*y+mYZ*z+mYW
                                    if pz<0 then tPts[i]={0,0,false}; goto continueCurve end

                                    tPts[i]={(mXX*x+mXY*y+mXZ*z+mXW)/pz,(mZX*x+mZY*y+mZZ*z+mZW)/pz,true}
                                    ::continueCurve::
                                end
                                local m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12=tPts[1],tPts[2],tPts[3],tPts[4],tPts[5],tPts[6],tPts[7],tPts[8],tPts[9],tPts[10],tPts[11],tPts[12]
                                local m1x,m1y,m1z,m2x,m2y,m3x,m3y,m4x,m4y,m4z=m1[1],m1[2],m1[3],m2[1],m2[2],m3[1],m3[2],m4[1],m4[2],m4[3]
                                if m1[3] and m1[3] and m1[3] and m4z then
                                    svg[c]=format('M%g %gC%g %g,%g %g,%g %g',m1x,m1y,m2x,m2y,m3x,m3y,m4x,m4y)
                                    c=c+1
                                end
                                local m5x,m5y,m6x,m6y,m7x,m7y,m7z=m5[1],m5[2],m6[1],m6[2],m7[1],m7[2],m7[3]
                                if m4z and m5[3] and m6[3] and m7z then
                                    svg[c]=format('M%g %gC%g %g,%g %g,%g %g',m4x,m4y,m5x,m5y,m6x,m6y,m7x,m7y)
                                    c=c+1
                                end
                                local m8x,m8y,m9x,m9y,m10x,m10y,m10z=m8[1],m8[2],m9[1],m9[2],m10[1],m10[2],m10[3]
                                if m7z and m8[3] and m9[3] and m10z then
                                    svg[c]=format('M%g %gC%g %g,%g %g,%g %g',m7x,m7y,m8x,m8y,m9x,m9y,m10x,m10y)
                                    c=c+1
                                end    
                                local m11x,m11y,m12x,m12y=m11[1],m11[2],m12[1],m12[2]
                                if m10z and m11[3] and m12[3] and m1z then
                                    svg[c]=format('M%g %gC%g %g,%g %g,%g %g',m10x,m10y,m11x,m11y,m12x,m12y,m1x,m1y)
                                    c=c+1
                                end
                                if labelDat[1] then
                                    if m1z and m4z and m7z and m10z then
                                        sLabelDat[sLDC+1]={{m1x,m1y,m1z},{m4x,m4y,m4z},{m7x,m7y,m7z},{m10x,m10y,m10z},labelDat}
                                        sLDC=sLDC+1
                                    end
                                end
                            else
                            end
                        end
                        svg[c]='"/>'
                        c=c+1
                        if sLDC>0 then
                            for ll=1,sLDC do
                                local lInfo=sLabelDat[ll]
                                local text=dat[1]
                                local s=dat[3]
                                for i=1,4 do
                                    local p=lInfo[i]
                                    local s=s
                                    if dat[2] then
                                        s=getSize(s,p[3],100,1)
                                    end
                                    
                                    svg[c]=format('<text x="%g" y="%g" fill="white" font-size="%g">%s</text>',p[1],p[2],s,text)
                                    c=c+1
                                end
                            end
                        end
                    end
					
	function self.setPolylines(groupId,style,points,scale)
        -- Polylines for-loop
        local group={style}
        local scale=scale or 1
        local offset=positionOffset
        local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
        for i=2,#points+1 do
            local line=points[i-1]
            local newPoints={}
            local counter=1
            for k=1,#line,3 do
                newPoints[counter]={line[k]/scale+offsetX,line[k+1]/scale-offsetY,line[k+2]/scale-offsetZ}
                counter=counter+1
            end
            group[i]=newPoints
        end
        self[1][groupId]=group
    end
    
    function self.setCircles(groupId,style,scale)
        local group={style}
        local scale=scale or 1
        local c=2
        self[2][groupId]=group
        local offset=offset or positionOffset
        local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
        local self={}
        function self.addCircle(position,radius,fill)
            local self={}
            local position={position[1]/scale+offsetX,position[2]/scale-offsetY,position[3]/scale-offsetZ}
            local label,offX,offY,size,resize,action = nil,nil,nil,nil,false,nil

            function self.setLabel(lab,rs,s,ofX,ofY)
                label=lab
                offX=ofX or 0
                offY=ofY or 0
                size=s or 10
                resize=rs or false
                return self
            end
            function self.setActionFunction(actionFunction)
                action=actionFunction
                return self
            end
            function self.build()
                local circleObj={position,radius,fill,label,offX,offY,size,resize,actionFunction}
                group[c]=circleObj
                c=c+1
                return circleObj,c
            end
            return self
        end
        return self
    end

    function self.setCurves(groupId,style,scale)
        local scale=scale or 1
        local curves= {}
        local group={style,curves}
        local offset=positionOffset
        local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
        self[3][groupId]=group
        local self={}
        local c=1
        function self.circleBuilder()
            local self={}
            function self.createCircle(center,radius)
                local k=0.5522847498307933984023
                local radius=radius/scale
                local cX,cY,cZ=center[1]/scale+offsetX,center[2]/scale-offsetY,center[3]/scale-offsetZ
                local cPoints={
                    {cX,radius+cY,cZ},{radius*k+cX,radius+cY,cZ},{radius+cX,radius*k+cY,cZ},
                    {radius+cX,cY,cZ},{radius+cX,-radius*k+cY,cZ},{radius*k+cX,-radius+cY,cZ},
                    {cX,-radius+cY,cZ},{-radius*k+cX,-radius+cY,cZ},{-radius+cX,-radius*k+cY,cZ},
                    {-radius+cX,cY,cZ},{-radius+cX,radius*k+cY,cZ},{-radius*k+cX,radius+cY,cZ}
                }
                local resize,size=false,10
                local labelDat={nil,resize,size}
                local self={}
                
                function self.setLabel(label,resize,size)
                    local resize=resize or false
                    local size=size*0.002 or 0.05
                    labelDat={label,resize,size}
                    return self
                end
                function self.build()
                    local persCircleArray={1,cPoints,labelDat}
                    curves[c]=persCircleArray
                    c=c+1
                    return persCircleArray,c
                end
                return self
            end
            return self
        end
        function self.bezierBuilder()
            local self={}
            function self.createCurve(sP)
            end
            function self.addControlPoint(cP)
            end
            function self.addEndPoint(eP)
            end
            return self
        end
        return self
    end
	
        local function createLabel(svg,c,x,y,text,size,opacity,fill)
            svg[c]='<text x="';svg[c+1]=x;svg[c+2]='" y="';svg[c+3]=y
            c=c+4
            if opacity then
                svg[c]='" fill-opacity="';svg[c+1]=opacity;svg[c+2]='" stroke-opacity="';svg[c+3]=opacity
                c=c+4
            end
            if fill then
                svg[c]='" fill="';svg[c+1]=fill
                c=c+2
            end
            if size then
                svg[c]='" font-size="';svg[c+1]=size
                c=c+2
            end
            svg[c]='">';svg[c+1]=text;svg[c+2]='</text>'
            return c+3
        end
		    local gCWOR,gCWOF,gCWOU,gCLOR,gCLOF,gCLOU,gCWR,gCWF,gCWU=core.getConstructWorldOrientationRight,core.getConstructWorldOrientationForward,core.getConstructWorldOrientationUp,core.getConstructOrientationRight,core.getConstructOrientationForward,core.getConstructOrientationUp,core.getConstructWorldRight,core.getConstructWorldForward,core.getConstructWorldUp
    local gWTLC,gLTWC=nil,nil
    
    function self.getLocalToWorldConverter()
        local s=solve
        local r,f,u=gCWR(),gCWF(),gCWU()
        local tr = {r[1],f[1],u[1]}
        local tf = {r[2],f[2],u[2]}
        local tu = {r[3],f[3],u[3]}
        return function(c)
            return s(tr, tf, tu, c)  
        end
    end

    function self.getWorldToLocalConverter()
        local xM,yM,zM=gCWR(),gCWF(),gCWU()
        local s = solve
        return function(w) return solve(xM,yM,zM,w) end
    end
    function self.quatToAxisAngle(ax,ay,az,aw)
        local awaw = 1/sqrt(1-aw*aw)

        return ax*awaw, ay*awaw, az*awaw, 2*acos(aw)
    end
	    function self.getPlayerLocalRotation()
        local fwd = unit.getMasterPlayerForward()
        local right = unit.getMasterPlayerRight()
        local up = unit.getMasterPlayerUp()

        return matrixToQuat(right[1],right[2],right[3],fwd[1],fwd[2],fwd[3],up[1],up[2],up[3])
    end
	function self.inverse(qX,qY,qZ,qW)
        return -qX,-qY,-qZ,qW
    end
    function self.inverseMulti(ax,ay,az,aw,bx,by,bz,bw)
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        return bx*(awaw-axax-ayay-azaz)+2*aw*(ax*bw+ay*bz-az*by),2*(bx*(aw*az+ax*ay)+bz*(ay*az-aw*ax))+by*(awaw-axax+ayay-azaz),2*(bx*(ax*az-aw*ay)+by*(ax*aw+ay*az))+bz*(awaw-axax-ayay+azaz),bw*(awaw+axax+ayay+azaz)
    end
    function self.transPoint3D(ax,ay,az,aw,bx,by,bz)
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        return 
        2*(by*(ax*ay-aw*az)+bz*(ax*az+aw*ay))+bx*(awaw+axax-ayay-azaz),
        2*(bx*(aw*az+ax*ay)+bz*(ay*az-aw*ax))+by*(awaw-axax+ayay-azaz),
        2*(bx*(ax*az-aw*ay)+by*(ax*aw+ay*az))+bz*(awaw-axax-ayay+azaz)
    end
    
    function self.transPoints3D(ax,ay,az,aw,points)
        
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        
        -- What I derived
        local a,b,c = (awaw+axax-ayay-azaz), 2*(ax*ay-aw*az), 2*(ax*az+aw*ay)
        local d,f,e = 2*(aw*az+ax*ay), (awaw-axax+ayay-azaz), 2*(ay*az-aw*ax)
        local g,h,i = 2*(ax*az-aw*ay), 2*(ax*aw+ay*az), (awaw-axax-ayay+azaz)
        
        local pts={}
        for i=1,#points,3 do
            local x,y,z=points[i],points[i+1],points[i+2]
            pts[i]=x*a+y*b+z*c
            pts[i+1]=x*d+y*e+z*f
            pts[i+2]=x*g+y*h+z*i
        end
        return pts
    end
    function self.transPoints2D(ax,ay,az,aw,points)
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        local b,c=2*(ax*az+aw*ay),(awaw+axax-ayay-azaz)
        local d,e=2*(aw*az+ax*ay),2*(ay*az-aw*ax)
        local g,i=2*(ax*az-aw*ay),(awaw-axax-ayay+azaz)
        local pts={}
        for i=1,#points,3 do
            local x,z=points[i],points[i+2]
            pts[i]=x*c+z*b
            pts[i+1]=x*d+z*e
            pts[i+2]=x*g+z*i
        end
        return pts
    end
    function self.multiply(ax,ay,az,aw,bx,by,bz,bw)
        return ax*bw+aw*bx+ay*bz-az*by,ay*bw+aw*by+az*bx-ax*bz,az*bw+aw*bz+ax*by-ay*bx,aw*bw-ax*bx-ay*by-az*bz
    end
    
    function self.transPoint2D(ax,ay,az,aw,x,y)
        local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
        return 2*z*(ax*az+aw*ay)+x*(awaw+axax-ayay-azaz),2*(x*(aw*az+ax*ay)+z*(ay*az-aw*ax)),2*x*(ax*az-aw*ay)+z*(awaw-axax-ayay+azaz)
    end
    gWTLC,gLTWC=self.getWorldToLocalConverter,self.getLocalToWorldConverter
	local function updateReferentials()
        local cU, cF, cR = getCWorldU(), getCWorldF(), getCWorldR()

        cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ = cR[1], cR[2], cR[3], cF[1], cF[2], cF[3], cU[1], cU[2], cU[3]
        sx, sy, sz, sw = matrixToQuat(cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ)
    end
	local oldX,oldY,oldZ,oldW
    local cLX,cLY,cLZ,cLW
    local lfT,lFT = 0,0
    local function lrp(ax,ay,az,aw, bx,by,bz,bw, s)
        local nX = ax + (ax-bx)*s
        local nY = ay + (ay-by)*s
        local nZ = az + (az-bz)*s
        local nW = aw + (aw-bw)*s
        local norm = (nX*nX+nY*nY+nZ*nZ+nW*nW)^(0.5)
	   return nX/norm,nY/norm,nZ/norm,nW/norm
    end
    
    function slerp(ax,ay,az,aw, bx,by,bz,bw, s)
        local dot = ax*bx+ay*by+az*bz+aw*bw
        --system.print(dot)
	   if dot < 0 then
            a = -a
            dot = -dot
        end
        --utils.clamp(dot, -1, 1)
        local theta = -math.acos(dot) * s
        --system.print(math.deg(theta))
        local cx,cy,cz,cw = bx-ax*dot,by-ay*dot,bz-az*dot,bw-aw*dot
        local norm = (cx*cx+cy*cy+cz*cz+cw*cw)^(0.5)
        local cosTheta,sinTheta=math.cos(theta),math.sin(theta)
        return ax * cosTheta + cx/norm * sinTheta,ay * cosTheta + cy/norm * sinTheta,az * cosTheta + cz/norm * sinTheta,aw * cosTheta + cw/norm * sinTheta
    end
	local tmpX,tmpY,tmpZ,tmpW = vx, vy, vz, vw
        if oldX and (lerp == 1 or lerp == 2) then
            if lerp==1 then
                vx,vy,vz,vw = lrp(vx,vy,vz,vw,oldX,oldY,oldZ,oldW,1)
            elseif lerp == 2 then
                vx,vy,vz,vw = slerp(vx,vy,vz,vw,oldX,oldY,oldZ,oldW,1)
            end
            vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3 = quatToMatrix(vx,vy,vz,vw)
            vw1, vw2, vw3 = -(vx1 * lCX + vy1 * lCY + vz1 * lCZ), 
                            -(vx2 * lCX + vy2 * lCY + vz2 * lCZ), 
                            -(vx3 * lCX + vy3 * lCY + vz3 * lCZ)
        end
        oldX,oldY,oldZ,oldW = tmpX,tmpY,tmpZ,tmpW
		local function quatToMatrix(x,y,z,w)
        local mXX, mXY, mXZ = 1 - 2*(y*y + z*z),2*(x*y + z*w),2*(x*z - y*w)
        local mYX, mYY, mYZ = 2*(x*y - z*w),1 - 2*(x*x + z*z),2*(y*z + x*w)
        local mZX, mZY, mZZ = 2*(x*z + y*w),2*(y*z - x*w),1 - 2*(x*x + y*y)
        return mXX, mXY, mXZ,mYX, mYY, mYZ,mZX, mZY, mZZ
    end