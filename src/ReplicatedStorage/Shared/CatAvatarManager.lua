local CatAvatarManager = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Function to apply cat appearance
local function ApplyCatAppearance(player, level)
    print("DEBUG: Applying cat appearance to", player.Name, "at level", level)
    
    -- Try to change the character's appearance to look more cat-like
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            -- Change the display name
            humanoid.DisplayName = "CosmoKitten"
            
            -- Change the character parts to look more cat-like
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    -- Make it look more cat-like
                    part.Color = Color3.fromRGB(255, 165, 0) -- Orange
                    part.Material = Enum.Material.Neon
                end
            end
            
            print("DEBUG: Applied CosmoKitten appearance to", player.Name)
        end
    end
end

-- Function to handle player joining
local function OnPlayerAdded(player)
    print("DEBUG: Player joined:", player.Name)
    
    -- Connect to character spawning
    player.CharacterAdded:Connect(function(character)
        print("DEBUG: Character spawned for", player.Name, "- applying cat appearance")
        wait(0.5) -- Small wait for character to load
        ApplyCatAppearance(player, 1) -- Start at Level 1
    end)
    
    -- If character already exists, apply immediately
    if player.Character then
        print("DEBUG: Character already exists for", player.Name, "- applying cat appearance")
        wait(0.5)
        ApplyCatAppearance(player, 1)
    end
end

-- Function to update avatar when player levels up (called from client)
function CatAvatarManager.UpdatePlayerAvatar(player, newLevel)
    print("DEBUG: Updating avatar for", player.Name, "to level", newLevel)
    ApplyCatAppearance(player, newLevel)
end

-- Initialize the avatar system
function CatAvatarManager.Initialize()
    print("DEBUG: Initializing Cat Avatar System...")
    
    -- Connect to existing players
    for _, player in pairs(Players:GetPlayers()) do
        OnPlayerAdded(player)
    end
    
    -- Connect to new players
    Players.PlayerAdded:Connect(OnPlayerAdded)
    
    print("DEBUG: Cat Avatar System initialized!")
end

return CatAvatarManager
