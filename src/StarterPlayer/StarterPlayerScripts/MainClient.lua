-- Simple test client script for CosmoCat
print("=== SIMPLE CLIENT SCRIPT STARTING ===")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Wait for everything to initialize
wait(1)

-- Simple score tracking
local playerScore = 0

-- Check for CatTreat collection
local function CheckCatTreatCollection()
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Find CatTreats in the workspace
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "CatTreat" and obj.Parent then
            local distance = (humanoidRootPart.Position - obj.Position).Magnitude
            local collectionRange = 5 -- Distance to collect
            
            if distance <= collectionRange then
                -- Collect the CatTreat
                local points = obj:FindFirstChild("Points")
                if points then
                    playerScore = playerScore + points.Value
                    print("Collected CatTreat! Score:", playerScore)
                end
                
                -- Remove the CatTreat
                obj:Destroy()
            end
        end
    end
end

-- Set up collection detection
RunService.Heartbeat:Connect(CheckCatTreatCollection)

print("Client collection system initialized")
print("=== SIMPLE CLIENT SCRIPT COMPLETE ===")
