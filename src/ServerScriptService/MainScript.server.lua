-- CatTreat spawning system for CosmoCat
print("=== CATTREAT SYSTEM STARTING ===")

-- Create RemoteEvent for client-server communication IMMEDIATELY
print("DEBUG: Creating RemoteEvents...")
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = game:GetService("ReplicatedStorage")

local CollectCatTreatEvent = Instance.new("RemoteEvent")
CollectCatTreatEvent.Name = "CollectCatTreat"
CollectCatTreatEvent.Parent = RemoteEvents

print("DEBUG: RemoteEvents created successfully!")
print("DEBUG: CollectCatTreatEvent exists:", CollectCatTreatEvent ~= nil)
print("DEBUG: CollectCatTreatEvent Parent:", CollectCatTreatEvent.Parent.Name)
print("DEBUG: CollectCatTreatEvent Full Path:", CollectCatTreatEvent:GetFullName())
print("DEBUG: RemoteEvents folder children count:", #RemoteEvents:GetChildren())

-- Wait a moment to ensure the RemoteEvent is fully created
wait(0.1)
print("DEBUG: RemoteEvent creation confirmed, proceeding with rest of system...")
print("DEBUG: Final RemoteEvents folder children:")
for _, child in pairs(RemoteEvents:GetChildren()) do
    print("  -", child.Name, "(" .. child.ClassName .. ")")
end

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Initialize Cat Avatar System
local CatAvatarManager = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CatAvatarManager"))
print("DEBUG: CatAvatarManager loaded successfully")

-- Handle CatTreat collection requests from clients FIRST
local function HandleCatTreatCollection(player, catTreatInfo)
    print("DEBUG: ===== CATTREAT COLLECTION REQUEST RECEIVED =====")
    print("DEBUG: Player:", player.Name)
    print("DEBUG: CatTreat Info:", catTreatInfo)
    
    if not catTreatInfo then
        print("DEBUG: CatTreatInfo is nil")
        return
    end
    
    if type(catTreatInfo) ~= "table" then
        print("DEBUG: CatTreatInfo is not a table, it's:", type(catTreatInfo))
        return
    end
    
    print("DEBUG: CatTreat Name:", catTreatInfo.name)
    print("DEBUG: CatTreat Position:", catTreatInfo.position)
    print("DEBUG: CatTreat ClassName:", catTreatInfo.className)
    
    -- Find the actual CatTreat object in workspace by name and position
    local foundCatTreat = nil
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == catTreatInfo.name and obj:IsA(catTreatInfo.className) then
            -- Check if position matches (within reasonable tolerance)
            local objPosition
            if obj:IsA("Model") then
                objPosition = obj.PrimaryPart and obj.PrimaryPart.Position or obj:FindFirstChildOfClass("Part") and obj:FindFirstChildOfClass("Part").Position
            else
                objPosition = obj.Position
            end
            
            if objPosition and (objPosition - catTreatInfo.position).Magnitude < 5 then
                foundCatTreat = obj
                break
            end
        end
    end
    
    if not foundCatTreat then
        print("DEBUG: Could not find CatTreat in workspace matching the info")
        return
    end
    
    print("DEBUG: Found CatTreat:", foundCatTreat.Name)
    print("DEBUG: CatTreat Parent:", foundCatTreat.Parent.Name)
    
    -- Check if CatTreat has points
    local points = foundCatTreat:FindFirstChild("Points")
    if points then
        print("DEBUG: CatTreat has", points.Value, "points")
        -- The client will handle score and level progression
        -- We just need to destroy the CatTreat
        print("DEBUG: About to destroy CatTreat...")
        foundCatTreat:Destroy()
        print("DEBUG: CatTreat destroyed by server successfully!")
    else
        print("DEBUG: CatTreat has no Points value")
        print("DEBUG: CatTreat children:")
        for _, child in pairs(foundCatTreat:GetChildren()) do
            print("  -", child.Name, "(" .. child.ClassName .. ")")
        end
    end
    print("DEBUG: ===== END CATTREAT COLLECTION =====")
end

-- Connect the RemoteEvent immediately
CollectCatTreatEvent.OnServerEvent:Connect(HandleCatTreatCollection)
print("DEBUG: CatTreat collection handler connected!")

-- Configuration
local MAX_CATTREATS = 25
local SPAWN_HEIGHT = 50
local LAND_HEIGHT = 1 -- Lowered from 5 to 1 stud above baseplate
local PLAY_AREA_SIZE = 100 -- ±50 studs from center
local FALL_TIME = 4 -- seconds to fall

-- Function to create a CatTreat
local function CreateCatTreat()
    -- Try to find the actual CatTreat model first
    local catModelsFolder = ReplicatedStorage:FindFirstChild("CatModels")
    if not catModelsFolder then
        print("DEBUG: CatModels folder not found in ReplicatedStorage")
        print("DEBUG: ReplicatedStorage children:")
        for _, child in pairs(ReplicatedStorage:GetChildren()) do
            print("  -", child.Name, "(" .. child.ClassName .. ")")
        end
    else
        print("DEBUG: CatModels folder found, looking for CatTreat...")
        local catTreatModel = catModelsFolder:FindFirstChild("CatTreat")
        if catTreatModel then
            print("DEBUG: Found CatTreat model, cloning it")
            local catTreat = catTreatModel:Clone()
            
            -- Scale the model appropriately
            for _, part in pairs(catTreat:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * 0.03
                end
            end
            
            -- Set properties for all BasePart descendants
            for _, part in pairs(catTreat:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                    part.CanCollide = false
                end
            end
            
            -- Add points value
            local points = Instance.new("IntValue")
            points.Name = "Points"
            points.Value = 1
            points.Parent = catTreat
            
            return catTreat
        else
            print("DEBUG: CatTreat model not found in CatModels folder")
            print("DEBUG: CatModels folder children:")
            for _, child in pairs(catModelsFolder:GetChildren()) do
                print("  -", child.Name, "(" .. child.ClassName .. ")")
            end
        end
    end
    
    -- Also check if CatTreat is directly in Workspace (where you said you put it)
    local workspaceCatTreat = Workspace:FindFirstChild("CatTreat")
    if workspaceCatTreat then
        print("DEBUG: Found CatTreat directly in Workspace, cloning it")
        local catTreat = workspaceCatTreat:Clone()
        
        -- Scale the model appropriately
        for _, part in pairs(catTreat:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * 0.03
            end
        end
        
        -- Set properties for all BasePart descendants
        for _, part in pairs(catTreat:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
                part.CanCollide = false
            end
        end
        
        -- Add points value
        local points = Instance.new("IntValue")
        points.Name = "Points"
        points.Value = 1
        points.Parent = catTreat
        
        return catTreat
    end
    
    print("DEBUG: CatTreat model not found anywhere, creating fallback Part")
    -- Fallback: create a simple Part if the model isn't found
    local catTreat = Instance.new("Part")
    catTreat.Name = "CatTreat"
    catTreat.Size = Vector3.new(2, 2, 2)
    catTreat.Color = Color3.fromRGB(255, 255, 0) -- Yellow
    catTreat.Material = Enum.Material.Neon
    catTreat.Anchored = true
    catTreat.CanCollide = false
    
    -- Add points value
    local points = Instance.new("IntValue")
    points.Name = "Points"
    points.Value = 1
    points.Parent = catTreat
    
    return catTreat
end

-- Spawn a single CatTreat at random position
local function SpawnCatTreat()
    local catTreat = CreateCatTreat()
    
    -- Add the CatTreat to workspace so the client can see it
    catTreat.Parent = workspace
    
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

-- Spawn all CatTreats efficiently
local function SpawnAllCatTreats()
    print("Starting CatTreat spawning...")
    local spawnedCount = 0
    
    -- Spawn all CatTreats immediately without delays
    for i = 1, MAX_CATTREATS do
        local catTreat = SpawnCatTreat()
        spawnedCount = spawnedCount + 1
        print("Spawned CatTreat", spawnedCount, "of", MAX_CATTREATS)
    end
    
    print("All", MAX_CATTREATS, "CatTreats spawned! They will land in", FALL_TIME, "seconds.")
end

-- Start spawning immediately
print("DEBUG: Starting CatTreat spawning immediately...")
SpawnAllCatTreats()

print("=== CATTREAT COLLECTION HANDLER SETUP COMPLETE ===")

print("=== CATTREAT SYSTEM COMPLETE ===")

-- Initialize the Cat Avatar System
print("=== INITIALIZING CAT AVATAR SYSTEM ===")
CatAvatarManager.Initialize()
print("=== CAT AVATAR SYSTEM COMPLETE ===")

print("=== COSMOCAT GAME SERVER FULLY INITIALIZED ===")

