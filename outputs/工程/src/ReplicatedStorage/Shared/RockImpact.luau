local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Debris=game:GetService("Debris")
local Impact={}
local shakes=setmetatable({},{__mode="k"})

local function shake(visual,large)
    if not visual then return end
    local previous=shakes[visual]
    local scope={rest=previous and previous.rest or visual:GetPivot()}
    shakes[visual]=scope
    task.spawn(function()
        local started=os.clock()
        while visual.Parent and shakes[visual]==scope do
            local t=os.clock()-started
            if t>=.26 then break end
            local decay=(1-t/.26)^2
            local strength=large and .31 or .16
            local offset=Vector3.new(math.sin(t*85)*strength,math.sin(t*58)*.08,math.cos(t*73)*strength*.6)*decay
            visual:PivotTo(scope.rest*CFrame.new(offset)*CFrame.Angles(0,math.sin(t*67)*.035*decay,math.sin(t*82)*.042*decay))
            RunService.RenderStepped:Wait()
        end
        if shakes[visual]==scope then
            if visual.Parent then visual:PivotTo(scope.rest)end
            shakes[visual]=nil
        end
    end)
end

function Impact.Play(target,root,rng)
    local valid=target and target:IsA("BasePart") and target:IsDescendantOf(workspace)
    local large=valid and target:GetAttribute("LargeImpact")==true
    local stone=valid and target.Color or Color3.fromRGB(214,170,111)
    local mineral=valid and target:GetAttribute("ImpactColor") or Color3.fromRGB(255,213,117)
    local contact=root.Position+root.CFrame.LookVector*3
    local center=contact
    if valid then
        local localRoot=target.CFrame:PointToObjectSpace(root.Position)
        local x=math.clamp(localRoot.X,-target.Size.X*.48,target.Size.X*.48)
        local z=math.clamp(localRoot.Z,-target.Size.Z*.48,target.Size.Z*.48)
        local y=math.clamp(localRoot.Y+.1,-target.Size.Y*.5+.6,target.Size.Y*.5-.3)
        contact=target.CFrame:PointToWorldSpace(Vector3.new(x,y,z))
        center=Vector3.new(target.Position.X,contact.Y,target.Position.Z)
        local visual=target.Parent:FindFirstChild("RockVisual")
        local flash=Instance.new("Highlight");flash.Name="RockHitFlash"
        flash.Adornee=visual or target;flash.FillColor=Color3.new(1,1,1);flash.FillTransparency=large and .22 or .38
        flash.OutlineTransparency=1;flash.DepthMode=Enum.HighlightDepthMode.Occluded;flash.Parent=target
        TweenService:Create(flash,TweenInfo.new(.18,Enum.EasingStyle.Quad),{FillTransparency=1}):Play()
        Debris:AddItem(flash,.21)
        shake(visual,large)
    end
    local count=large and 28 or valid and 16 or 7
    for i=1,count do
        local chip=Instance.new(i%3==0 and "WedgePart" or "Part")
        chip.Name="MiningChip"
        local size=large and rng:NextNumber(.30,.85) or rng:NextNumber(.13,.40)
        chip.Size=Vector3.new(size,size*rng:NextNumber(.65,1.1),size*rng:NextNumber(.7,1.2))
        chip.Color=i%3==0 and mineral or stone:Lerp(Color3.fromRGB(255,231,187),rng:NextNumber(0,.25))
        chip.Material=Enum.Material.SmoothPlastic;chip.Anchored=true;chip.CanCollide=false;chip.CanQuery=false;chip.CanTouch=false
        local angle=i/count*math.pi*2+rng:NextNumber(-.25,.25)
        local direction=Vector3.new(math.cos(angle),0,math.sin(angle))
        local origin=contact
        if large and i>10 then
            local radius=math.min(target.Size.X,target.Size.Z)*rng:NextNumber(.23,.42)
            origin=center+direction*radius+Vector3.new(0,rng:NextNumber(-.8,1.8),0)
        end
        chip.CFrame=CFrame.new(origin)*CFrame.Angles(rng:NextNumber(0,3),rng:NextNumber(0,3),rng:NextNumber(0,3));chip.Parent=workspace
        local distance=large and rng:NextNumber(3,6) or rng:NextNumber(1.3,2.8)
        local peak=origin+direction*distance*.65+Vector3.new(0,rng:NextNumber(1.4,3.5),0)
        local endPoint=origin+direction*distance-Vector3.new(0,rng:NextNumber(.8,2.6),0)
        TweenService:Create(chip,TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=peak,Orientation=chip.Orientation+Vector3.new(60,80,30)}):Play()
        task.delay(.16,function()
            if chip.Parent then TweenService:Create(chip,TweenInfo.new(.32,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=endPoint,Transparency=1,Orientation=chip.Orientation+Vector3.new(80,60,40)}):Play()end
        end)
        Debris:AddItem(chip,.51)
    end
    local sound=Instance.new("Sound");sound.Name="PickaxeImpact";sound.SoundId="rbxasset://sounds/action_jump_land.mp3"
    sound.Volume=large and .38 or .23;sound.PlaybackSpeed=rng:NextNumber(1.1,1.4);sound.Parent=root;sound:Play();Debris:AddItem(sound,1.2)
end

return Impact
