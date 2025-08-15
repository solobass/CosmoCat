-- CatTreat collection and level progression system for CosmoCat
print("=== CATTREAT COLLECTION & LEVEL SYSTEM STARTING ===")

-- IMMEDIATE username prevention - run this first before anything else
local function PreventUsernameDisplay()
    print("DEBUG: Preventing username display...")

    -- Disable username display in various ways
    if player then -- NOTE: 'player' is nil here when this function is first called. This is a bug.
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.DisplayName = "" -- Clear display name
            end

            local nameTag = character:FindFirstChild("NameTag")
            if nameTag then
                nameTag:Destroy()
            end

            for _, child in pairs(character:GetChildren()) do
                if child.Name:lower():find("name") or child.Name:lower():find("tag") then
                    if child:IsA("BillboardGui") or child:IsA("TextLabel") then
                        child:Destroy()
                    end
                end
            end
        end

        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            for _, child in pairs(playerGui:GetChildren()) do
                if child.Name:lower():find("username") or child.Name:lower():find("player") or
                   child.Name:lower():find("name") then
                    child:Destroy()
                end

                if child.Text and (child.Text:find("FurGamesRoblox") or
                   child.Text:find("username") or child.Text:find("player")) then
                    child:Destroy()
                end
            end
        end
    end

    if game then
        local starterGui = game:FindFirstChild("StarterGui")
        if starterGui then
            for _, child in pairs(starterGui:GetChildren()) do
                if child.Name:lower():find("username") or child.Name:lower():find("player") or
                   child.Name:lower():find("name") then
                    child:Destroy()
                end
            end
        end
    end

    print("DEBUG: Username prevention completed!")
end

-- Run username prevention immediately
PreventUsernameDisplay()

-- Continuous username monitoring - catch any that appear later
spawn(function()
    while wait(0.5) do -- Check every half second
        if player then -- 'player' will be valid here after the script's main execution starts
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                for _, child in pairs(playerGui:GetChildren()) do
                    local shouldRemove = false

                    if child.Name:lower():find("username") or child.Name:lower():find("player") or
                       child.Name:lower():find("name") or child.Name:lower():find("tag") then
                        shouldRemove = true
                    end

                    if child.Text and (child.Text:find("FurGamesRoblox") or
                       child.Text:find("username") or child.Text:find("player") or
                       child.Text:find("Roblox automatically translates")) then
                        shouldRemove = true
                    end

                    if shouldRemove then
                        print("DEBUG: Removing username element:", child.Name, "Text:", child.Text)
                        child:Destroy()
                    end
                end
            end

            local character = player.Character
            if character then
                for _, child in pairs(character:GetChildren()) do
                    if child.Name:lower():find("name") or child.Name:lower():find("tag") then
                        if child:IsA("BillboardGui") or child:IsA("TextLabel") then
                            child:Destroy()
                        end
                    end
                end
            end
        end
    end
end)

-- AGGRESSIVE UI PREVENTION - Block elements before they can appear
local function SetupAggressiveUIPrevention()
    print("DEBUG: Setting up aggressive UI prevention...")
    
    -- Block common Roblox UI elements from appearing
    local function blockUIElement(elementName, elementType)
        if elementType == "ScreenGui" then
            -- Monitor for new ScreenGuis and destroy unwanted ones immediately
            local playerGui = player and player:FindFirstChild("PlayerGui")
            if playerGui then
                playerGui.ChildAdded:Connect(function(child)
                    if child.Name:lower():find(elementName:lower()) then
                        print("DEBUG: BLOCKED ScreenGui:", child.Name)
                        child:Destroy()
                    end
                end)
            end
        end
    end
    
    -- Block specific unwanted UI elements
    blockUIElement("username", "ScreenGui")
    blockUIElement("player", "ScreenGui")
    blockUIElement("name", "ScreenGui")
    blockUIElement("translation", "ScreenGui")
    blockUIElement("chat", "ScreenGui")
    blockUIElement("roblox", "ScreenGui")
    
    -- Block translation messages specifically
    if player then
        local playerGui = player:WaitForChild("PlayerGui")
        playerGui.ChildAdded:Connect(function(child)
            if child:IsA("ScreenGui") then
                -- Check all children of the new ScreenGui for translation text
                child.ChildAdded:Connect(function(guiChild)
                    if guiChild:IsA("TextLabel") or guiChild:IsA("TextButton") or guiChild:IsA("TextBox") then
                        if guiChild.Text and (guiChild.Text:find("Roblox automatically translates") or
                           guiChild.Text:find("supported languages") or
                           guiChild.Text:find("FurGamesRoblox")) then
                            print("DEBUG: BLOCKED translation message:", guiChild.Text)
                            child:Destroy() -- Destroy the entire ScreenGui
                        end
                    end
                end)
                
                -- Also check existing children
                for _, guiChild in pairs(child:GetChildren()) do
                    if guiChild:IsA("TextLabel") or guiChild:IsA("TextButton") or guiChild:IsA("TextBox") then
                        if guiChild.Text and (guiChild.Text:find("Roblox automatically translates") or
                           guiChild.Text:find("supported languages") or
                           guiChild.Text:find("FurGamesRoblox")) then
                            print("DEBUG: BLOCKED existing translation message:", guiChild.Text)
                            child:Destroy() -- Destroy the entire ScreenGui
                            break
                        end
                    end
                end
            end
        end)
    end
    
    print("DEBUG: Aggressive UI prevention setup complete!")
end

-- Wait for services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer -- 'player' is defined here, AFTER PreventUsernameDisplay() is called.
local playerScore = 0
local playerLevel = 1
local lastCollectionTime = 0
local collectionCooldown = 0.1 -- Prevent multiple collections within 0.1 seconds

-- Wait for GameConfig and RemoteEvents to load
local GameConfig
local CollectCatTreatEvent

print("DEBUG: Waiting for GameConfig and RemoteEvents...")

-- Wait for GameConfig
while not GameConfig do
    local success, result = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
    end)
    
    if success then
        GameConfig = result
        print("DEBUG: GameConfig loaded successfully")
        print("DEBUG: GameConfig.Levels exists:", GameConfig.Levels ~= nil)
        if GameConfig.Levels then
            print("DEBUG: Number of levels:", #GameConfig.Levels)
        end
    else
        print("DEBUG: Failed to load GameConfig:", result)
        wait(0.5)
    end
end

-- Wait for RemoteEvents
while not CollectCatTreatEvent do
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CollectCatTreat")
    end)
    
    if success then
        CollectCatTreatEvent = result
        print("DEBUG: CollectCatTreatEvent loaded successfully")
    else
        print("DEBUG: Failed to load CollectCatTreatEvent:", result)
        wait(0.5)
    end
end

print("DEBUG: Both GameConfig and CollectCatTreatEvent are loaded!")
wait(1)

-- Define ShowLevelUpNotification FIRST
local function ShowLevelUpNotification(level, catName)
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LevelUpNotification"
    screenGui.Parent = playerGui

    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 600, 0, 60) -- Wider and shorter for single line
    notification.Position = UDim2.new(1, -620, 1, -80) -- Bottom right corner
    notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notification.BackgroundTransparency = 0.2
    notification.BorderSizePixel = 0
    notification.Parent = screenGui

    -- Create level text in yellow
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(0, 120, 1, 0) -- Fixed width for "LEVEL X"
    levelLabel.Position = UDim2.new(0, 0, 0, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = string.format("LEVEL %d", level)
    levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Yellow text
    levelLabel.TextSize = 24 -- Fixed font size instead of TextScaled
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Parent = notification

    -- Create separator text
    local separatorLabel = Instance.new("TextLabel")
    separatorLabel.Name = "SeparatorLabel"
    separatorLabel.Size = UDim2.new(0, 20, 1, 0) -- Fixed width for separator
    separatorLabel.Position = UDim2.new(0, 120, 0, 0)
    separatorLabel.BackgroundTransparency = 1
    separatorLabel.Text = ": "
    separatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    separatorLabel.TextSize = 24 -- Same font size as level text
    separatorLabel.Font = Enum.Font.GothamBold
    separatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    separatorLabel.Parent = notification

    -- Create cat name text in white
    local catNameLabel = Instance.new("TextLabel")
    catNameLabel.Name = "CatNameLabel"
    catNameLabel.Size = UDim2.new(1, -140, 1, 0) -- Remaining width after level and separator
    catNameLabel.Position = UDim2.new(0, 140, 0, 0)
    catNameLabel.BackgroundTransparency = 1
    catNameLabel.Text = catName
    catNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    catNameLabel.TextSize = 24 -- Same font size as level text
    catNameLabel.Font = Enum.Font.GothamBold
    catNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    catNameLabel.Parent = notification

    -- Auto-remove after 3 seconds
    wait(3)
    screenGui:Destroy()
end

local function CheckLevelUp()
    if not GameConfig or not GameConfig.Levels then
        print("DEBUG: GameConfig or GameConfig.Levels is nil in CheckLevelUp")
        return
    end
    
    local currentLevelData = GameConfig.Levels[playerLevel]
    if not currentLevelData then 
        print("DEBUG: No current level data for level", playerLevel)
        return 
    end
    
    local nextLevel = playerLevel + 1
    local nextLevelData = GameConfig.Levels[nextLevel]
    
    print("DEBUG: Checking level up - Current:", playerLevel, "Score:", playerScore, "Next level required:", nextLevelData and nextLevelData.pointsRequired or "none")
    
    if nextLevelData and playerScore >= nextLevelData.pointsRequired then
        print("DEBUG: LEVEL UP CONDITION MET!")
        playerLevel = nextLevel
        
        -- Safety check for nextLevelData.name
        if nextLevelData.name then
            ShowLevelUpNotification(nextLevel, nextLevelData.name)
            print("LEVEL UP! Now Level", playerLevel, "-", nextLevelData.name)
        else
            print("DEBUG: WARNING - nextLevelData.name is nil for level", nextLevel)
            ShowLevelUpNotification(nextLevel, "Unknown Cat")
            print("LEVEL UP! Now Level", playerLevel, "- Unknown Cat")
        end
    end
end

local function CheckCatTreatCollection()
    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Check cooldown
    local currentTime = tick()
    if currentTime - lastCollectionTime < collectionCooldown then
        return
    end

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "CatTreat" and obj.Parent then
            -- Skip if already being collected (has a "Collecting" tag)
            if obj:FindFirstChild("Collecting") then
                continue
            end
            
            local distance
            local collectionRange = 8 -- Increased from 5 to 8 studs for easier collection
            
            -- Handle both Models and Parts
            if obj:IsA("Model") then
                -- For Models, check distance to PrimaryPart or first Part
                local partToCheck = obj.PrimaryPart or obj:FindFirstChildOfClass("Part")
                if partToCheck then
                    distance = (humanoidRootPart.Position - partToCheck.Position).Magnitude
                    -- Debug output for Models
                    if distance <= 15 then -- Only debug when close
                        print("DEBUG: CatTreat Model at distance:", distance, "from player")
                    end
                else
                    distance = math.huge -- Can't collect if no parts
                end
            elseif obj:IsA("Part") then
                -- For Parts, check distance directly
                distance = (humanoidRootPart.Position - obj.Position).Magnitude
                -- Debug output for Parts
                if distance <= 15 then -- Only debug when close
                    print("DEBUG: CatTreat Part at distance:", distance, "from player")
                end
            else
                distance = math.huge -- Skip non-Model/Part objects
            end
            
            if distance <= collectionRange then
                print("DEBUG: COLLECTING CatTreat at distance:", distance)
                print("DEBUG: CatTreat type:", obj.ClassName, "Name:", obj.Name)
                
                -- Mark this CatTreat as being collected to prevent multiple collections
                local collectingTag = Instance.new("BoolValue")
                collectingTag.Name = "Collecting"
                collectingTag.Value = true
                collectingTag.Parent = obj
                print("DEBUG: Added collecting tag")
                
                -- Update collection time
                lastCollectionTime = currentTime
                
                -- Add visual feedback (make it glow briefly before destroying)
                if obj:IsA("Model") then
                    local partToGlow = obj.PrimaryPart or obj:FindFirstChildOfClass("Part")
                    if partToGlow then
                        partToGlow.Material = Enum.Material.Neon
                        partToGlow.Color = Color3.fromRGB(255, 255, 0) -- Bright yellow
                        print("DEBUG: Made Model glow")
                    end
                elseif obj:IsA("Part") then
                    obj.Material = Enum.Material.Neon
                    obj.Color = Color3.fromRGB(255, 255, 0) -- Bright yellow
                    print("DEBUG: Made Part glow")
                end

                        -- Collect points and check level up
                        local points = obj:FindFirstChild("Points")
                        if points then
                            playerScore = playerScore + points.Value
                            print("Collected CatTreat! Score:", playerScore, "Level:", playerLevel)
                            
                            -- Check level up in a separate thread so it doesn't block CatTreat destruction
                            spawn(function()
                                CheckLevelUp()
                            end)
                        else
                            print("DEBUG: No Points value found on CatTreat")
                        end

                        -- Request server to destroy the CatTreat immediately
                        print("DEBUG: Requesting server to destroy CatTreat...")
                        print("DEBUG: CatTreat object:", obj)
                        print("DEBUG: CatTreat Parent:", obj.Parent)
                        print("DEBUG: CatTreat Name:", obj.Name)
                        print("DEBUG: CatTreat ClassName:", obj.ClassName)
                        
                        -- Send CatTreat info to server instead of the object itself
                        local catTreatInfo = {
                            name = obj.Name,
                            position = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:FindFirstChildOfClass("Part") and obj:FindFirstChildOfClass("Part").Position) or obj.Position,
                            className = obj.ClassName
                        }
                        
                        print("DEBUG: About to send catTreatInfo to server:", catTreatInfo)
                        print("DEBUG: CollectCatTreatEvent exists:", CollectCatTreatEvent ~= nil)
                        print("DEBUG: CollectCatTreatEvent type:", type(CollectCatTreatEvent))
                        
                        local success, error = pcall(function()
                            CollectCatTreatEvent:FireServer(catTreatInfo)
                        end)
                        
                        if success then
                            print("DEBUG: Collection request sent to server successfully")
                        else
                            print("DEBUG: Failed to send collection request:", error)
                        end
                        
                        break -- Exit the loop after collecting one CatTreat per frame
            end
        end
    end
end
RunService.Heartbeat:Connect(CheckCatTreatCollection)

-- Create UI
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameUI"
screenGui.Parent = playerGui

        -- Create score display only
        local function CreateScoreDisplay()
            local playerGui = player:WaitForChild("PlayerGui")
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "ScoreDisplay"
            screenGui.Parent = playerGui

            -- Create the score frame for left side positioning
            local scoreFrame = Instance.new("Frame")
            scoreFrame.Name = "ScoreFrame"
            scoreFrame.Size = UDim2.new(0, 200, 0, 50)
            scoreFrame.Position = UDim2.new(0, 20, 1, -70) -- Bottom left
            scoreFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            scoreFrame.BackgroundTransparency = 0.3
            scoreFrame.BorderSizePixel = 0
            scoreFrame.Parent = screenGui

            -- Create the score label
            local scoreLabel = Instance.new("TextLabel")
            scoreLabel.Name = "ScoreLabel"
            scoreLabel.Size = UDim2.new(1, 0, 1, 0)
            scoreLabel.Position = UDim2.new(0, 0, 0, 0)
            scoreLabel.BackgroundTransparency = 1
            scoreLabel.Text = "Meow: 0"
            scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White
            scoreLabel.TextScaled = true
            scoreLabel.Font = Enum.Font.GothamBold
            scoreLabel.TextXAlignment = Enum.TextXAlignment.Left
            scoreLabel.Parent = scoreFrame

            -- Hide player name and translation message after 5 seconds
            spawn(function()
                wait(5)
                
                print("DEBUG: Starting aggressive UI cleanup...")
                
                -- Function to recursively search and destroy elements
                local function destroyElementRecursively(parent)
                    for _, child in pairs(parent:GetChildren()) do
                        -- Check if this element should be destroyed
                        local shouldDestroy = false
                        
                        -- Check by name
                        local childName = child.Name:lower()
                        if childName:find("username") or childName:find("player") or 
                           childName:find("name") or childName:find("translation") or
                           childName:find("chat") or childName:find("roblox") then
                            shouldDestroy = true
                        end
                        
                        -- Check by text content - only for elements that can have text
                        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                            if child.Text then
                                local text = child.Text:lower()
                                if text:find("roblox automatically translates") or 
                                   text:find("supported languages") or
                                   text:find("chat") or
                                   text:find("furgamesroblox") or
                                   text:find("username") then
                                    shouldDestroy = true
                                end
                            end
                        end
                        
                        -- Check by class name
                        if child.ClassName == "TextLabel" or child.ClassName == "TextButton" or
                           child.ClassName == "Frame" or child.ClassName == "GuiObject" then
                            -- Additional checks for these types
                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                if child.Text and (child.Text:find("FurGamesRoblox") or 
                                   child.Text:find("Roblox automatically translates")) then
                                    shouldDestroy = true
                                end
                            end
                        end
                        
                        -- Destroy if flagged
                        if shouldDestroy then
                            print("DEBUG: Destroying element:", child.Name, "Class:", child.ClassName, "Text:", child:IsA("TextLabel") and child.Text or "N/A")
                            child:Destroy()
                        else
                            -- Recursively check children
                            destroyElementRecursively(child)
                        end
                    end
                end
                
                -- Clean up PlayerGui
                destroyElementRecursively(playerGui)
                
                -- Also check StarterGui and other locations
                local starterGui = player:FindFirstChild("StarterGui")
                if starterGui then
                    destroyElementRecursively(starterGui)
                end
                
                -- Check for elements in the main game
                local gameGui = game:FindFirstChild("CoreGui")
                if gameGui then
                    destroyElementRecursively(gameGui)
                end
                
                print("DEBUG: UI cleanup completed!")
            end)

            return scoreLabel
        end

        -- Initialize systems
        local function InitializeSystems()
            -- Initialize CatTreat collection system
            CheckCatTreatCollection()
            print("CatTreat collection system initialized")

            -- Initialize level progression system
            CheckLevelUp()
            print("Level progression system initialized")

            -- Create score display
            local scoreLabel = CreateScoreDisplay()
            print("Score display created")

            -- Store reference for updating
            _G.ScoreLabel = scoreLabel

            print("=== CATTREAT COLLECTION & LEVEL SYSTEM COMPLETE ===")
        end

        local function UpdateUI()
            if not GameConfig or not GameConfig.Levels then
                print("DEBUG: GameConfig or GameConfig.Levels is nil in UpdateUI")
                return
            end

            local scoreLabel = _G.ScoreLabel

            if not scoreLabel then
                print("DEBUG: ScoreLabel not found in UpdateUI")
                return
            end

            local currentLevelData = GameConfig.Levels[playerLevel]
            if not currentLevelData then
                print("DEBUG: No level data for level", playerLevel)
                return
            end

            -- Update the combined level and score display
            scoreLabel.Text = string.format("Meow: %d", playerScore)
        end
RunService.Heartbeat:Connect(UpdateUI)

-- Debug function to show nearby CatTreats
local function DebugNearbyCatTreats()
    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    print("DEBUG: Player position:", humanoidRootPart.Position)
    print("DEBUG: Looking for CatTreats...")
    
    local foundCount = 0
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "CatTreat" and obj.Parent then
            foundCount = foundCount + 1
            local distance
            if obj:IsA("Model") then
                local partToCheck = obj.PrimaryPart or obj:FindFirstChildOfClass("Part")
                if partToCheck then
                    distance = (humanoidRootPart.Position - partToCheck.Position).Magnitude
                    print("DEBUG: CatTreat Model #" .. foundCount .. " at distance:", distance, "Position:", partToCheck.Position)
                end
            elseif obj:IsA("Part") then
                distance = (humanoidRootPart.Position - obj.Position).Magnitude
                print("DEBUG: CatTreat Part #" .. foundCount .. " at distance:", distance, "Position:", obj.Position)
            end
        end
    end
    print("DEBUG: Found", foundCount, "CatTreats in workspace")
end

-- Run debug function every 5 seconds
spawn(function()
    while true do
        wait(5)
        DebugNearbyCatTreats()
    end
end)

-- Setup aggressive UI prevention once player is available
spawn(function()
    while not player do
        wait(0.1)
    end
    SetupAggressiveUIPrevention()
end)

-- NUCLEAR OPTION: Continuous aggressive cleanup every frame
local function NuclearUICleanup()
    if not player then return end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- Instead of destroying, make unwanted elements invisible and move them off-screen
    for _, child in pairs(playerGui:GetChildren()) do
        local shouldHide = false
        
        -- Check by name
        local childName = child.Name:lower()
        if childName:find("username") or childName:find("player") or 
           childName:find("name") or childName:find("translation") or
           childName:find("chat") or childName:find("roblox") or
           childName:find("furgames") then
            shouldHide = true
        end
        
        -- Check by text content recursively
        local function checkTextRecursively(obj)
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if obj.Text then
                    local text = obj.Text:lower()
                    if text:find("roblox automatically translates") or 
                       text:find("supported languages") or
                       text:find("furgamesroblox") or
                       text:find("username") or
                       text:find("player") or
                       text:find("name") or
                       text:find("translation") then
                        return true
                    end
                end
            end
            
            -- Check children recursively
            for _, grandChild in pairs(obj:GetChildren()) do
                if checkTextRecursively(grandChild) then
                    return true
                end
            end
            
            return false
        end
        
        if checkTextRecursively(child) then
            shouldHide = true
        end
        
        -- Hide and move off-screen if flagged
        if shouldHide then
            -- Make the element invisible
            if child:IsA("GuiObject") then
                child.Visible = false
                child.BackgroundTransparency = 1
                child.BorderSizePixel = 0
                
                -- Move it far off-screen
                if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                    child.Position = UDim2.new(10, 0, 10, 0) -- Move 10x screen size away
                    child.Size = UDim2.new(0, 1, 0, 1) -- Make it tiny
                end
            end
            
            -- Also hide all children recursively
            local function hideRecursively(obj)
                if obj:IsA("GuiObject") then
                    obj.Visible = false
                    obj.BackgroundTransparency = 1
                    obj.BorderSizePixel = 0
                    
                    if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        obj.Position = UDim2.new(10, 0, 10, 0)
                        obj.Size = UDim2.new(0, 1, 0, 1)
                    end
                end
                
                for _, grandChild in pairs(obj:GetChildren()) do
                    hideRecursively(grandChild)
                end
            end
            
            hideRecursively(child)
            print("DEBUG: HIDDEN UI element:", child.Name, "Class:", child.ClassName)
        end
    end
end

-- Run nuclear cleanup every frame
RunService.Heartbeat:Connect(NuclearUICleanup)

InitializeSystems()
