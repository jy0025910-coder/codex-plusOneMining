-- Operates on authored, inspectable UI. Does not create or own gameplay state.
local Layout = {}
function Layout.Apply(root, size, menuOpen, offersOpen)
    local w,h=size.X,size.Y
    local full=w>=1100 and h>=650
    local top=root.TopRow
    local head=top.LevelHeader
    local offer=top.MultiplierOffer
    if full then
        local headerW=math.min(720,w*.47)
        top.Size=UDim2.fromOffset(headerW+214,90)
        top.Position=UDim2.new(.5,0,0,10)
        head.Size=UDim2.fromOffset(headerW,54)
        head.LevelBadge.Size=UDim2.fromOffset(132,54)
        head.ProgressTrack.Position=UDim2.fromOffset(139,6)
        head.ProgressTrack.Size=UDim2.new(1,-145,0,42)
        head.LevelBadge.Label.TextSize=29
        head.ProgressTrack.ProgressText.TextSize=28
        offer.Position=UDim2.fromOffset(headerW+14,0)
        offer.Size=UDim2.fromOffset(200,76)
        offer.Label.TextSize=24
        offer.Price.TextSize=23
        offer.Multiplier.TextSize=24
        head.Remaining.TextSize=17
    else
        local groupW=math.min(w-24,700)
        local offerW=w<540 and 104 or 154
        local headerW=groupW-offerW-10
        top.Size=UDim2.fromOffset(groupW,82)
        top.Position=UDim2.new(.5,0,0,8)
        head.Size=UDim2.fromOffset(headerW,42)
        local badgeW=w<540 and 76 or 100
        head.LevelBadge.Size=UDim2.fromOffset(badgeW,42)
        head.ProgressTrack.Position=UDim2.fromOffset(badgeW+5,5)
        head.ProgressTrack.Size=UDim2.new(1,-badgeW-10,0,32)
        head.LevelBadge.Label.TextSize=w<540 and 18 or 23
        head.ProgressTrack.ProgressText.TextSize=w<540 and 17 or 23
        offer.Position=UDim2.fromOffset(headerW+10,0)
        offer.Size=UDim2.fromOffset(offerW,59)
        offer.Label.TextSize=w<540 and 15 or 19
        offer.Price.TextSize=w<540 and 16 or 19
        offer.Multiplier.TextSize=w<540 and 17 or 22
        head.Remaining.TextSize=w<540 and 12 or 14
    end
    local grid=root.MenuGrid
    local toggle=root.MenuToggle
    root:SetAttribute("LayoutMode",full and "Full" or "Compact")
    toggle.Visible=not full
    toggle.Position=UDim2.fromOffset(14,94)
    grid.Visible=full or menuOpen
    grid.BackgroundTransparency=full and 1 or .05
    local cols,cellW,cellH,gap
    if full then
        cols,cellW,cellH,gap=2,82,88,8
        grid.Position=UDim2.fromOffset(16,math.max(112,math.min(h*.18,h-566)))
    elseif w>=700 then
        cols,cellW,cellH,gap=4,62,68,7
        grid.Position=UDim2.fromOffset(14,194)
    else
        cols,cellW,cellH,gap=2,62,68,7
        grid.Position=UDim2.fromOffset(14,194)
    end
    local rows=math.ceil(8/cols)
    grid.Size=UDim2.fromOffset(cols*cellW+(cols-1)*gap,rows*cellH+(rows-1)*gap)
    grid.Grid.CellSize=UDim2.fromOffset(cellW,cellH)
    grid.Grid.CellPadding=UDim2.fromOffset(gap,gap)
    grid.Grid.FillDirectionMaxCells=cols
    for _,tile in grid:GetChildren()do
        if tile:IsA("TextButton")then
            tile.Label.TextSize=full and 19 or 15
            tile.Icon.Size=UDim2.new(1,-10,1,-23)
            tile.Label.Size=UDim2.new(1,-2,0,full and 25 or 21)
        end
    end
    local resources=root.ResourceList
    if full then
        resources.AnchorPoint=Vector2.new(0,1)
        resources.Position=UDim2.new(0,16,1,-20)
        resources.Size=UDim2.fromOffset(226,154)
        resources.List.FillDirection=Enum.FillDirection.Vertical
        resources.List.Padding=UDim.new(0,6)
        for _,row in resources:GetChildren()do if row:IsA("Frame")then
            row.Size=UDim2.fromOffset(226,46)
            row.Icon.Size=UDim2.fromOffset(54,54)
            row.Label.Visible=true;row.Label.TextSize=17
            row.Value.Position=UDim2.fromOffset(105,0)
            row.Value.Size=UDim2.new(1,-113,1,0);row.Value.TextSize=27
        end end
    else
        local total=math.min(w-28,500)
        local rw=math.floor((total-12)/3)
        resources.AnchorPoint=Vector2.new(.5,0)
        resources.Position=UDim2.new(.5,0,0,79)
        resources.Size=UDim2.fromOffset(total,34)
        resources.List.FillDirection=Enum.FillDirection.Horizontal
        resources.List.Padding=UDim.new(0,6)
        for _,row in resources:GetChildren()do if row:IsA("Frame")then
            row.Size=UDim2.fromOffset(rw,34)
            row.Icon.Size=UDim2.fromOffset(38,38)
            row.Label.Visible=false
            row.Value.Position=UDim2.fromOffset(34,0)
            row.Value.Size=UDim2.new(1,-39,1,0);row.Value.TextSize=w<540 and 19 or 23
        end end
        toggle.Position=UDim2.fromOffset(14,124)
    end
    local offers=root.PowerOffers
    root.OffersToggle.Visible=not full
    root.OffersToggle.Position=UDim2.new(1,-14,0,124)
    offers.Visible=full or offersOpen
    local ow=full and 218 or 178
    local oh=full and 91 or 69
    offers.Size=UDim2.fromOffset(ow,oh*3+20)
    offers.Position=full and UDim2.new(1,-16,.46,0)or UDim2.new(1,-14,0,194)
    offers.AnchorPoint=Vector2.new(1,full and .5 or 0)
    offers.List.FillDirection=Enum.FillDirection.Vertical
    if not full and w>=700 and h<460 then
        local total=math.min(w-28,554)
        ow=math.floor((total-20)/3)
        offers.Size=UDim2.fromOffset(total,oh)
        offers.List.FillDirection=Enum.FillDirection.Horizontal
    elseif not full then
        oh=math.clamp(math.floor((h-238)/3),48,69)
        offers.Size=UDim2.fromOffset(ow,oh*3+20)
    end
    for _,tile in offers:GetChildren()do if tile:IsA("TextButton")then
        tile.Size=UDim2.fromOffset(ow,oh)
        tile.Label.TextSize=full and 24 or 19
        tile.Price.TextSize=full and 22 or 19
    end end
    root.Status.Guide.Size=UDim2.fromOffset(math.min(600,w-48),26)
    root.Status.Guide.Visible=full
    root.Status.Toast.Size=UDim2.fromOffset(math.min(620,w-30),48)
    root.Status.Toast.Position=UDim2.new(.5,0,0,full and 102 or 116)
    root.Status.Target.Size=UDim2.fromOffset(math.min(600,w-30),32)
    root.Status.Target.Position=UDim2.new(.5,0,1,-(full and 76 or 50))
    root.ReturnToCamp.Position=UDim2.new(1,-16,1,-(full and 45 or 16))
    root.ReturnToCamp.Size=UDim2.fromOffset(full and 132 or 114,32)
    root.PreviewNote.Visible=full
    return full
end
return Layout
