-- CatTreat spawning system for CosmoCat
print("=== CATTREAT SYSTEM STARTING ===")

local TweenService = game:GetService("TweenService")

-- Wait for everything to initialize
wait(2)

-- Create CatTreat Part
local function CreateCatTreat()
    local catTreat = Instance.new("Part")
    catTreat.Name = "CatTreat"
    catTreat.Size = Vector3.new(2, 2, 2)
    catTreat.Color = Color3.fromRGB(255, 215, 0) -- Gold color
    catTreat.Material = Enum.Material.Neon
    catTreat.Anchored = true
    catTreat.CanCollide = false
    catTreat.Position = Vector3.new(0, 20, 0) -- Above spawn point
    catTreat.Parent = workspace
    
    -- Add point value
    local points = Instance.new("IntValue")
    points.Name = "Points"
    points.Value = 1
    points.Parent = catTreat
    
    print("CatTreat Part created successfully!")
    return catTreat
end

-- Spawn and animate CatTreat
local catTreat = CreateCatTreat()

-- Animate the CatTreat falling
local tween = TweenService:Create(
    catTreat,
    TweenInfo.new(3, Enum.EasingStyle.Linear),
    {Position = Vector3.new(0, 5, 0)} -- Land at ground level
)
tween:Play()
tween.Completed:Connect(function()
    print("CatTreat landed at:", catTreat.Position)
end)

print("=== CATTREAT SYSTEM COMPLETE ===")
