-- Edit-time, reusable native GUI artwork. No image uploads or runtime particles.
local Decor={}
local function frame(name,parent,size,position,z)
    local o=Instance.new("Frame");o.Name=name;o.BorderSizePixel=0
    o.Size=size;o.Position=position;o.AnchorPoint=Vector2.new(.5,.5)
    o.BackgroundColor3=Color3.new(1,1,1);o.ZIndex=z or 2;o.Parent=parent
    return o
end
local function round(o)
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(.5,0);c.Parent=o
end
function Decor.Burst(parent)
    local glow=frame("RewardGlow",parent,UDim2.fromScale(.99,1.16),UDim2.fromScale(.5,.37),2)
    glow.BackgroundTransparency=1
    local aspect=Instance.new("UIAspectRatioConstraint");aspect.AspectRatio=1;aspect.Parent=glow
    for i=1,8 do
        local d=.84-i*.075
        local core=frame("Core"..i,glow,UDim2.fromScale(d,d),UDim2.fromScale(.5,.5),2)
        core.BackgroundTransparency=.97-i*.012;round(core)
    end
    for i,angle in {0,45,90,135}do
        local ray=frame("Ray"..angle,glow,UDim2.fromScale(i%2==1 and 1 or .9,i%2==1 and .105 or .065),UDim2.fromScale(.5,.5),2)
        ray.Rotation=angle;round(ray)
        local fade=Instance.new("UIGradient");fade.Name="CenterToEdge"
        fade.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.16,.75),
            NumberSequenceKeypoint.new(.38,.15),NumberSequenceKeypoint.new(.5,0),
            NumberSequenceKeypoint.new(.62,.15),NumberSequenceKeypoint.new(.84,.75),NumberSequenceKeypoint.new(1,1),
        });fade.Parent=ray
    end
    return glow
end
function Decor.ResourceShade(parent)
    local shadow=frame("ResourceShade",parent,UDim2.fromScale(1,.84),UDim2.fromScale(.5,.5),2)
    shadow.BackgroundColor3=Color3.new(0,0,0);round(shadow)
    local fade=Instance.new("UIGradient");fade.Name="SoftSides"
    fade.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(.16,.76),NumberSequenceKeypoint.new(.4,.48),
        NumberSequenceKeypoint.new(.6,.48),NumberSequenceKeypoint.new(.84,.76),NumberSequenceKeypoint.new(1,1)})
    fade.Parent=shadow
    return shadow
end
return Decor
