# Next Flashbang | The most optimized flashbang system.

Next Flashbang is a lightweight, high-performance flashbang system designed for FiveM. Built with optimization and reliability in mind, it ensures immersive tactical gameplay while minimizing performance impact across clients and the server.

---

## 🚀 Features

- 🔥 Ultra-optimized client-side flashbang detection
- 🎯 Proximity-based stun scaling (closer = longer effect)
- ⚡ Full compatibility with `ox_inventory` (Other frameworks will require some scripting knowledge to implement)
- 🔊 Optional sound and screen effects
- 🎮 Automatic disarming on flash (configurable)
- 🔄 Server sync with networked entity tracking
- 🔒 Safe and clean handling of game-native throwables

---

## 🧱 Requirements

- **[next-flashbang-item](https://github.com/nextextend/next-flashbang-item)**
- **ox_inventory** (Highly recommended)

In both cases, you need to add the item yourself. Here's how to do this.

---

## 🔧 Integration

Download and install both resources ([next-flashbang-item](https://github.com/nextextend/next-flashbang-item) & next-flashbang). Add these resources to your resources.cfg.

### 📦 ox_inventory Setup

Add the flashbang as a **throwable weapon** in your Ox Inventory weapon configuration (usually found in `data/weapons.lua` or your own custom weapons file):

```lua
['WEAPON_FLASHBANG'] = {
    label = 'K-J4 Flashbang',
    category = 'weapons',
    weight = 600,
    throwable = true,
    anim = { 'melee@holster', 'unholster', 200, 'melee@holster', 'holster', 600 },
}
```

After you have added the flashbang as a weapon, you can give it to players using commands or shops. All that's left to do is to have fun with the flashbang!

---

### 📦 ESX Setup

Standalone ESX integration (without ox_inventory) is unsupported at this moment. If you don't use ox but still want to use this resource, you may alter this resource in order to achieve this. Use the export below to let the script know that a player is holding a flasbang, and can throw it any minute.

```lua
exports['next-flashbang']:onFlashbang()
```
