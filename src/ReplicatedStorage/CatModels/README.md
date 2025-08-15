# 🐱 Cat Models Setup Guide

## 📁 How to Add Your CosmoKitten FBX Model

### **Step 1: Import the FBX**
1. Open Roblox Studio
2. In the Explorer, navigate to `ReplicatedStorage > CatModels`
3. Right-click on `CatModels` folder
4. Select "Import 3D Object"
5. Choose your `CosmoKitten.fbx` file

### **Step 2: Name the Model**
- **Important**: The imported model MUST be named exactly `CosmoKitten`
- This name must match what's in `GameConfig.lua`

### **Step 3: Set Primary Part**
1. Select the imported model
2. In the Properties panel, find "PrimaryPart"
3. Click the dropdown and select the main body part of your cat
4. This ensures proper positioning and movement

### **Step 4: Verify Setup**
- The model should appear in `ReplicatedStorage > CatModels > CosmoKitten`
- All parts should be properly scaled and positioned
- The model should have a PrimaryPart set

## 🔧 Technical Details

- **Scale**: Models are automatically scaled to 3% of original size
- **Positioning**: Cats spawn 5 studs above the spawn point
- **Movement**: Uses standard Roblox humanoid movement system
- **Respawn**: Automatically reapplies cat avatar when player respawns

## 🚨 Troubleshooting

- **"Cat model not found"**: Check that the model name matches exactly
- **Model too big/small**: The system auto-scales, but you can adjust `CAT_MODEL_SCALE` in `CatAvatarManager.lua`
- **Movement issues**: Ensure PrimaryPart is set correctly
- **Not appearing**: Check that the model is in the correct folder path

## 📋 Next Steps

Once CosmoKitten is working:
1. Add more cat models for higher levels
2. Implement level-based avatar switching
3. Add special abilities for each cat type
