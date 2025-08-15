# CosmoCat 🐱🚀

A Roblox game where you play as a cat in space! Collect CatTreats, level up, and compete with other players in this cosmic adventure.

## 🎮 Game Concept

- **10 Levels**: Each level features a different custom cat character
- **Space Theme**: Explore a cosmic environment with shooting star collectibles
- **Multiplayer**: Compete with other players in PvP encounters
- **Progression**: Level up by collecting points and defeating opponents

## 🛠️ Development Setup

### Prerequisites
- [Roblox Studio](https://www.roblox.com/create)
- [Rojo](https://rojo.space/) - Roblox development tool
- [Cursor](https://cursor.sh/) - AI-powered code editor

### Installation
1. Clone this repository
2. Install Rojo: `aftman add rojo-rbx/rojo@7.5.1`
3. Start Rojo server: `aftman run rojo serve default.project.json`
4. Open Roblox Studio and connect to Rojo

### Project Structure
```
src/
├── ServerScriptService/     # Server-side scripts
├── StarterPlayer/           # Client-side scripts
├── Workspace/               # Game world objects
├── Lighting/                # Environment lighting
└── StarterGui/              # User interface
```

## 🚀 Current Features

### Phase 1: Basic Setup ✅
- [x] Humanoid character movement
- [x] Third-person camera
- [x] Standard controls
- [x] Special abilities per character
- [x] Level 1 starting point
- [x] Simple space environment

### Phase 2: Collectibles & Scoring ✅
- [x] CatTreat spawning system
- [x] Point collection
- [x] Score display ("Meow: X")
- [x] Shooting star falling animation
- [x] Level progression system (10 levels)
- [x] UI system with notifications

### Phase 3: Cat Avatar System 🐱
- [x] CosmoKitten avatar replacement
- [x] Automatic avatar application on join/respawn
- [x] Custom FBX model integration
- [x] Proper scaling and positioning
- [x] Humanoid movement system integration

## 🎯 Next Steps

- [ ] Level-based avatar switching (different cats per level)
- [ ] Multiplayer PvP mechanics
- [ ] Special abilities for each cat type
- [ ] Enhanced space environment
- [ ] Sound effects and music

## 🎨 Game Mechanics

### Scoring System
- **CatTreat**: 1 point
- **Other collectibles**: Various point values
- **PvP**: Winner gains loser's points + level bonus

### Level Progression
- Level 1: 0 points required
- Level 2: 10 points required
- Level 3: 25 points required
- And so on...

### Player Elimination
- Players can't be eliminated at Level 1 with 0 points
- Losers respawn at Level 1 with 0 points
- Winners gain points and potentially level up

## 🔧 Technical Details

- **Language**: Lua
- **Architecture**: Client-Server model
- **Build Tool**: Rojo
- **Version Control**: Git

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Happy coding! 🐱✨**
