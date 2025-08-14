-- CatTreat spawning system for CosmoCat
print("=== CATTREAT SYSTEM STARTING ===")

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Configuration
local MAX_CATTREATS = 25
local SPAWN_HEIGHT = 50
local LAND_HEIGHT = 5
local PLAY_AREA_SIZE = 100 -- ±50 studs from center
local FALL_TIME = 4 -- seconds to fall

-- Wait for everything to initialize
wait(2)

-- Debug: Check what's in the Workspace
print("=== DEBUGGING WORKSPACE STRUCTURE ===")
print("Workspace children:")
for _, child in pairs(Workspace:GetChildren()) do
    print("  -", child.Name, "(" .. child.ClassName .. ")")
end

-- Check for CatTreat model directly in Workspace
if Workspace:FindFirstChild("CatTreat") then
    print("CatTreat model found directly in Workspace!")
    local catTreatModel = Workspace.CatTreat
    print("  -", catTreatModel.Name, "(" .. catTreatModel.ClassName .. ")")
    
    if catTreatModel:IsA("Model") then
        print("  - It's a Model with PrimaryPart:", catTreatModel.PrimaryPart and "Yes" or "No")
        if catTreatModel.PrimaryPart then
            print("  - PrimaryPart size:", catTreatModel.PrimaryPart.Size)
        end
    end
else
    print("CatTreat model NOT found in Workspace!")
end

if Workspace:FindFirstChild("Map") then
    print("Map folder found!")
    print("Map children:")
    for _, child in pairs(Workspace.Map:GetChildren()) do
        print("  -", child.Name, "(" .. child.ClassName .. ")")
    end
    
    if Workspace.Map:FindFirstChild("CatTreat") then
        print("CatTreat folder found!")
        print("CatTreat folder children:")
        for _, child in pairs(Workspace.Map.CatTreat:GetChildren()) do
            print("  -", child.Name, "(" .. child.ClassName .. ")")
        end
    else
        print("CatTreat folder NOT found!")
    end
else
    print("Map folder NOT found!")
end
print("=== END DEBUGGING ===")

-- Create CatTreat using the actual model
local function CreateCatTreat()
    -- Try to find the CatTreat model in the correct location
    local catTreatModel = nil
    
    -- First, try to find it directly in Workspace (where it actually is)
    if Workspace:FindFirstChild("CatTreat") and Workspace.CatTreat:IsA("Model") then
        catTreatModel = Workspace.CatTreat
        print("Found CatTreat model directly in Workspace:", catTreatModel.Name)
    -- Fallback: try the Map folder
    elseif Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("CatTreat") then
        -- Look for any Model in the CatTreat folder
        for _, child in pairs(Workspace.Map.CatTreat:GetChildren()) do
            if child:IsA("Model") then
                catTreatModel = child
                print("Found CatTreat model in Map folder:", child.Name)
                break
            end
        end
        
        -- If no Model found, look for any Part
        if not catTreatModel then
            for _, child in pairs(Workspace.Map.CatTreat:GetChildren()) do
                if child:IsA("BasePart") then
                    catTreatModel = child
                    print("Found CatTreat part in Map folder:", child.Name)
                    break
                end
            end
        end
    end
    
    local catTreat
    
    if catTreatModel then
        -- Clone the actual CatTreat model
        catTreat = catTreatModel:Clone()
        
        -- Scale down ALL parts in the model to fix the huge mesh issue
        local scale = 0.03 -- Adjust this value as needed (0.03 = 3% of original size)
        for _, part in pairs(catTreat:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * scale
                -- Set properties on individual parts, not the model
                part.Anchored = true
                part.CanCollide = false
                -- Also scale any meshes
                local mesh = part:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.Scale = Vector3.new(scale, scale, scale)
                end
            end
        end
        
        print("CatTreat Model cloned successfully and scaled to", scale * 100, "% of original size!")
    else
        -- Fallback to creating a simple Part if model not found
        catTreat = Instance.new("Part")
        catTreat.Name = "CatTreat"
        catTreat.Size = Vector3.new(2, 2, 2)
        catTreat.Color = Color3.fromRGB(255, 215, 0) -- Gold color
        catTreat.Material = Enum.Material.Neon
        catTreat.Anchored = true
        catTreat.CanCollide = false
        print("CatTreat Model not found, created fallback Part")
    end
    
    catTreat.Parent = workspace
    
    -- Add point value
    local points = Instance.new("IntValue")
    points.Name = "Points"
    points.Value = 1
    points.Parent = catTreat
    
    return catTreat
end

-- Spawn a single CatTreat at random position
local function SpawnCatTreat()
    local catTreat = CreateCatTreat()
    
    -- Random spawn position in the sky (diagonal shooting star effect)
    local spawnX = math.random(-PLAY_AREA_SIZE, PLAY_AREA_SIZE)
    local spawnZ = math.random(-PLAY_AREA_SIZE, PLAY_AREA_SIZE)
    local spawnPos = Vector3.new(spawnX, SPAWN_HEIGHT, spawnZ)
    
    -- Random landing position on the ground (spread out)
    local landX = math.random(-PLAY_AREA_SIZE, PLAY_AREA_SIZE)
    local landZ = math.random(-PLAY_AREA_SIZE, PLAY_AREA_SIZE)
    local landPos = Vector3.new(landX, LAND_HEIGHT, landZ)
    
    -- Set initial position based on whether it's a Model or Part
    if catTreat:IsA("Model") then
        -- For models, set the PrimaryPart position
        if catTreat.PrimaryPart then
            catTreat.PrimaryPart.Position = spawnPos
        else
            -- If no PrimaryPart, set the first Part's position
            local firstPart = catTreat:FindFirstChildOfClass("Part")
            if firstPart then
                firstPart.Position = spawnPos
            end
        end
    else
        -- For Parts, set position directly
        catTreat.Position = spawnPos
    end
    
    -- Animate the CatTreat falling (shooting star effect)
    if catTreat:IsA("Model") then
        -- For models, animate the PrimaryPart or first Part
        local partToAnimate = catTreat.PrimaryPart or catTreat:FindFirstChildOfClass("Part")
        if partToAnimate then
            local tween = TweenService:Create(
                partToAnimate,
                TweenInfo.new(FALL_TIME, Enum.EasingStyle.Linear),
                {Position = landPos}
            )
            tween:Play()
            tween.Completed:Connect(function()
                print("CatTreat landed at:", partToAnimate.Position)
            end)
        end
    else
        -- For Parts, animate directly
        local tween = TweenService:Create(
            catTreat,
            TweenInfo.new(FALL_TIME, Enum.EasingStyle.Linear),
            {Position = landPos}
        )
        tween:Play()
        tween.Completed:Connect(function()
            print("CatTreat landed at:", catTreat.Position)
        end)
    end
    
    return catTreat
end

-- Spawn all CatTreats with staggered timing
local function SpawnAllCatTreats()
    print("Starting CatTreat spawning...")
    local spawnedCount = 0
    
    -- Spawn CatTreats with slight delays to create a nice effect
    for i = 1, MAX_CATTREATS do
        spawn(function()
            local catTreat = SpawnCatTreat()
            spawnedCount = spawnedCount + 1
            print("Spawned CatTreat", spawnedCount, "of", MAX_CATTREATS)
            
            -- Small delay between spawns
            wait(0.2)
        end)
    end
    
    -- Wait for all to spawn, then announce completion
    wait(MAX_CATTREATS * 0.2 + FALL_TIME)
    print("All", MAX_CATTREATS, "CatTreats spawned and landed!")
end

-- Start spawning
SpawnAllCatTreats()

print("=== CATTREAT SYSTEM COMPLETE ===")
