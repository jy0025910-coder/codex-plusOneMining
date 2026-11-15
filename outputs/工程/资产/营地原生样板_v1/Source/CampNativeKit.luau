-- Edit-time authoring kit. Not called by the game's runtime bootstrap.
-- Native CSG wall route retained for reproducibility. Reviewed wall fallback is
-- supplied by CanyonMeshKit; paving/stall remain editable native geometry.
local Kit = {}
local V, C = Vector3.new, CFrame.new
local Assets = game:GetService("ServerStorage"):WaitForChild("GameAssets")
local MaterialService = game:GetService("MaterialService")
local Collection = game:GetService("CollectionService")
local WALL_MATERIAL = "Camp_PaintedStrata_v2"
local function model(parent, name)
    local m = Instance.new("Model")
    m.Name = name
    m:SetAttribute("AssetVersion", 1)
    m:SetAttribute("AuthoringRoute", "RobloxNative")
    m.Parent = parent
    return m
end
local function part(parent, name, size, cf, color, solid, material, variant)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame = name, size, cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.MaterialVariant = variant or ""
    p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, solid == true, solid == true, false
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Reflectance = 0
    p.Parent = parent
    return p
end
local function pivot(m)
    local p = part(m, "AssetPivot", V(.1,.1,.1), C(0,0,0), Color3.new(1,1,1), false)
    p.Transparency, p.CastShadow = 1, false
    m.PrimaryPart = p
end
local function folder(parent, name)
    local f = parent:FindFirstChild(name)
    if not f then f=Instance.new("Folder"); f.Name=name; f.Parent=parent end
    return f
end
local function stripGameplay(root)
    for _,o in root:GetDescendants() do
        for _,tag in Collection:GetTags(o) do Collection:RemoveTag(o,tag) end
        if o:IsA("Script") or o:IsA("LocalScript") or o:IsA("ModuleScript") then
            o:Destroy()
        elseif o:IsA("ProximityPrompt") then
            o.Enabled=false
        elseif o:IsA("BasePart") then
            o.Anchored=true; o.CanTouch=false
        end
    end
    for _,tag in Collection:GetTags(root) do Collection:RemoveTag(root,tag) end
end

-- Intersect a box with diagonal half-spaces by subtracting cutters outside them.
-- A single UnionOperation remains per broad geological layer.
local function rockLayer(parent, name, size, cf, bevel, tint, seed)
    local scratch=Instance.new("Folder")
    scratch.Name="CampNativeCSG_Work"
    scratch.Parent=workspace
    local working=C(420,100,-200)
    local body=part(scratch,"Rock blank",size,working,Color3.new(1,1,1),false,Enum.Material.Sandstone)
    local cuts={}
    local function plane(point,normal)
        normal=normal.Unit
        local center=working:PointToWorldSpace(point+normal*60)
        local axis=working:VectorToWorldSpace(normal)
        local cut=part(scratch,"Temporary clipping solid",V(120,120,120),CFrame.lookAt(center,center-axis),Color3.new(1,1,1),false)
        table.insert(cuts,cut)
    end
    for _,sx in {-1,1} do for _,sz in {-1,1} do
        local b=bevel*(.82+((seed+sx*3+sz*7)%5)*.14)
        plane(V(sx*(size.X/2-b/2),0,sz*(size.Z/2-b/2)),V(sx,0,sz))
    end end
    plane(V(-size.X*.12,size.Y/2-.9,-size.Z/2+bevel*.7),V(.16,.92,-.38))
    plane(V(size.X/2-bevel*.8,size.Y/2-.6,0),V(.42,.91,0))
    plane(V(0,0,-size.Z/2+.55),V(.028,.045,-1))
    local ok,result=pcall(function()
        return body:SubtractAsync(cuts,Enum.CollisionFidelity.Box,Enum.RenderFidelity.Automatic)
    end)
    scratch:Destroy()
    if not ok then error("Native rock CSG failed: "..tostring(result)) end
    result.Name=name
    result.CFrame=cf*(working:ToObjectSpace(result.CFrame))
    result.UsePartColor=true
    result.Color=MaterialService:FindFirstChild(WALL_MATERIAL,true) and tint or Color3.fromRGB(204,109,61)
    result.Material=Enum.Material.Sandstone
    result.MaterialVariant=MaterialService:FindFirstChild(WALL_MATERIAL,true) and WALL_MATERIAL or ""
    result.Anchored=true; result.CanCollide=false; result.CanTouch=false; result.CanQuery=false
    result:SetAttribute("SurfaceRole","Sandstone")
    result:SetAttribute("NativeOperation","SubtractAsync")
    result.Parent=parent
    task.wait()
    return result
end
local function wall(parent,name,layers,seed)
    local m=model(parent,name)
    pivot(m)
    m:SetAttribute("AssetId","Environment."..name)
    m:SetAttribute("InwardAxis","-Z")
    for i,l in layers do
        rockLayer(m,"Broad sandstone layer "..i,l[1],l[2],l[3],l[4],seed+i)
        local p=part(m,"Simple collision "..i,l[1]*V(.88,.98,.84),l[2],Color3.new(1,1,1),true)
        p.Transparency=1; p.CastShadow=false
    end
    return m
end
function Kit.BuildLibrary()
    local env=folder(Assets,"Environment")
    local meshKit=env:FindFirstChild("CanyonMeshKit")
    local old=env:FindFirstChild("NativeCampSampleKit")
    local lib=model(nil,"NativeCampSampleKit")
    lib:SetAttribute("Purpose","S1 visual sample; not approved for whole-map repetition")
    lib:SetAttribute("AuthoringRoute",meshKit and "NativePaving_OriginalStall_BlenderWall" or "RobloxNative")
    lib:SetAttribute("MaterialRevision",meshKit and meshKit:GetAttribute("AssetVersion") or 1)
    local walls=folder(lib,"CanyonKit")
    local white=Color3.fromRGB(255,246,238)
    if meshKit then
        for _,entry in {{"CanyonWall_A","CanyonWall_Straight_A"},{"CanyonWall_B","CanyonWall_Straight_B"},{"CanyonWall_Corner","CanyonWall_Corner"}}do
            local clone=meshKit[entry[1]]:Clone();clone.Name=entry[2];clone.Parent=walls
        end
    else
    wall(walls,"CanyonWall_Straight_A",{
        {V(30,21,18),C(0,10.5,0),5.1,white},
        {V(28,16,16),C(-.9,27.6,1.1)*CFrame.Angles(0,.035,0),4.9,Color3.fromRGB(255,252,244)},
    },13)
    wall(walls,"CanyonWall_Straight_B",{
        {V(29,24,19),C(0,12,0)*CFrame.Angles(0,-.028,0),5.2,white},
        {V(25,16,16),C(1,30,1.5)*CFrame.Angles(0,.045,0),4.6,Color3.fromRGB(251,242,235)},
    },37)
    wall(walls,"CanyonWall_Corner",{
        {V(24,17,18),C(0,8.5,0),5.1,white},
        {V(20,12,15),C(-2,21.4,1.7),4.1,Color3.fromRGB(253,245,236)},
    },71)
    end
    local paving=folder(lib,"PavingKit")
    local slab=model(paving,"Paving_Slab_6x8")
    pivot(slab)
    local p=part(slab,"Stone slab",V(5.92,.45,7.92),C(0,.225,0),Color3.fromRGB(146,157,173),true,Enum.Material.Concrete)
    p:SetAttribute("SurfaceRole","Paver")
    slab:SetAttribute("AssetId","Environment.Paving_Slab_6x8")
    slab:SetAttribute("Footprint",V(6,0,8))
    local curb=model(paving,"Paving_Curb_8")
    pivot(curb)
    part(curb,"Thick slate curb",V(1,.72,8),C(0,.36,0),Color3.fromRGB(73,85,103),true,Enum.Material.Slate)
    curb:SetAttribute("AssetId","Environment.Paving_Curb_8")
    local stall=Assets.Buildings.MarketStall:Clone()
    stall.Name="MarketStall_MaterialSample"
    stripGameplay(stall)
    local counts={wood=0,fabric=0}
    for _,rootName in {"TimberFrame","Counter"} do
        local root=stall:FindFirstChild(rootName)
        if root then for _,o in root:GetDescendants()do if o:IsA("BasePart")then
            o.Material=Enum.Material.Wood
            o.Reflectance=0
            o.Color=o.Color:Lerp(Color3.fromRGB(163,111,67),.22)
            o:SetAttribute("SurfaceRole","Timber")
            counts.wood+=1
        end end end
    end
    if stall:FindFirstChild("Canopy")then for _,o in stall.Canopy:GetDescendants()do if o:IsA("BasePart")then
        o.Material=Enum.Material.Fabric; o.Reflectance=0
        if o:GetAttribute("TintRole")=="Canopy" then o.Color=Color3.fromRGB(76,159,105)
        else o.Color=Color3.fromRGB(239,231,206)end
        o:SetAttribute("SurfaceRole","Canvas"); counts.fabric+=1
    end end end
    stall:SetAttribute("Changes","Materials and restrained color only; original geometry and mounts retained")
    stall:SetAttribute("WoodParts",counts.wood)
    stall:SetAttribute("FabricParts",counts.fabric)
    stall.Parent=lib
    lib.Parent=env
    if old then old:Destroy()end
    return lib
end

local function cloneAt(source,parent,name,cf)
    local c=source:Clone(); c.Name=name; c:PivotTo(cf); c.Parent=parent; return c
end
function Kit.BuildSample(origin)
    origin=origin or V(420,0,0)
    local lib=Assets.Environment.NativeCampSampleKit
    local old=workspace:FindFirstChild("Camp Art Sample")
    local sample=model(nil,"Camp Art Sample")
    pivot(sample)
    sample.PrimaryPart.CFrame=C(origin)
    sample:SetAttribute("AssetId","Preview.CampNativeS1")
    sample:SetAttribute("VisualOnly",true)
    sample:SetAttribute("AuthoringRoute","NativePaving_OriginalStall_BlenderWall")
    sample:SetAttribute("MaterialRevision",lib:GetAttribute("MaterialRevision") or 1)
    sample:SetAttribute("Origin",origin)
    local function at(x,y,z)return C(origin+V(x,y,z))end
    part(sample,"Sand foundation",V(70,2,76),at(0,-1.2,-5),Color3.fromRGB(213,174,115),true,Enum.Material.Sand)
    local walls=model(sample,"Continuous sandstone sample")
    cloneAt(lib.CanyonKit.CanyonWall_Straight_A,walls,"Wall A",at(-14,0,-30)*CFrame.Angles(0,math.pi,0))
    cloneAt(lib.CanyonKit.CanyonWall_Straight_B,walls,"Wall B",at(13.5,0,-32)*CFrame.Angles(0,math.pi,0))
    cloneAt(lib.CanyonKit.CanyonWall_Corner,walls,"Corner buttress",at(-29,0,-9)*CFrame.Angles(0,-math.pi/2,0))
    local paving=model(sample,"T junction stone paving")
    local tileIndex=0
    -- 6x8 grid: one T junction, no overlapping slabs at its intersection.
    for r=-2,2 do for col=-3,3 do
        if r<=0 or math.abs(col)<=1 then
            tileIndex+=1
            local tile=cloneAt(lib.PavingKit.Paving_Slab_6x8,paving,"Slab "..tileIndex,at(col*6,0,r*8))
            local shade=({Color3.fromRGB(137,147,163),Color3.fromRGB(149,159,175),Color3.fromRGB(160,169,183),Color3.fromRGB(143,153,169)})[(r*7+col*11)%4+1]
            tile["Stone slab"].Color=shade
        end
    end end
    -- Top .45, darker continuous mortar foundation below slab tops.
    part(paving,"Dark mortar base horizontal",V(42,.28,24),at(0,-.01,-8),Color3.fromRGB(91,103,119),true,Enum.Material.Slate)
    part(paving,"Dark mortar base stem",V(18,.28,16),at(0,-.01,12),Color3.fromRGB(91,103,119),true,Enum.Material.Slate)
    local edge=Color3.fromRGB(91,104,123)
    part(paving,"Back border course",V(46,.50,2),at(0,.20,-21),edge,true,Enum.Material.Slate)
    part(paving,"Front border left",V(13,.50,2),at(-16,.20,5),edge,true,Enum.Material.Slate)
    part(paving,"Front border right",V(13,.50,2),at(16,.20,5),edge,true,Enum.Material.Slate)
    part(paving,"Front curb left",V(13,.72,.8),at(-16.5,.10,6.4),Color3.fromRGB(67,81,101),true,Enum.Material.Slate)
    part(paving,"Front curb right",V(13,.72,.8),at(16.5,.10,6.4),Color3.fromRGB(67,81,101),true,Enum.Material.Slate)
    for _,side in {-1,1}do
        part(paving,"Outer horizontal curb",V(1,.72,26),at(side*23.5,.10,-8),Color3.fromRGB(67,81,101),true,Enum.Material.Slate)
        part(paving,"Stem border course",V(2,.50,17),at(side*10,.20,12.5),edge,true,Enum.Material.Slate)
        part(paving,"Stem outer curb",V(.8,.72,17),at(side*11.4,.10,12.5),Color3.fromRGB(67,81,101),true,Enum.Material.Slate)
    end
    -- Single stall on a modest slab plinth; preserve the original architecture.
    local plinth=model(sample,"Stall plinth")
    part(plinth,"Slate foundation",V(13.5,.6,10.5),at(11,.3,-13.5),Color3.fromRGB(75,86,105),true,Enum.Material.Slate)
    part(plinth,"Stone top",V(13,.32,10),at(11,.76,-13.5),Color3.fromRGB(152,162,178),true,Enum.Material.Concrete)
    part(plinth,"Lower step",V(7,.34,1.6),at(11,.17,-6.4),Color3.fromRGB(139,149,166),true,Enum.Material.Concrete)
    part(plinth,"Upper step",V(7,.54,1.6),at(11,.27,-8),Color3.fromRGB(152,162,178),true,Enum.Material.Concrete)
    local stall=cloneAt(lib.MarketStall_MaterialSample,sample,"One stall - material refinement",at(11,.92,-14))
    local merchant=Assets.Characters.ProspectorMerchant:Clone()
    stripGameplay(merchant)
    merchant.Name="Original merchant - unchanged appearance"
    merchant:PivotTo(stall.Mounts.NpcMount.CFrame)
    merchant.Parent=stall
    if stall:FindFirstChild("SignAnchor")then
        local gui=stall.SignAnchor:FindFirstChild("Lettering")
        if gui and gui:FindFirstChild("Title")then gui.Title.Text="矿石回收"end
    end
    local rock=cloneAt(Assets.TrainingRocks.PracticeRock_A_Classic,sample,"Approved practice rock - scale reference",at(-12,.45,-12)*CFrame.Angles(0,math.pi,0))
    stripGameplay(rock)
    -- Purely visual zone: remove tags, no sell/training can be discovered here.
    local zone=Assets.Interactions.AutoSellZone:Clone()
    stripGameplay(zone)
    zone.Name="Visual green boundary - no gameplay"
    zone:PivotTo(at(11,.93,-5))
    if zone:FindFirstChild("Trigger")then zone.Trigger:SetAttribute("Enabled",false)end
    if zone:FindFirstChild("FloorLabel")then zone.FloorLabel:Destroy()end
    zone.Parent=sample
    sample.Parent=workspace
    if old then old:Destroy()end
    return sample
end
return Kit
