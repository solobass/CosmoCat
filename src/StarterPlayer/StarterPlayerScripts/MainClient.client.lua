-- CatTreat collection system for CosmoCat
print("=== CATTREAT COLLECTION SYSTEM STARTING ===")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerScore = 0

-- Wait for everything to initialize
wait(1)

-- Check for CatTreat collection
local function CheckCatTreatCollection()
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Find CatTreats in the workspace
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "CatTreat" and obj.Parent then
            local distance
            local collectionRange = 5 -- Distance to collect
            
            if obj:IsA("Model") then
                -- For Models, check distance to PrimaryPart or first Part
                local partToCheck = obj.PrimaryPart or obj:FindFirstChildOfClass("Part")
                if partToCheck then
                    distance = (humanoidRootPart.Position - partToCheck.Position).Magnitude
                else
                    distance = math.huge -- Can't collect if no parts
                end
            else
                -- For Parts, check distance directly
                distance = (humanoidRootPart.Position - obj.Position).Magnitude
            end
            
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

-- Create score display
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScoreUI"
screenGui.Parent = playerGui

local scoreLabel = Instance.new("TextLabel")
scoreLabel.Name = "ScoreLabel"
scoreLabel.Size = UDim2.new(0, 200, 0, 50)
scoreLabel.Position = UDim2.new(1, -220, 1, -70) -- Lower right corner
scoreLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
scoreLabel.BackgroundTransparency = 0.5
scoreLabel.BorderSizePixel = 0
scoreLabel.Text = "Meow: 0"
scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
scoreLabel.TextScaled = true
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.Parent = screenGui

-- Update score display
local function UpdateScore()
    scoreLabel.Text = "Meow: " .. tostring(playerScore)
end

RunService.Heartbeat:Connect(UpdateScore)

print("CatTreat collection system initialized")
print("Score display created")
print("=== CATTREAT COLLECTION SYSTEM COMPLETE ===")
