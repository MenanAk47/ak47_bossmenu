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
    return RegisteredSocieties[name] or {
        name = name,
        label = name,
        account = 'society_' .. name,
    }
end

AddEventHandler('esx_society:registerSociety', RegisterSociety)
exports('registerSociety', RegisterSociety)
exports('GetSociety', GetSociety)
exports('getSociety', GetSociety)

AddEventHandler('esx_society:getSociety', function(name, cb)
    if cb then cb(GetSociety(name)) end
end)
