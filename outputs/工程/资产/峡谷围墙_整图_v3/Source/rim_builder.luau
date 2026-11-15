-- Owned by CampEnvironment. Selective, repeatable wall-only migration.
function Environment.ReplaceRim(town)
    local kit=assets.Environment:FindFirstChild("CanyonMeshKit")
    assert(kit and kit:GetAttribute("AssetVersion")==3,"CanyonMeshKit v3 required")
    local rim=Instance.new("Model");rim.Name="Canyon rim"
    rim:SetAttribute("AssetId","Environment.LayeredCanyonRim")
    rim:SetAttribute("AssetVersion",3)
    rim:SetAttribute("InnerWallCenter",98)
    local count=0
    local function place(name,variant,position,size,yaw,solid,tint)
        local source=kit:FindFirstChild("CanyonWall_"..variant)
        assert(source and source.PrimaryPart,"Missing wall template "..variant)
        local m=Instance.new("Model");m.Name=name
        m:SetAttribute("AssetId",source:GetAttribute("AssetId") or "Environment.CanyonWall."..variant)
        m:SetAttribute("AssetVersion",3)
        m:SetAttribute("LayerRole",name)
        local p=source.PrimaryPart:Clone();p.Name="Sandstone visual"
        p.Size=size;p.PivotOffset=C(0,-size.Y/2,0)
        local cf=C(position)*CFrame.Angles(0,yaw,0)
        p.CFrame=cf*C(0,size.Y/2,0)
        p.Color=tint or Color3.new(1,1,1)
        p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
        p.Parent=m;m.PrimaryPart=p
        if solid then
            local collider=part(m,"Simple cliff collision",V(size.X*.95,size.Y*.95,size.Z*.70),cf*C(0,size.Y*.475,0),Color3.new(1,1,1),true)
            collider.Transparency=1
        end
        m.Parent=rim;count+=1
        return m
    end
    -- Close inner ring, with broad overlapping modules and varied skyline.
    local heights={38,43,35,40,37,44,39}
    for _,side in {-1,1}do
        for i=1,7 do
            local coordinate=-90+(i-1)*30
            local variant=(i+(side==1 and 1 or 0))%2==0 and "A" or "B"
            local yaw=side==1 and math.pi/2 or -math.pi/2
            local nudge=({0,1.1,-.8,.6,-1,.2,0})[i]
            place("Main side cliff",variant,V(side*(98+nudge),-.3,coordinate),V(35,heights[i],23),yaw+math.rad((i%3-1)*2),true)
        end
        task.wait()
    end
    for i=1,7 do
        local x=-90+(i-1)*30
        place("Arrival enclosing cliff",i%2==0 and "A" or "B",V(x,-.3,98+(i%3-1)),V(35,heights[8-i]-2,23),math.rad((i%3-1)*2),true)
        if i~=4 then
            place("Mine-side cliff",i%2==0 and "B" or "A",V(x,-.3,-98-(i%3-1)),V(35,heights[i]+1,24),math.pi+math.rad((i%3-1)*2),true)
        end
    end
    task.wait()
    -- Staggered rear masses rise above the close ring instead of making one flat wall.
    for _,side in {-1,1}do
        for i=1,5 do
            local c=-80+(i-1)*40
            local h=({24,30,23,28,25})[i]+(side==1 and 1 or -1)
            place("Rear ridge lower mass","Corner",V(side*117,-.3,c),V(49,28,29),side*math.pi/2+math.rad((i%3-1)*5),false)
            place("Rear high ridge",i%2==0 and "A" or "B",V(side*117,23,c),V(49,h,29),side*math.pi/2+math.rad((i%3-1)*5),false,Color3.fromRGB(248,245,241))
            if side==1 then
                place("Rear arrival lower mass","Corner",V(c,-.3,117),V(49,28,29),math.rad((i%3-1)*4),false)
                place("Rear arrival ridge",i%2==0 and "B" or "A",V(c,23,117),V(49,h-3,29),math.rad((i%3-1)*4),false,Color3.fromRGB(248,245,241))
            end
            if math.abs(c)>=40 and side==1 then
                place("Rear mine lower mass","Corner",V(c,-.3,-118),V(48,28,30),math.pi+math.rad((i%3-1)*4),false)
                place("Rear mine ridge",i%2==0 and "A" or "B",V(c,23,-118),V(48,h+2,30),math.pi+math.rad((i%3-1)*4),false,Color3.fromRGB(248,245,241))
            end
        end
        task.wait()
    end
    -- Four inward shoulders establish foreground / middle / high-back layers.
    for _,sx in {-1,1}do for _,sz in {-1,1}do
        place("Inset corner shoulder","Corner",V(sx*77,-.25,sz*72),V(36,24+(sx==sz and 3 or 0),32),sx*sz*.26,true)
        place("Corner upper ledge","A",V(sx*85,15,sz*85),V(32,24,26),sx*sz*.18,false)
    end end
    -- Keep the existing 26-stud gate and all three rooms exactly where they are.
    for _,side in {-1,1}do
        place("Portal shoulder","Corner",V(side*23,-.3,-85),V(14,27,24),math.pi+side*.08,true)
    end
    place("Portal crown","A",V(0,16,-94),V(46,27,29),math.pi,false)
    for _,side in {-1,1}do
        place("Portal upper transition","Corner",V(side*21,27,-109),V(28,20,26),math.pi+side*.12,false)
    end
    local crown=part(rim,"Portal overhead collision",V(31,24,25),C(0,28,-94),Color3.new(1,1,1),true);crown.Transparency=1
    rim:SetAttribute("VisualMeshCount",count)
    rim.WorldPivot=C(0,0,0)
    local old=town:FindFirstChild("Canyon rim")
    rim.Parent=town
    if old then old:Destroy()end
    town:SetAttribute("CanyonArtVersion",3)
    return rim
end
