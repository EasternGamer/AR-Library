function Projector(core, camera)
    -- Localize frequently accessed data
    local utils=require('cpml.utils')
    local library=library
    local core=core
    local unit=unit
    local system=system
    local manager=getManager()
    
    -- Localize frequently accessed functions
    --- Library-based function calls
    local solve=library.systemResolution3
    
    --- System-based function calls
    local getWidth=system.getScreenWidth
    local getHeight=system.getScreenHeight
    local getFov=system.getFov
    local getMouseDeltaX=system.getMouseDeltaX
    local getMouseDeltaY=system.getMouseDeltaY
    local getPlayerWorldPos=system.getPlayerWorldPos
    local print=system.print
    
    --- Core-based function calls
    local getCWorldPos=core.getConstructWorldPos
    local getCWorldOriR=core.getConstructWorldOrientationRight
    local getCWorldOriF=core.getConstructWorldOrientationForward
    local getCWorldOriU=core.getConstructWorldOrientationUp
    local getCLocalOriR=core.getConstructOrientationRight
    local getCLocalOriF=core.getConstructOrientationForward
    local getCLocalOriU=core.getConstructOrientationUp
    local getElementPositionById=core.getElementPositionById
    local getElementRotationById=core.getElementRotationById
    
    --- Unit-based function calls
    local getRelativeOrientation=unit.getMasterPlayerRelativeOrientation
    
    --- Camera-based function calls
    local getAlignmentType=camera.getAlignmentType
    
    --- Manager-based function calls
    ---- Positional Operations
    local getLocalToWorldConverter=manager.getLocalToWorldConverter
    local getWorldToLocalConverter=manager.getWorldToLocalConverter
    local getTrueWorldPos=manager.getTrueWorldPos
    local getPlayerLocalPos=manager.getPlayerLocalPos
    ---- Quaternion operations
    local inverse,multiply,divide,rotToEuler,rotToQuat=manager.inverse,manager.multiply,manager.divide,manager.rotMatrixToEuler,manager.rotMatrixToQuat
    
    -- Localize Math functions
    local sin,cos,tan,rad,deg,sqrt,atan,ceil,floor=math.sin,math.cos,math.tan,math.rad,math.deg,math.sqrt,math.atan,math.ceil,math.floor

    -- Projection infomation
    --- Screen Parameters
    local width = getWidth()*0.5
    local height = getHeight()*0.5

    --- FOV Paramters
    
    --local offset = (width + height) / 5000
    local offset=0
    local hfovRad=rad(getFov()+offset)
    local tanFov=tan(hfovRad*0.5)*height/width

    --- Matrix Subprocessing
    local aspect=width/height
    local near=width/tanFov
    local top=near*tanFov
    local bottom=-top
    local left=bottom*aspect
    local right=top*aspect

    --- Matrix Paramters
    local x0=2*near/(right-left)
    local y0=2*near/(top-bottom)
    
    -- Player-related values
    local playerId=unit.getMasterPlayerId()
    local unitId=unit.getId()
    
    -- Camera-Related values
    local eye=camera.position
    local cOrientation=camera.orientation
    local cameraType=camera.cType
    local alignmentType=nil
    
    --- Mouse info
    local sensitivity=1 --export: Sensitivtiy
    local m=sensitivity*(width*2)*0.00104584100642898+0.00222458611638299

    local bottomLock=false
    local topLock=false
    local rightLock=false
    local leftLock=false

    local objectGroups={}
    
    local self={objectGroups=objectGroups}

    function self.getSize(size,zDepth,max,min)
        local pSize=atan(size,zDepth)*(near/aspect)
        local max=max or pSize
        local min=min or pSize
        if pSize>=max then return max
        elseif pSize<=min then return min
        else return pSize end
    end
    
    function self.updateCamera()
        if cameraType.name~="fGlobal" and cameraType.name~="fLocal" then
            -- Localize variables
            local atan=atan
            
            eye=getPlayerLocalPos(playerId)

            local deltaMouseX,deltaMouseY=getMouseDeltaX(),getMouseDeltaY()
            local width=width
            local deltaPitch=atan(-deltaMouseY,width)*m
            local deltaHeading=atan(deltaMouseX,width)*m
        
            local pPitch=cOrientation[1]
            local pHeading=cOrientation[2]
            
            local alignType=alignmentType
            if alignType==nil then alignType=getAlignmentType() end
            
            local pitPos,pitNeg=alignType.pitchPos,alignType.pitchNeg
            local headPos,headNeg=alignType.headingPos,alignType.headingNeg
            
            if pitPos~=nil then
                if not(bottomLock or topLock) then  
                    pPitch=pPitch+deltaPitch
                    if pPitch<=pitNeg then
                        pPitch=pitNeg
                        bottomLock=true
                    end
                    if pPitch>=pitPos then
                        pPitch=pitPos
                        topLock=true
                    end
                else
                    if bottomLock and deltaMouseY<0 then
                        bottomLock=false
                        pPitch=pPitch+deltaPitch
                    end
                    if topLock and deltaMouseY>0 then
                        topLock=false
                        pPitch=pPitch+deltaPitch
                    end
                end
                cOrientation[1]=pPitch
            else
                cOrientation[1]=0
            end
            if headPos ~= nil then
                if not(leftLock or rightLock) then  
                    pHeading=pHeading+deltaHeading
                    if pHeading<=headNeg then
                        pHeading=headNeg
                        leftLock=true
                    end
                    if pHeading>=headPos then
                        pHeading=headPos
                        rightLock=true
                    end
                else
                    if rightLock and deltaMouseX<0 then
                        rightLock=false
                        pHeading=pHeading+deltaHeading
                    end
                    if leftLock and deltaMouseX>0 then
                        leftLock=false
                        pHeading=pHeading+deltaHeading
                    end
                end
                cOrientation[2]=pHeading
            else
                cOrientation[2]=0
            end
        end
    end

    function self.addObjectGroup(objectGroup, id)
        local index=id or #objectGroups+1
        objectGroups[index]=objectGroup
        return index
    end

    function self.removeObjectGroup(id)
    	objectGroups[id]={}
    end
    
    local sx,sy,sz,sw = 0,0,0,1
    local lx,ly,lz,lw = 0,0,0,1
    local cUX,cUY,cUZ = nil,nil,nil
    local cFX,cFY,cFZ = nil,nil,nil
    local cRX,cRY,cRZ = nil,nil,nil
    
    function self.getModelMatrices(mObject)
        local s,c,multi,inverse=sin,cos,multiply,inverse
        local modelMatrices={}
            
        -- Localize Object values.
        local obj=mObject
        local objOri=obj[9]
        local objPos=obj[11]
        local objPosX,objPosY,objPosZ=objPos[1],objPos[2],objPos[3]
        
        local cUX,cUY,cUZ=cUX,cUY,cUZ
        local cFX,cFY,cFZ=cFX,cFY,cFZ
        local cRX,cRY,cRZ=cRX,cRY,cRZ
        local sx,sy,sz,sw=sx,sy,sz,sw
        
        local recurse={}
        local ct=2
        function recurse.subObjectMatrices(kx,ky,kz,kw,sObjX,sObjY,sObjZ,object,posLX,posLY,posLZ)
            local objPos=object[11]
            local objRot=object[9]
            local objX,objY,objZ=objPos[1],objPos[2],objPos[3]
            
            local objP,objH,objR=objRot[1]*0.5,objRot[2]*0.5,objRot[3]*0.5
            local sP,sH,sR=s(objP),s(objR),s(objH)
            local cP,cH,cR=c(objP),c(objR),c(objH)
    
            local wwx,wwy,wwz,www=sP*cH*cR-cP*sH*sR,cP*sH*cR+sP*cH*sR,cP*cH*sR-sP*sH*cR,cP*cH*cR+sP*sH*sR
            local wx,wy,wz,ww=wwx,wwy,wwz,www

            local lix,liy,liz,liw=inverse(kx,ky,kz,kw)
            
            local posTX,posTY,posTZ,posTW=multi(kx,ky,kz,kw,objX,objY,objZ,0)

            local posIX=-posTX*liw+posTW*lix-posTY*liz-posTZ*liy
            local posIY=posTY*liw+posTW*liy+posTZ*lix-posTX*liz
            local posIZ=-posTZ*liw+posTW*liz+posTX*liy+posTY*lix
            if object[7]==2 then
                local dotX=cRX*posIX+cFX*posIY+cUX*posIZ
                local dotY=cRY*posIX+cFY*posIY+cUY*posIZ
                local dotZ=cRZ*posIX+cFZ*posIY+cUZ*posIZ
                posIX=dotX
                posIY=dotY
                posIZ=dotZ
            end
            posIX,posIY,posIZ=posIX+posLX,posIY+posLY,posIZ+posLZ
            if object[8]==2 then
                wx,wy,wz,ww=multi(wx,wy,wz,ww,sx,sy,sz,sw)
            end
            
            local wxwx,wxwy,wxwz,wxww,wywy,wywz,wyww,wzwz,wzww=wx*wx,wx*wy,wx*wz,wx*ww,wy*wy,wy*wz,wy*ww,wz*wz,wz*ww
            local a1 = 1-2*(wywy+wzwz)
            local b1 = 2*(wxwy-wzww)
            local c1 = 2*(wxwz+wyww)
    
            local d1 = 2*(wxwy+wzww)
            local e1 = 1-2*(wxwx+wzwz)
            local f1 = 2*(wywz-wxww)
    
            local g1 = 2*(wxwz-wyww)
            local h1 = 2*(wywz+wxww)
            local i1 = 1-2*(wxwx+wywy)
            
            modelMatrices[ct]={object,{a1,-d1,-g1,posIX,-b1,e1,h1,-posIY,-c1,f1,i1,-posIZ,0,0,0,1}}
            ct=ct+1
            
            local subObjects=object[6]
            if #subObjects>0 then
                for k=1,#subObjects do
                    local subObj=subObjects[k]
                    if subObj[11]~=nil then
                        recurse.subObjectMatrices(wwx,wwy,wwz,www,objX,objY,objZ,subObj,posIX,posIY,posIZ)
                    end
                end
            end
        end
        local pitch,heading,roll=objOri[1]*0.5,objOri[2]*0.5,objOri[3]*0.5
        
        --- Quaternion of object rotations
        local sP,sH,sR=s(pitch),s(roll),s(heading)
        local cP,cH,cR=c(pitch),c(roll),c(heading)
    
        local wwx=(sP*cH*cR-cP*sH*sR)
        local wwy=(cP*sH*cR+sP*cH*sR)
        local wwz=(cP*cH*sR-sP*sH*cR)
        local www=(cP*cH*cR+sP*sH*sR)
        local wx,wy,wz,ww=wwx,wwy,wwz,www
        
        if obj[8]==2 then
            wx,wy,wz,ww=multiply(wx,wy,wz,ww,sx,sy,sz,sw)
        end
        
        local wxwx,wxwy,wxwz,wxww,wywy,wywz,wyww,wzwz,wzww=wx*wx,wx*wy,wx*wz,wx*ww,wy*wy,wy*wz,wy*ww,wz*wz,wz*ww
        local a2=1-2*(wywy+wzwz)
        local b2=2*(wxwy-wzww)
        local c2=2*(wxwz+wyww)
    
        local d2=2*(wxwy+wzww)
        local e2=1-2*(wxwx+wzwz)
        local f2=2*(wywz-wxww)
    
        local g2=2*(wxwz-wyww)
        local h2=2*(wywz+wxww)
        local i2=1-2*(wxwx+wywy)

        if obj[7]==2 then
            local dotX=cRX*objPosX+cFX*objPosY+cUX*objPosZ
            local dotY=cRY*objPosX+cFY*objPosY+cUY*objPosZ
            local dotZ=cRZ*objPosX+cFZ*objPosY+cUZ*objPosZ
            objPosX=dotX
            objPosY=dotY
            objPosZ=dotZ
        else
            local cWorldPos=getTrueWorldPos()
            objPosX=objPosX-cWorldPos[1]
            objPosY=objPosY-cWorldPos[2]
            objPosZ=objPosZ-cWorldPos[3]
        end
        local subObjs=obj[6]
        if #subObjs>0 then
            for k=1,#subObjs do
                local subObj=subObjs[k]
                if subObj[6]~= nil then
                    recurse.subObjectMatrices(wwx,wwy,wwz,www,objPos[1],objPos[2],objPos[3],subObj,objPosX,objPosY,objPosZ)
                end
            end
        end
        modelMatrices[1]={obj,{a2,-d2,-g2,objPosX,-b2,e2,h2,-objPosY,-c2,f2,i2,-objPosZ,0,0,0,1}}
        return modelMatrices
    end

    local function updateReferentials()
        local s = solve
        local cU,cF,cR = getCWorldOriU(),getCWorldOriF(),getCWorldOriR()
        local ccUX,ccUY,ccUZ,ccFX,ccFY,ccFZ,ccRX,ccRY,ccRZ=cU[1],cU[2],cU[3],cF[1],cF[2],cF[3],cR[1],cR[2],cR[3]
        local v1t,v2t,v3t=s(cR,cF,cU,{1,0,0}),s(cR,cF,cU,{0,1,0}),s(cR,cF,cU,{0,0,1})
        cRX,cRY,cRZ,cFX,cFY,cFZ,cUX,cUY,cUZ=ccRX,ccRY,ccRZ,ccFX,ccFY,ccFZ,ccUX,ccUY,ccUZ
        sx,sy,sz,sw=rotToQuat({ccRX,ccRY,ccRZ,0,ccFX,ccFY,ccFZ,0,ccUX,ccUY,ccUZ,0})
        lx,ly,lz,lw=rotToQuat({v1t[1],v1t[2],v1t[3],0,v2t[1],v2t[2],v2t[3],0,v3t[1],v3t[2],v3t[3],0})
    end
    
    function self.getViewMatrix()
        updateReferentials()
        local s,c,multi,solve=sin,cos,multiply,solve

        local board=getElementRotationById(unitId)
        local ax,ay,az,aw=board[1],board[2],board[3],board[4]
        
        local body=getRelativeOrientation()
        local bx,by,bz,bw=body[1],body[2],body[3],body[4]
        
        local sx,sy,sz,sw=lx,ly,lz,lw

        local eye=eye
        local eyeX,eyeY,eyeZ=eye[1],eye[2],eye[3]

        local dotX,dotY,dotZ=eyeX,eyeY,eyeZ
        local wx,wy,wz,ww=0,0,0,1
        
        local px,py,pz,pw=multi(ax,ay,az,aw,bx,by,bz,bw)
        local alignment=getAlignmentType(px,py,pz,pw,eyeX,eyeY,eyeZ)
        alignmentType=alignment
        local pix,piy,piz,piw=inverse(px,py,pz,pw)
        local shift=alignment.shift
            
        local eyeTX,eyeTY,eyeTZ,eyeTW=multi(px,py,pz,pw,shift[1],shift[2],shift[3],0)
        local eyeIX,eyeIY,eyeIZ,eyeIW=multi(eyeTX,eyeTY,eyeTZ,eyeTW,pix,piy,piz,piw)
        
        local alignName=alignment.name
        local nFG=alignName~="fGlobal"
        local fG=alignName=="fGlobal"
        local nFL=alignName~="fLocal"
        local fL=alignName=="fLocal"
        local ori=cOrientation
        local pitch,roll,heading=ori[1]*0.5,0,ori[2]*0.5
        if pitch~=0 or heading~=0 or roll~=0 or fG or fL then
            local sP,sH,sR=s(pitch),s(roll),s(heading)
            local cP,cH,cR=c(pitch),c(roll),c(heading)
            
            local cx=sP*cH*cR-cP*sH*sR
            local cy=-cP*sH*cR-sP*cH*sR
            local cz=-cP*cH*sR+sP*sH*cR
            local cw=cP*cH*cR+sP*sH*sR
            if nFG and nFL then px,py,pz,pw=multi(px,py,pz,pw,cx,cy,cz,cw)
            elseif alignName=="fGlobal" then wx,wy,wz,ww=cx,cy,cz,cw
            else wx,wy,wz,ww = multi(sx,sy,sz,sw,cx,cy,cz,cw) end
        end
        
        if nFG and nFL then
            local pxpx,pxpy,pxpz,pxpw,pypy,pypz,pypw,pzpz,pzpw=px*px,px*py,px*pz,px*pw,py*py,py*pz,py*pw,pz*pz,pz*pw
            local a1=1-2*(pypy+pzpz)
            local b1=2*(pxpy-pzpw)
            local c1=2*(pxpz+pypw)
    
            local d1=2*(pxpy+pzpw)
            local e1=1-2*(pxpx+pzpz)
            local f1=2*(pypz-pxpw)
    
            local g1=2*(pxpz-pypw)
            local h1=2*(pypz+pxpw)
            local i1=1-2*(pxpx+pypy)
            eyeX=eyeX-eyeIX
            eyeY=eyeY+eyeIY
            eyeZ=eyeZ+eyeIZ
        
            dotX=a1*eyeX+-d1*eyeY+-g1*eyeZ
            dotY=-b1*eyeX+e1*eyeY+h1*eyeZ
            dotZ=-c1*eyeX+f1*eyeY+i1*eyeZ
            wx,wy,wz,ww=multi(sx,sy,sz,sw,px,py,pz,pw)
        end
        -- Camera rotation determination
        --- Directly input euler angles in radians
        
        local wxwx,wxwy,wxwz,wxww,wywy,wywz,wyww,wzwz,wzww=wx*wx,wx*wy,wx*wz,wx*ww,wy*wy,wy*wz,wy*ww,wz*wz,wz*ww
        local a2=1-2*(wywy+wzwz)
        local b2=2*(wxwy-wzww)
        local c2=2*(wxwz+wyww)
    
        local d2=2*(wxwy+wzww)
        local e2=1-2*(wxwx+wzwz)
        local f2=2*(wywz-wxww)
    
        local g2=2*(wxwz-wyww)
        local h2=2*(wywz+wxww)
        local i2=1-2*(wxwx+wywy)

        return {a2,-d2,-g2,dotX,-b2,e2,h2,dotY,-c2,f2,i2,dotZ,0,0,0,1}
    end
    
    function self.getSVG()
        local svg={}
        local c=1
        local view=self.getViewMatrix()

        local vx1,vy1,vz1,vw1=view[1],view[2],view[3],view[4]
        local vx2,vy2,vz2,vw2=view[5],view[6],view[7],view[8]
        local vx3,vy3,vz3,vw3=view[9],view[10],view[11],view[12]
        
        local getSize,sort=self.getSize,table.sort
        
        local function trigSort(t1,t2)
            return t1[1]>t2[1]
        end

        local function createLabel(svg,c,x,y,text,size,opacity,fill)
            svg[c]='<text x="'
            svg[c+1]=x
            svg[c+2]='" y="'
            svg[c+3]=y
            c=c+4
            if opacity then
                svg[c]='" fill-opacity="'
                svg[c+1]=opacity
                svg[c+2]='" stroke-opacity="'
                svg[c+3]=opacity
                c=c+4
            end
            if fill then
                svg[c]='" fill="'
                svg[c+1]=fill
                c=c+2
            end
            if size then
                svg[c]='" font-size="'
                svg[c+1]=size
                c=c+2
            end
            
            svg[c]='">'
            svg[c+1]=text
            svg[c+2]='</text>'
            return c+3
        end
        -- Localize projection matrix values
        local px1=x0
        local pz3=y0
        
        -- Localize screen info
        local width=width
        local height=height

        local objectGroups=objectGroups
        for i = 1, #objectGroups do
            local objectGroup=objectGroups[i]
            if objectGroup.enabled==false then goto not_enabled end
            local objGTransX=objectGroup.transX or width
            local objGTransY=objectGroup.transY or height
            local objects=objectGroup.objects
            
            svg[c]=[[<svg viewBox="0 0 ]]
            svg[c+1]=width*2
            svg[c+2]=[[ ]]
            svg[c+3]=height*2
            svg[c+4]=[[" class="]]
            svg[c+5]=objectGroup.style
            svg[c+6]='"><g transform="translate('
            svg[c+7]=objGTransX
            svg[c+8]=','
            svg[c+9]=objGTransY
            svg[c+10]=')">'
            c=c+11
            for m=1,#objects do
                local obj=objects[m]
                if obj[11]==nil then goto is_nil end
                local models=self.getModelMatrices(obj)
                -- Localize model matrix values
                for k=1,#models do
                    local modelObj=models[k]
                    local object=modelObj[1]
                    local model=modelObj[2]
                    
                    local objStyle=object[10]
                    local objTransX=object[13] or 0
                    local objTransY=object[14] or 0
                    
                    svg[c]='<g class="'
                    svg[c+1]=objStyle
                    c=c+2
                    if objTransX~=0 or objTransY~=0 then
                        svg[c]='" transform="translate('
                        svg[c+1]=objTransX
                        svg[c+2]=','
                        svg[c+3]=objTransY
                        svg[c+4]=')'
                        c=c+5
                    end
                    svg[c]='">'
                    c=c+1
                    local mx1,my1,mz1,mw1=model[1],model[2],model[3],model[4]
                    local mx2,my2,mz2,mw2=model[5],model[6],model[7],model[8]
                    local mx3,my3,mz3,mw3=model[9],model[10],model[11],model[12]
                
                    local pxw = px1*width            
                    local mXX=(vx1*mx1+vy1*mx2+vz1*mx3)*pxw
                    local mXY=(vx1*my1+vy1*my2+vz1*my3)*pxw
                    local mXZ=(vx1*mz1+vy1*mz2+vz1*mz3)*pxw
                    local mXW=(vw1+vx1*mw1+vy1*mw2+vz1*mw3)*pxw
        
                    local mYX=(vx2*mx1+vy2*mx2+vz2*mx3)
                    local mYY=(vx2*my1+vy2*my2+vz2*my3)
                    local mYZ=(vx2*mz1+vy2*mz2+vz2*mz3)
                    local mYW=(vw2+vx2*mw1+vy2*mw2+vz2*mw3)
        
                    local pzw=pz3*height
                    local mZX=(vx3*mx1+vy3*mx2+vz3*mx3)*pzw
                    local mZY=(vx3*my1+vy3*my2+vz3*my3)*pzw
                    local mZZ=(vx3*mz1+vy3*mz2+vz3*mz3)*pzw
                    local mZW=(vw3+vx3*mw1+vy3*mw2+vz3*mw3)*pzw
                
                    local polylineGroups,circleGroups,curvesGroups,customGroups,triangleGroups=object[1],object[2],object[3],object[4],object[5]            
            
                    -- Polylines for-loop
                    for d=1,#polylineGroups do
                        local polylineGroup = polylineGroups[d]
                        svg[c]='<path class="'
                        svg[c+1]=polylineGroup[1]
                        svg[c+2]='" d="'
                        c=c+3
                        for f=2,#polylineGroup do
                            local line=polylineGroup[f]
                            svg[c]='M '
                            local lC=0
                            local sP={}
                            local eP={}
                            c=c+1
                            for h=1,#line do
                                local p=line[h]
                                local x,y,z=p[1],-p[2],-p[3]
                                local pz=mYX*x+mYY*y+mYZ*z+mYW
                                if pz>0 then goto behindLine end

                                local ww=-pz
                                local wx=(mXX*x+mXY*y+mXZ*z+mXW)/ww
                                local wy=(mZX*x+mZY*y+mZZ*z+mZW)/ww
                                if lC~=0 then
                                    svg[c]=' L '
                                    c=c+1
                                    eP={wx,wy}
                                else
                                    sP={wx,wy}
                                end
                                svg[c]=wx
                                svg[c+1]=' '
                                svg[c+2]=wy
                                c=c+3
                                lC=lC+1
                                ::behindLine::
                            end
                            if lC < 2 then
                                if lC == 1 then c=c-4
                                else c=c-1 end
                            else
                                if eP[1]==sP[1] and eP[2]==sP[2] then
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
                        svg[c]='<g class="'
                        svg[c+1]=circleGroup[1]
                        svg[c+2]='">'
                        c=c+3
                        for l=2,#circleGroup do
                            local cir=circleGroup[l]
                            local p=cir[1]
                            local x,y,z=p[1],-p[2],-p[3]
                            local pz=mYX*x+mYY*y+mYZ*z+mYW
                            if pz>0 then goto behindCircle end

                            local ww=-pz
                            local wx=(mXX*x+mXY*y+mXZ*z+mXW)/ww
                            local wy=(mZX*x+mZY*y+mZZ*z+mZW)/ww
                            local radius,fill,label,offX,offY,size,resize,action=cir[2],cir[3],cir[4],cir[5],cir[6],cir[7],cir[8],cir[9]
                            svg[c]='<circle cx="'
                            svg[c+1]=wx
                            svg[c+2]='" cy="'
                            svg[c+3]=wy
                            svg[c+4]='" r="'
                            svg[c+5]=radius
                            svg[c+6]='" fill="'
                            svg[c+7]=fill
                            svg[c+8]='"/>'
                            c=c+9
                            if label then
                                svg[c]='<text x="'
                                svg[c+1]=wx+offX
                                svg[c+2]='" y="'
                                svg[c+3]=wy+offY
                                c=c+4
                                if size then
                                    if resize==true then
                                        svg[c]='" font-size="'
                                        svg[c+1]=getSize(size, wz)
                                    else
                                        svg[c]='" font-size="'
                                        svg[c+1]=size
                                    end
                                    c=c+2
                                end
                                svg[c]='">'
                                svg[c+1]=label
                                svg[c+2]='</text>'
                                c=c+3
                                end
                            if action then
                                c=action(svg, c, object, wx, wy, wz)
                            end
                            ::behindCircle::
                        end
                        svg[c]='</g>'
                        c=c+1
                    end
                    for cuG=1,#curvesGroups do
                        local curveG=curvesGroups[cuG]
                        svg[c]='<g class="'
                        svg[c+1]=curveG[1]
                        svg[c+2]='">'
                        c=c+3
                        local curveG=curvesGroups[cuG]
                        svg[c]='<path d="'
                        c=c+1
                        local curves=curveG[2]
                        local sLabelDat={}
                        local sLDC=0
                        for cCt=1,#curves do
                            local curve=curves[cCt]
                            if curve[1]==1 then
                                local pts=curve[2]
                                local labelDat=curve[3]
                                local tPts={}
                                for i=1,12 do
                                    local p=pts[i]
                                    local x,y,z=p[1],-p[2],-p[3]
                                    local pz=mYX*x+mYY*y+mYZ*z+mYW
                                    if pz>0 then tPts[i]={0,0,false}; goto continueCurve end
                                    
                                    local ww=-pz
                                    tPts[i]={(mXX*x+mXY*y+mXZ*z+mXW)/ww,(mZX*x+mZY*y+mZZ*z+mZW)/ww,true}
                                    ::continueCurve::
                                end
                                local m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12=tPts[1],tPts[2],tPts[3],tPts[4],tPts[5],tPts[6],tPts[7],tPts[8],tPts[9],tPts[10],tPts[11],tPts[12]
                                local m1x,m1y,m1z,m2x,m2y,m3x,m3y,m4x,m4y,m4z=m1[1],m1[2],m1[3],m2[1],m2[2],m3[1],m3[2],m4[1],m4[2],m4[3]
                                if m1[3] and m1[3] and m1[3] and m4z then
                                    svg[c]='M';svg[c+1]=m1x;svg[c+2]=' ';svg[c+3]=m1y;svg[c+4]='C';svg[c+5]=m2x;svg[c+6]=' ';svg[c+7]=m2y;svg[c+8]=',';svg[c+9]=m3x;svg[c+10]=' ';svg[c+11]=m3y;svg[c+12]=',';svg[c+13]=m4x;svg[c+14]=' ';svg[c+15]=m4y
                                    c=c+16
                                end
                                local m5x,m5y,m6x,m6y,m7x,m7y,m7z=m5[1],m5[2],m6[1],m6[2],m7[1],m7[2],m7[3]
                                if m4z and m5[3] and m6[3] and m7z then
                                    svg[c]='M';svg[c+1]=m4x;svg[c+2]=' ';svg[c+3]=m4y;svg[c+4]='C';svg[c+5]=m5x;svg[c+6]=' ';svg[c+7]=m5y;svg[c+8]=',';svg[c+9]=m6x;svg[c+10]=' ';svg[c+11]=m6y;svg[c+12]=',';svg[c+13]=m7x;svg[c+14]=' ';svg[c+15]=m7y
                                    c=c+16
                                end
                                local m8x,m8y,m9x,m9y,m10x,m10y,m10z=m8[1],m8[2],m9[1],m9[2],m10[1],m10[2],m10[3]
                                if m7z and m8[3] and m9[3] and m10z then
                                    svg[c]='M';svg[c+1]=m7x;svg[c+2]=' ';svg[c+3]=m7y;svg[c+4]='C';svg[c+5]=m8x;svg[c+6]=' ';svg[c+7]=m8x;svg[c+8]=',';svg[c+9]=m9x;svg[c+10]=' ';svg[c+11]=m9y;svg[c+12]=',';svg[c+13]=m10x;svg[c+14]=' ';svg[c+15]=m10y
                                    c=c+16
                                end    
                                local m11x,m11y,m12x,m12y=m11[1],m11[2],m12[1],m12[2]
                                if m10z and m11[3] and m12[3] and m1z then
                                    svg[c]='M';vg[c+1]=m10x;svg[c+2]=' ';svg[c+3]=m10y;svg[c+4]='C';svg[c+5]=m11x;svg[c+6]=' ';svg[c+7]=m11y;svg[c+8]=',';svg[c+9]=m12x;svg[c+10]=' ';svg[c+11]=m12y;svg[c+12]=',';svg[c+13]=m1x;svg[c+14]=' ';svg[c+15]=m1y
                                    c=c+16
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
                                        s=getSize(s, p[3], 100, 1)
                                    end
                                    svg[c]='<text x="'
                                    svg[c+1]=p[1]
                                    svg[c+2]='" y="'
                                    svg[c+3]=p[2]
                                    svg[c+4]='" fill="white" font-size="'
                                    svg[c+6]=s
                                    svg[c+7]='">'
                                    svg[c+8]=text
                                    svg[c+9]='</text>'
                                    c=c+10
                                end
                            end
                        end
                    end
                    for cG=1,#customGroups do
                        local customGroup=customGroups[cG]
                        local multiGroups=customGroup[2]
                        local singleGroups=customGroup[3]
                        svg[c]='<g class="'
                        svg[c+1]=customGroup[1]
                        svg[c+2]='">'
                        c=c+3
                        for mGC=1,#multiGroups do
                            local multiGroup=multiGroups[mGC]
                            local pts=multiGroup[1]
                            local tPoints={}
                            local ct=1
                            for pC=1,#pts do
                                local p=pts[pC]
                                local x,y,z=p[1],-p[2],-p[3]
                                local pz=mYX*x+mYY*y+mYZ*z+mYW
                                if pz>0 then goto behindMG end

                                local ww=-pz
                                tPoints[ct]={(mXX*x+mXY*y+mXZ*z+mXW)/ww,(mZX*x+mZY*y+mZZ*z+mZW)/ww,ww}
                                ct=ct+1
                                ::behindMG::
                            end
                            if ct~=1 then
                                local drawFunction=multiGroup[2]
                                local data=multiGroup[3]
                                c=drawFunction(svg,c,object,tPoints,data)
                            end
                        end
                        for sGC=1,#singleGroups do
                            local singleGroup = singleGroups[sGC]
                            local p=singleGroup[1]
                            local x,y,z=p[1],-p[2],-p[3]
                            local pz=mYX*x+mYY*y+mYZ*z+mYW
                            if pz>0 then goto behindSingle end
                            
                            local ww=-pz
                            local drawFunction=singleGroup[2]
                            local data=singleGroup[3]
                            c=drawFunction(svg,c,object,(mXX*x+mXY*y+mXZ*z+mXW)/ww,(mZX*x+mZY*y+mZZ*z+mZW)/ww,ww,data)
                            ::behindSingle::
                        end
                        svg[c]='</g>'
                        c=c+1
                    end
                    for tG=1,#triangleGroups do
                        local trigGroup=triangleGroups[tG]
                        svg[c]='<g class="'
                        svg[c+1]=trigGroup[1]
                        svg[c+2]='">'
                        c=c+3
                        local trigInfo=trigGroup[2]
                        local pts=trigGroup[3]
                        local transTrigs={}
                        for b=1,#trigInfo do
                            transTrigs[b]={-1,{},trigInfo[b][3]}
                        end
                        for ptI=1,#pts do
                            local pI=pts[ptI]
                            local p,indices=pI[1],pI[2]
                            local x,y,z=p[1],-p[2],-p[3]
                            local pz=mYX*x+mYY*y+mYZ*z+mYW
                            if pz>0 then goto behindTrig end

                            local ww=-pz
                            for i=1,#indices do
                                local triangleData=transTrigs[indices[i]]
                                triangleData[1]=triangleData[1]+ww
                                local points=triangleData[2]
                                points[#points+1]={(mXX*x+mXY*y+mXZ*z+mXW)/ww,(mZX*x+mZY*y+mZZ*z+mZW)/ww}
                            end
                            ::behindTrig::
                        end
                        sort(transTrigs,trigSort)
                        for tIdx=1,#transTrigs do
                            local trig=transTrigs[tIdx]
                            local tPts=trig[2]
                            if #tPts~=3 then goto invalid end
                            local p1,p2,p3=tPts[1],tPts[2],tPts[3]
                            svg[c]='<path stroke="black" fill="'
                            svg[c+1]=trig[3]
                            svg[c+2]='" d="M'
                            svg[c+3]=p1[1]
                            svg[c+4]=' '
                            svg[c+5]=p1[2]
                            svg[c+6]=' L '
                            svg[c+7]=p2[1]
                            svg[c+8]=' '
                            svg[c+9]=p2[2]
                            svg[c+10]=' L '
                            svg[c+11]=p3[1]
                            svg[c+12]=' '
                            svg[c+13]=p3[2]
                            svg[c+14]=' Z"/>'
                            c=c+15
                            ::invalid::
                        end
                        svg[c]='</g>'
                        c=c+1
                    end
                    svg[c]='</g>'
                    c=c+1
                end
                ::is_nil::
            end
            svg[c]='</g></svg>'
            c=c+1
            ::not_enabled::
        end
        return svg, c
    end
    return self
end