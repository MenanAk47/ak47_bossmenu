local isMenuOpen = false

function OpenBossMenu(groupName, groupType)
    groupType = groupType or 'job'
    local initialData = Lib47.Callback.Await('ak47_bossmenu:server:getInitialData', nil, groupName, groupType)

    if not initialData then
        Lib47.Notify(_U('no_permission'), 'error')
        return
    end

    isMenuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openUI',
        data = {
            bossData = initialData,
            locales = Locales[Config.Locale or 'en'] or Locales['en'] or {},
        }
    })
end

RegisterNUICallback('close', function(_, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
    local success, message = Lib47.Callback.Await('ak47_bossmenu:server:deposit', nil, data.groupName, data.amount)
    local freshData = Lib47.Callback.Await('ak47_bossmenu:server:getInitialData', nil, data.groupName, data.groupType)
    cb({
        success = success,
        message = message,
        balance = freshData and freshData.balance or nil,
    })
end)

RegisterNUICallback('withdraw', function(data, cb)
    local success, message = Lib47.Callback.Await('ak47_bossmenu:server:withdraw', nil, data.groupName, data.amount)
    local freshData = Lib47.Callback.Await('ak47_bossmenu:server:getInitialData', nil, data.groupName, data.groupType)
    cb({
        success = success,
        message = message,
        balance = freshData and freshData.balance or nil,
    })
end)

RegisterNUICallback('updateGrade', function(data, cb)
    local success, message, employees = Lib47.Callback.Await('ak47_bossmenu:server:updateGrade', nil, data.cid, data.groupName, data.groupType, data.newGrade)
    cb({ success = success, message = message, employees = employees })
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    local success, message, employees = Lib47.Callback.Await('ak47_bossmenu:server:fireEmployee', nil, data.cid, data.groupName, data.groupType)
    cb({ success = success, message = message, employees = employees })
end)

RegisterNUICallback('hireEmployee', function(data, cb)
    local success, message, employees = Lib47.Callback.Await('ak47_bossmenu:server:hireEmployee', nil, data.targetSource, data.groupName, data.groupType)
    cb({ success = success, message = message, employees = employees })
end)

RegisterNUICallback('updateSalary', function(data, cb)
    local success, message = Lib47.Callback.Await('ak47_bossmenu:server:updateSalary', nil, data.groupName, data.grade, data.salary)
    cb({ success = success, message = message })
end)

RegisterNUICallback('getNearbyPlayers', function(_, cb)
    local players = Lib47.Callback.Await('ak47_bossmenu:server:getNearbyPlayers', nil)
    cb(players or {})
end)

RegisterNUICallback('openStash', function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    SendNUIMessage({ action = 'closeUI' })
    cb('ok')
    CreateThread(function()
        Wait(100)
        local stashId = 'boss_' .. tostring(data.groupName)
        local stashLabel = (tostring(data.groupName):gsub("^%l", string.upper)) .. ' Storage'
        local weight = (Config.Stash and Config.Stash.weight) or 1000
        local slots = (Config.Stash and Config.Stash.slots) or 100
        Lib47.OpenStash(stashId, stashLabel, weight, slots)
    end)
end)

RegisterNUICallback('openWardrobe', function(_, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    SendNUIMessage({ action = 'closeUI' })
    cb('ok')
    CreateThread(function()
        Wait(100)
        Lib47.OpenWardrobe()
    end)
end)

RegisterNetEvent('ak47_bossmenu:client:openMenu', function(groupName, groupType)
    OpenBossMenu(groupName, groupType)
end)

RegisterCommand('bossmenu', function()
    local job = Lib47.GetJob()
    if job and job.name then
        OpenBossMenu(job.name, 'job')
    end
end, false)
