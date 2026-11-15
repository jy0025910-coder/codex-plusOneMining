-- Edit-time authored reusable GUI component. No runtime construction loop.
local shared=game.ReplicatedStorage.Shared
local template=Instance.new("CanvasGroup")
template.Name="PowerGainTemplate";template.AnchorPoint=Vector2.new(.5,.5)
template.Size=UDim2.fromOffset(200,100);template.BackgroundTransparency=1
template.Visible=false;template.Active=false;template.ZIndex=20
template:SetAttribute("AssetId","UI.StrengthGain");template:SetAttribute("AssetVersion",1)
local icon=Instance.new("ViewportFrame");icon.Name="Icon";icon.Size=UDim2.fromOffset(86,86)
icon.Position=UDim2.fromOffset(4,9);icon.BackgroundTransparency=1
icon.Ambient=Color3.fromRGB(185,190,210);icon.LightColor=Color3.fromRGB(255,244,219)
icon.LightDirection=Vector3.new(-1,-1,-2);icon.ZIndex=21;icon.Parent=template
local world=Instance.new("WorldModel");world.Name="PickaxePreview";world.Parent=icon
local model=Instance.new("Model");model.Name="IronPickaxeIcon";model.Parent=world
for _,source in game.ServerStorage.GameAssets.Tools.IronPickaxe:GetDescendants()do
    if source:IsA("BasePart") and source.Transparency<1 then
        local part=source:Clone()
        for _,child in part:GetChildren()do
            if child:IsA("LuaSourceContainer") or child:IsA("JointInstance") or child:IsA("Constraint")then child:Destroy()end
        end
        part.Anchored=true;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false
        part.Parent=model
    end
end
local box=model:GetBoundingBox()
local rotation=CFrame.Angles(0,math.rad(-12),math.rad(-28))
for _,part in model:GetChildren()do part.CFrame=rotation*(part.CFrame-box.Position)end
local _,size=model:GetBoundingBox()
local camera=Instance.new("Camera");camera.Name="IconCamera";camera.FieldOfView=35
camera.CFrame=CFrame.lookAt(Vector3.new(0,0,math.max(size.X,size.Y)/2/math.tan(math.rad(17.5))*1.12),Vector3.zero)
camera.Parent=icon;icon.CurrentCamera=camera
-- Camera instances do not replicate; clients rebuild from this portable data.
icon:SetAttribute("PreviewCameraFrame",camera.CFrame)
icon:SetAttribute("PreviewFieldOfView",camera.FieldOfView)
local number=Instance.new("TextLabel");number.Name="Amount"
number.Size=UDim2.fromOffset(112,86);number.Position=UDim2.fromOffset(83,5)
number.BackgroundTransparency=1;number.Font=Enum.Font.FredokaOne
number.TextSize=70;number.TextColor3=Color3.new(1,1,1);number.Text="+1"
number.TextStrokeTransparency=1;number.ZIndex=21;number.Parent=template
local outline=Instance.new("UIStroke");outline.Name="InkOutline"
outline.Color=Color3.fromRGB(20,15,19);outline.Thickness=4
outline.ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual;outline.LineJoinMode=Enum.LineJoinMode.Round;outline.Parent=number
local scale=Instance.new("UIScale");scale.Name="PopScale";scale.Parent=template
local old=shared:FindFirstChild(template.Name);template.Parent=shared;if old then old:Destroy()end
return template:GetFullName()
