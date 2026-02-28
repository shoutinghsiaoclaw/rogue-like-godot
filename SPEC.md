# Rogue-like Game - SPEC.md

## 1. Project Overview
- **Project Name**: Simple Rogue-like
- **Engine**: Godot 4.x
- **Genre**: Top-down rogue-like dungeon crawler
- **Core Concept**: 極簡 rogue-like，體驗核心樂趣

## 2. Minimal Elements

### Player
- 簡單方形角色
- 移動：WASD 或 方向鍵
- 攻擊：靠近敵人自動攻擊 / 點擊攻擊

### Enemies
- 1-2 種敵人類型
- 簡單 AI：追蹤玩家

### Dungeon
- 隨機生成的房間
- 樓層系統（樓下樓）
- 道具：藥水、武器

### Combat
- 回合制戰鬥
- 血量、攻擊力、防禦
- 敵人死亡掉落道具

## 3. Win/Lose Condition
- **Lose**: 血量歸零
- **Win**: 通過 5 層樓

## 4. Art Style
- 簡單像素風格（Godot 預設或簡單色塊）
- 不需要複雜美術資源

## 5. Scope
- 最少代碼、最少資源
- 1-2 週開完發原型
