-- Export only changed, readable, engine-serialized properties; preserve hierarchy and Attributes.
local Reflection=game:GetService("ReflectionService")
local Http=game:GetService("HttpService")
local defaults,properties={},{}
local function value(v)
    local t=typeof(v)
    if t=="number"or t=="string"or t=="boolean"then return v end
    if t=="EnumItem"then return v.Value end
    if t=="UDim2"then return {v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset}end
    if t=="UDim"then return {v.Scale,v.Offset}end
    if t=="Vector2"then return {v.X,v.Y}end
    if t=="Color3"then return {v.R,v.G,v.B}end
    if t=="Rect"then return {v.Min.X,v.Min.Y,v.Max.X,v.Max.Y}end
    if t=="Font"then return {v.Family,v.Weight.Value,v.Style.Name}end
    if t=="Content"then return v.SourceType==Enum.ContentSourceType.Uri and v.Uri or ""end
    if t=="NumberSequence"then local a={};for _,p in v.Keypoints do table.insert(a,{p.Time,p.Value,p.Envelope})end;return a end
    if t=="ColorSequence"then local a={};for _,p in v.Keypoints do table.insert(a,{p.Time,p.Value.R,p.Value.G,p.Value.B,0})end;return a end
    if t=="nil"then return nil end
    error("Unsupported serialized property value: "..t)
end
local function snapshot(o)
    local class=o.ClassName
    if not defaults[class]then defaults[class]=Instance.new(class);properties[class]=Reflection:GetPropertiesOfClass(class)end
    local n={c=class,p={},a=o:GetAttributes(),children={}}
    for _,p in properties[class]do
        if p.Serialized and p.Type.EngineType~="SecurityCapabilities"then
            local ok,a=pcall(function()return value(o[p.Name])end)
            local same,b=pcall(function()return value(defaults[class][p.Name])end)
            if ok and (not same or Http:JSONEncode(a)~=Http:JSONEncode(b))then
                table.insert(n.p,{n=p.Name,t=p.Type.EngineType,v=a})
            end
        end
    end
    if o:IsA("LuaSourceContainer")then table.insert(n.p,{n="Source",t="ProtectedString",v=o.Source})end
    table.sort(n.p,function(a,b)return a.n<b.n end)
    for _,child in o:GetChildren()do table.insert(n.children,snapshot(child))end
    return n
end
_G.SnapshotMiningUI=snapshot
return snapshot
