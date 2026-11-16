# AK47 Boss Management Menu

[![Discord](https://img.shields.io/badge/Discord-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/menanak47)
[![Support](https://img.shields.io/badge/Support-Community-blue?style=flat-square)](https://discord.gg/menanak47)

High-performance, modern multi-framework Boss & Gang Management System for FiveM powered by `ak47_lib` and React 18 + TSX + Tailwind CSS, featuring full 100% drop-in compatibility for **ESX Society**, **QBCore Management**, and **Qbox Management**.
<p align="center">
    <img width="400" alt="bossmenu 1" src="https://github.com/user-attachments/assets/7acc9e78-76de-4739-9907-485ea3f26e86" />
    <img width="400" alt="bossmenu 2" src="https://github.com/user-attachments/assets/142f83f1-721c-499d-ab00-db85dd7f8865" />
</p>
<p align="center">
    <img width="400" alt="bossmenu 3" src="https://github.com/user-attachments/assets/0641f009-abad-4ef3-8e64-587f9c98bfc3" />
    <img width="400" alt="bossmenu 4" src="https://github.com/user-attachments/assets/e7a57c08-be66-4e41-a7f0-d8cdbe2d9f7e" />
</p>

## ⚡ Features

- **100% Multi-Framework Support:** Native compatibility across ESX Legacy, QBCore, and Qbox powered by `ak47_lib`.
- **Jobs & Gangs Support:** Seamlessly handles both legal employment organizations and illegal gangs with dedicated grade hierarchies.
- **Modern NUI Interface:** Responsive, dark glassmorphic HUD built with React 18, TypeScript, Tailwind CSS, Lucide icons, and tactile procedural sound synthesis.
- **Financial Treasury Management:** Direct society banking integration routing to `esx_addonaccount`, `qb-management`, `ak47_banking`, `qb-banking`, `ars_banking`, `okokBanking`, or `Renewed-Banking`.
- **Employee Directory:** Searchable online/offline staff list with live presence badges (`🟢` / `❌`), rank indicators, and rank promotion/demotion.
- **Anti-Exploit Rank Protection:** Server-side hierarchy enforcement preventing bosses from promoting anyone to or above their own rank, firing higher ranks, or firing themselves.
- **Nearby Recruitment:** 1-click recruitment of players standing within 10 meters.
- **Dynamic Salary Adjustment:** Real-time salary editing for database-backed ranks (ESX) with max salary bounds.
- **Integrated Stash & Wardrobe:** One-click shortcuts to launch organization stashes and wardrobes via `Lib47.OpenStash()` and `Lib47.OpenWardrobe()`.
- **Target & 2D TextUI Support:** Built-in support for `ox_target`, `ak47_target`, `qb-target`, and `qtarget`, with a smooth 2D TextUI fallback.
- **Discord Webhook Auditing:** Rich embedded logs for deposits, withdrawals, promotions, dismissals, and recruitment.
- **100% Drop-In Replacement:** Fully replaces `esx_society`, `qb-management`, `qbx_management`, and `qb-bossmenu` without breaking existing jobs or third-party scripts.

---

## 📦 Dependencies & Installation

1. Ensure **`ak47_lib`** and **`oxmysql`** are installed and started before this resource.
2. Place `ak47_bossmenu` into your server's `resources` directory.
3. Add to your `server.cfg`:
```cfg
ensure oxmysql
ensure ak47_lib
ensure ak47_bossmenu
```

> [!NOTE]
> **Drop-In Replacement**: If you are using `ak47_bossmenu`, you can safely remove `esx_society`, `qb-management`, and `qbx_management`. `ak47_bossmenu` registers `provides` in its manifest and automatically handles all legacy events, callbacks, and exports.

---

## 🔑 Configuration & Permissions

Configure menu locations, boss ranks, and interaction modes in `config.lua`:

```lua
Config = {}
Config.Locale = 'en'
Config.UseTarget = true     -- Set to true to use ox_target / qb-target; false for 2D TextUI prompt
Config.MaxSalary = 5000     -- Maximum allowable salary edit limit (ESX)

-- ESX Boss Grade Identifiers (QBCore and Qbox use job.isboss / gang.isboss natively)
Config.BossGrades = {
    ['boss'] = true,
    ['chief'] = true,
    ['commander'] = true,
}

-- Quick Action Features
Config.EnableStash = true
Config.EnableWardrobe = true
Config.EnableMoneyWash = true

Config.Stash = {
    weight = 1000, -- Maximum stash capacity in KG
    slots = 100,   -- Maximum stash slots
}

Config.BlackMoney = {
    esx = {
        IsAccount = true,
        AccountName = 'black_money',
        --ItemName = 'markedbills',
        --HasMetaData = true,
        --MetaKey = 'worth',
    },
    qb = {
        --IsAccount = true,
        --AccountName = 'black_money',
        ItemName = 'markedbills',
        HasMetaData = true,
        MetaKey = 'worth',
    },
    qbx = {
        --IsAccount = true,
        --AccountName = 'black_money',
        ItemName = 'markedbills',
        HasMetaData = true,
        MetaKey = 'worth',
    }
}

-- Boss Menu Locations
Config.Menus = {
    ['police'] = {
        label = 'Police Management',
        type = 'job', -- 'job' or 'gang'
        coords = vector3(460.6, -986.3, 30.7),
        size = vector3(1.5, 1.5, 2.0),
        rotation = 0.0,
    },
    ['ambulance'] = {
        label = 'EMS Management',
        type = 'job',
        coords = vector3(311.2, -599.4, 43.3),
        size = vector3(1.5, 1.5, 2.0),
        rotation = 0.0,
    },
    ['ballas'] = {
        label = 'Ballas Management',
        type = 'gang',
        coords = vector3(104.9, -1981.8, 20.9),
        size = vector3(1.5, 1.5, 2.0),
        rotation = 0.0,
    },
}
```

---

## 🎮 Chat Commands & Controls

| Trigger | Description |
| :--- | :--- |
| `/bossmenu` | Opens the Boss Management menu for the player's active job (if boss). |
| **Target Zone (Alt / Eye)** | Left-click target interaction at configured boss desk coordinates. |
| **TextUI Prompt ([E])** | Keyboard interaction prompt displayed when target is disabled. |
| **[ESC]** | Closes the open NUI Boss Management menu. |

---

## 🛠️ API & Exports Reference

### Server-Side Exports

```lua
-- Query society account balance
local balance = exports['ak47_bossmenu']:GetSocietyBalance('police')

-- Add society funds
exports['ak47_bossmenu']:AddSocietyMoney('police', 5000, 'Civil asset forfeiture')

-- Remove society funds
exports['ak47_bossmenu']:RemoveSocietyMoney('police', 2500, 'Equipment purchase')

-- Get formatted employee list for a job or gang
local employees = exports['ak47_bossmenu']:GetEmployees('police', 'job')

-- Verify whether a player has boss access
local isBoss = exports['ak47_bossmenu']:IsBoss(source, 'police', 'job')
```

### Client-Side Exports

```lua
-- Open boss menu programmatically
exports['ak47_bossmenu']:OpenBossMenu('police', 'job')

-- Close boss menu programmatically
exports['ak47_bossmenu']:CloseBossMenu()
```

---

## 🔄 Drop-In Compatibility

`ak47_bossmenu` provides native drop-in shims for existing resources. Third-party scripts calling the following events and exports will work without any changes:

* **ESX Society**:
  * `exports['esx_society']:getSociety(name)` / `exports['esx_society']:GetSociety(name)`
  * `exports['esx_society']:registerSociety(...)`
  * `AddEventHandler('esx_society:registerSociety', ...)`
  * `TriggerEvent('esx_society:getSociety', name, cb)`
  * `TriggerClientEvent('esx_society:openBossMenu', ...)`
* **QBCore Management**:
  * `exports['qb-management']:GetAccount(job)`
  * `exports['qb-management']:AddMoney(job, amount, reason)`
  * `exports['qb-management']:RemoveMoney(job, amount, reason)`
  * `QBCore.Functions.CreateCallback('qb-bossmenu:server:GetEmployees')`
  * `QBCore.Functions.CreateCallback('qb-bossmenu:getplayers')`
  * `QBCore.Functions.CreateCallback('qb-gangmenu:server:GetEmployees')`
  * `RegisterNetEvent('qb-bossmenu:server:HireEmployee')`
  * `RegisterNetEvent('qb-bossmenu:server:FireEmployee')`
  * `RegisterNetEvent('qb-bossmenu:server:GradeUpdate')`
  * `TriggerClientEvent('qb-bossmenu:client:OpenMenu')`
  * `TriggerClientEvent('qb-gangmenu:client:OpenMenu')`
* **Qbox Management**:
  * `ox_lib` callback `qbx_management:server:getEmployees`

---

## 🔔 Discord Webhook Setup

Configure `webhooks.lua`:
```lua
Webhooks = {
    enabled = true,
    url = 'https://discord.com/api/webhooks/...',
    botName = 'AK47 Boss Management',
    avatar = 'https://i.imgur.com/8Q9j9sZ.png',
}
```

---

## 🖥️ Building the Web UI

The UI is built with Vite + React 18 + TypeScript. If you modify any files in `ak47_bossmenu_web/src`:

```bash
cd ak47_bossmenu_web
npm install
npm run build
```

Production builds will automatically compile directly into `ak47_bossmenu/web/`.

---

## 📄 License & Credits

- Developed by **MenanAk47**
- **Support & Discord:** [discord.gg/menanak47](https://discord.gg/menanak47)
