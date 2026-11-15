-- Edit-time reusable 2D UI template; the image must be uploaded with approval first.
local image="rbxassetid://140555305371223"
assert(image:match("^rbxassetid://%d+$"),"Approved pickaxe B image asset is not configured")
local shared=game.ReplicatedStorage.Shared
local template=Instance.new("CanvasGroup")
template.Name="PowerGainTemplate";template.AnchorPoint=Vector2.new(.5,.5)
template.Size=UDim2.fromOffset(200,100);template.BackgroundTransparency=1
template.Visible=false;template.Active=false;template.ZIndex=20
template:SetAttribute("AssetId","UI.StrengthGain");template:SetAttribute("AssetVersion",2)
template:SetAttribute("IconVariant","Pickaxe_B");template:SetAttribute("IconImage",image)
local icon=Instance.new("ImageLabel");icon.Name="Icon";icon.Size=UDim2.fromOffset(86,86)
icon.Position=UDim2.fromOffset(4,9);icon.BackgroundTransparency=1
icon.Image=image;icon.ScaleType=Enum.ScaleType.Fit;icon.ZIndex=21;icon.Parent=template
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
