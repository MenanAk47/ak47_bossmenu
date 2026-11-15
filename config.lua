Config = Config or {}

Config.Locale = 'en'
Config.UseTarget = true -- Use ox_target / qb-target via ak47_lib

-- Maximum allowable employee salary when adjusted by boss (ESX)
Config.MaxSalary = 5000

-- ESX Boss grade identifier fallback
Config.BossGrades = {
    ['boss'] = true,
    ['chief'] = true,
    ['commander'] = true,
}

-- Quick Action Features
Config.EnableStash = true
Config.EnableWardrobe = true
Config.Stash = {
    weight = 1000, -- Maximum stash capacity in KG
    slots = 100,   -- Maximum stash slots
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
    ['mechanic'] = {
        label = 'Mechanic Management',
        type = 'job',
        coords = vector3(-205.5, -1331.5, 34.9),
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
