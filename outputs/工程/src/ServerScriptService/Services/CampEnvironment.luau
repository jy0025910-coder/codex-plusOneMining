local Config=require(game.ReplicatedStorage.Shared.PrototypeConfig)
local assets=game.ServerStorage.GameAssets
local Environment={}
local V,C=Vector3.new,CFrame.new
local function model(parent,name)
    local m=Instance.new("Model");m.Name=name;m.Parent=parent;return m
end
local function part(parent,name,size,cf,color,solid,material)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
    p.CanCollide=solid==true;p.CanQuery=solid==true;p.CanTouch=false
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
    return p
end

function Environment.CreateSign(parent,name,cf,title,subtitle,color,width)
    local sign=model(parent,name);width=width or 30
    local frame=part(sign,"Neon frame",V(width+1.1,8.6,1.1),cf,color,false,Enum.Material.Neon)
    local body=part(sign,"Enamel panel",V(width,7.5,1.2),cf,Color3.fromRGB(30,60,80))
    sign.PrimaryPart=body
    for _,side in {-1,1}do
        part(sign,"Signpost",V(.8,cf.Position.Y-3,.9),C(cf.Position.X+side*(width*.39),(cf.Position.Y-3)/2,cf.Position.Z),Color3.fromRGB(69,99,111),true)
        part(sign,"Post collar",V(1.5,.7,1.5),C(cf.Position.X+side*(width*.39),1,cf.Position.Z),color)
    end
    for _,face in {Enum.NormalId.Front,Enum.NormalId.Back}do
        local gui=Instance.new("SurfaceGui");gui.Name="NeonLettering";gui.Face=face;gui.CanvasSize=Vector2.new(500,140);gui.LightInfluence=0;gui.Parent=body
        local main=Instance.new("TextLabel");main.Name="Title";main.BackgroundTransparency=1;main.Position=UDim2.fromScale(.03,.04);main.Size=UDim2.fromScale(.94,.66)
        main.Text=title;main.Font=Enum.Font.GothamBlack;main.TextScaled=true;main.TextColor3=Color3.fromRGB(221,255,255);main.TextStrokeColor3=color;main.TextStrokeTransparency=.1;main.Parent=gui
        local caption=main:Clone();caption.Name="Subtitle";caption.Position=UDim2.fromScale(.05,.75);caption.Size=UDim2.fromScale(.9,.17);caption.Text=subtitle;caption.TextColor3=color:Lerp(Color3.new(1,1,1),.6);caption.TextStrokeTransparency=1;caption.Parent=gui
    end
    local glow=Instance.new("PointLight");glow.Color=color;glow.Brightness=.5;glow.Range=22;glow.Parent=frame
    sign:SetAttribute("AssetId","Sign.NeonCampBoard")
    return sign
end

-- The authored sandstone mesh is reused for soft, faceted canyon silhouettes.
local function cliff(parent,name,cf,size,color,collision)
    local m=model(parent,name)
    local stretch=V(size.X/5.49,size.Y/3.68,size.Z/4.07)
    for _,source in assets.Ores.SandstoneOre:GetChildren()do
        if source:IsA("MeshPart") and source:GetAttribute("MeshRole")=="StoneBody" then
            local p=source:Clone();local localCF=source.CFrame
            p.Size=p.Size*stretch;p.CFrame=cf*C(localCF.Position*stretch)*localCF.Rotation
            local base=p:GetAttribute("BaseColor") or p.Color
            p.Color=color:Lerp(Color3.fromRGB(255,205,137),math.clamp((base.R-.65)*1.2,0,.26))
            p.Material=Enum.Material.SmoothPlastic;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Parent=m
        end
    end
    if collision then
        local p=part(m,"Cliff collision",V(size.X*.88,size.Y*.82,size.Z*.88),cf*C(0,size.Y*.4,0),color,true)
        p.Transparency=1
    end
    return m
end

function Environment.Build(town)
    local floor=part(town,"Desert floor",V(196,2,196),C(0,-1,0),Color3.fromRGB(239,197,126),true,Enum.Material.Sand)
    part(town,"Mine foundation",V(40,2,120),C(0,-1,-133),Color3.fromRGB(239,197,126),true,Enum.Material.Sand)
    town.PrimaryPart=floor
    local paving=model(town,"Cross stone paving")
    local border=Color3.fromRGB(107,135,139)
    part(paving,"North south road foundation",V(27,.35,147),C(0,.03,0),border,true)
    part(paving,"East west road foundation",V(147,.35,27),C(0,.03,0),border,true)
    for row=-14,14 do
        for col=-14,14 do
            if math.abs(row)<=2 or math.abs(col)<=2 then
                local variation=(row*7+col*11)%4
                part(paving,"Cross paving brick",V(4.84,.17,4.84),C(col*5,.28,row*5),Color3.fromRGB(193+variation*5,190+variation*5,169+variation*5),true)
            end
        end
        if row%5==0 then task.wait()end
    end
    for _,sx in {-1,1}do for _,sz in {-1,1}do
        part(paving,"Corner stall apron",V(25,.3,25),C(sx*27,.08,sz*27),Color3.fromRGB(180,178,157),true)
        part(paving,"Apron inset",V(23.5,.15,23.5),C(sx*27,.31,sz*27),Color3.fromRGB(214,203,174),true)
    end end
    part(paving,"Practice approach",V(10,.25,90),C(-42,.14,0),Color3.fromRGB(205,192,161),true)
    part(paving,"Rankings terrace",V(44,.55,51),C(58,.15,0),Color3.fromRGB(180,181,159),true)
    part(paving,"Rankings terrace inset",V(42,.12,49),C(58,.49,0),Color3.fromRGB(226,213,174),true)
    local rim=model(town,"Canyon rim")
    local orange=Color3.fromRGB(196,127,80)
    for _,side in {-1,1}do
        for i=0,10 do
            local coordinate=-75+i*15
            cliff(rim,"Side canyon",C(side*85,0,coordinate),V(24,27+(i%3)*4,20),orange,true)
            if side==1 then
            cliff(rim,"South canyon",C(coordinate,0,85),V(20,26+(i%4)*3,25),orange,true)
            if math.abs(coordinate)>=30 then
                cliff(rim,"North canyon",C(coordinate,0,-85),V(20,30+(i%3)*3,25),orange,true)
            end
            end
        end
        task.wait()
    end
    for _,sx in {-1,1}do for _,sz in {-1,1}do
        cliff(rim,"Inset corner buttress",C(sx*62,0,sz*61)*CFrame.Angles(0,sx*sz*.16,0),V(48,18,38),orange,true)
        cliff(rim,"Corner upper ledge",C(sx*67,11,sz*68),V(35,18,30),Color3.fromRGB(215,150,91),false)
        task.wait()
    end end
    -- The fourth side is enclosed above the one playable mine doorway.
    for _,side in {-1,1}do
        cliff(rim,"Mine portal shoulder",C(side*22,0,-82),V(14,21,23),orange,true)
    end
    cliff(rim,"Mine arch crown",C(0,15,-85),V(42,18,25),orange,false)
    part(rim,"Mine arch collision",V(35,15,16),C(0,23,-85),orange,true).Transparency=1
    Environment.CreateSign(town,"Practice neon billboard",C(-60,25,-48),"练功区","挥镐变强  ·  挑战更深矿脉",Color3.fromRGB(47,222,246),33)
    return floor
end

return Environment
