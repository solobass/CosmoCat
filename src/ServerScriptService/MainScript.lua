-- Simple test server script for CosmoCat
print("=== SIMPLE SERVER SCRIPT STARTING ===")

local TweenService = game:GetService("TweenService")

-- Wait for everything to initialize
wait(2)

-- Create ONE simple CatTreat
local function CreateSimpleCatTreat()
    print("Creating simple CatTreat...")
    
    -- Create a simple Part (not a Model for now)
    local catTreat = Instance.new("Part")
    catTreat.Name = "CatTreat"
    catTreat.Size = Vector3.new(3, 3, 3)
    catTreat.Color = Color3.fromRGB(255, 215, 0) -- Gold color
    catTreat.Material = Enum.Material.Neon
    catTreat.Anchored = true
    catTreat.CanCollide = false
    catTreat.Position = Vector3.new(0, 20, 0) -- Right above spawn point
    catTreat.Parent = workspace
    
    -- Add point value
    local points = Instance.new("IntValue")
    points.Name = "Points"
    points.Value = 1
    points.Parent = catTreat
    
    print("CatTreat created at position:", catTreat.Position)
    return catTreat
end

-- Spawn the CatTreat
local catTreat = CreateSimpleCatTreat()

-- Make it fall to the ground
local tween = TweenService:Create(
    catTreat,
    TweenInfo.new(3, Enum.EasingStyle.Linear),
    {Position = Vector3.new(0, 5, 0)} -- Land at ground level
)

tween:Play()
tween.Completed:Connect(function()
    print("CatTreat landed!")
end)

print("=== SIMPLE SERVER SCRIPT COMPLETE ===")
