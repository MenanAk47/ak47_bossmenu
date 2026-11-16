-- ESX Society Drop-in Interoperability Layer
local RegisteredSocieties = {}

local function RegisterSociety(name, label, account, datastore, inventory, data)
    RegisteredSocieties[name] = {
        name = name,
        label = label or name,
        account = account or ('society_' .. name),
        datastore = datastore,
        inventory = inventory,
        data = data or {},
    }
end

local function GetSociety(name)
    local cleanName = name:gsub('^society_', '')
    return RegisteredSocieties[cleanName] or RegisteredSocieties[name] or {
        name = cleanName,
        label = cleanName,
        account = 'society_' .. cleanName,
    }
end

AddEventHandler('esx_society:registerSociety', RegisterSociety)
exports('registerSociety', RegisterSociety)
exports('GetSociety', GetSociety)
exports('getSociety', GetSociety)

exports('GetSocieties', function()
    return RegisteredSocieties
end)
exports('getSocieties', function()
    return RegisteredSocieties
end)

AddEventHandler('esx_society:getSociety', function(name, cb)
    if cb then cb(GetSociety(name)) end
end)

AddEventHandler('esx_society:getSocieties', function(cb)
    if cb then cb(RegisteredSocieties) end
end)

RegisterNetEvent('esx_society:depositMoney', function(societyName, amount)
    local src = source
    local groupName = tostring(societyName):gsub('^society_', '')
    Society.Deposit(src, groupName, amount)
end)

RegisterNetEvent('esx_society:withdrawMoney', function(societyName, amount)
    local src = source
    local groupName = tostring(societyName):gsub('^society_', '')
    Society.Withdraw(src, groupName, amount)
end)
