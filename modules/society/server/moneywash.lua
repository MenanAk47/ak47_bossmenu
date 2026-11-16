MoneyWash = {}

local function getBlackMoneyConfig()
    local fw = Lib47.Framework
    if Config.BlackMoney and Config.BlackMoney[fw] then
        return Config.BlackMoney[fw]
    end
    if fw == 'esx' then
        return { IsAccount = true, AccountName = 'black_money' }
    else
        return { ItemName = 'markedbills', HasMetaData = true, MetaKey = 'worth' }
    end
end

function MoneyWash.GetPlayerBlackMoney(source)
    local cfg = getBlackMoneyConfig()
    if cfg.IsAccount then
        return Lib47.GetMoney(source, cfg.AccountName or 'black_money') or 0
    else
        local itemName = cfg.ItemName or 'markedbills'
        local totalWorth = 0
        local inv = Lib47.GetInventoryItems and Lib47.GetInventoryItems(source)
        if not inv and (Lib47.Framework == 'qb' or Lib47.Framework == 'qbx') then
            local player = Lib47.GetPlayer(source)
            inv = player and player.PlayerData and player.PlayerData.items
        end

        for _, item in pairs(inv or {}) do
            if item and item.name == itemName then
                if cfg.HasMetaData then
                    local meta = item.info or item.metadata
                    local worth = meta and meta[cfg.MetaKey or 'worth']
                    if worth and tonumber(worth) then
                        totalWorth = totalWorth + tonumber(worth)
                    else
                        totalWorth = totalWorth + (tonumber(item.amount or item.count) or 0)
                    end
                else
                    totalWorth = totalWorth + (tonumber(item.amount or item.count) or 0)
                end
            end
        end
        return totalWorth
    end
end

function MoneyWash.RemoveBlackMoney(source, amount)
    amount = tonumber(amount)
    if not amount or amount <= 0 then return false end

    local cfg = getBlackMoneyConfig()
    if cfg.IsAccount then
        local current = Lib47.GetMoney(source, cfg.AccountName or 'black_money') or 0
        if current < amount then return false end
        return Lib47.RemoveMoney(source, cfg.AccountName or 'black_money', amount)
    else
        local itemName = cfg.ItemName or 'markedbills'
        local current = MoneyWash.GetPlayerBlackMoney(source)
        if current < amount then return false end

        local remaining = amount
        local inv = Lib47.GetInventoryItems and Lib47.GetInventoryItems(source)
        if not inv and (Lib47.Framework == 'qb' or Lib47.Framework == 'qbx') then
            local player = Lib47.GetPlayer(source)
            inv = player and player.PlayerData and player.PlayerData.items
        end

        for slot, item in pairs(inv or {}) do
            if remaining <= 0 then break end
            if item and item.name == itemName then
                local itemSlot = item.slot or slot
                if cfg.HasMetaData then
                    local meta = item.info or item.metadata or {}
                    local worth = tonumber(meta[cfg.MetaKey or 'worth']) or 0
                    if worth > 0 then
                        if worth <= remaining then
                            remaining = remaining - worth
                            Lib47.RemoveItem(source, itemName, 1, itemSlot)
                        else
                            local newWorth = worth - remaining
                            remaining = 0
                            meta[cfg.MetaKey or 'worth'] = newWorth
                            local player = Lib47.GetPlayer(source)
                            if player and player.Functions and player.Functions.SetInventory then
                                player.PlayerData.items[itemSlot].info = meta
                                player.Functions.SetInventory(player.PlayerData.items)
                            elseif exports.ox_inventory and exports.ox_inventory.SetMetadata then
                                exports.ox_inventory:SetMetadata(source, itemSlot, meta)
                            end
                        end
                    else
                        local count = tonumber(item.amount or item.count) or 0
                        local toRemove = math.min(count, remaining)
                        remaining = remaining - toRemove
                        Lib47.RemoveItem(source, itemName, toRemove, itemSlot)
                    end
                else
                    local count = tonumber(item.amount or item.count) or 0
                    local toRemove = math.min(count, remaining)
                    remaining = remaining - toRemove
                    Lib47.RemoveItem(source, itemName, toRemove, itemSlot)
                end
            end
        end

        return remaining <= 0
    end
end

function MoneyWash.Wash(source, groupName, amount)
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false, _U('invalid_amount')
    end

    if not Config.EnableMoneyWash then
        return false, 'Money wash is disabled in configuration.'
    end

    if not Permissions.IsBoss(source, groupName, 'job') and not Permissions.IsBoss(source, groupName, 'gang') then
        return false, _U('no_permission')
    end

    local blackBalance = MoneyWash.GetPlayerBlackMoney(source)
    if blackBalance < amount then
        return false, 'You do not have enough dirty money.'
    end

    if not MoneyWash.RemoveBlackMoney(source, amount) then
        return false, 'Failed to process dirty money.'
    end

    Lib47.AddSocietyMoney(groupName, amount, 'Money Laundering')
    SendDiscordLog('Money Laundered', string.format('%s washed $%s of dirty funds into %s society account', Lib47.GetCharacterName(source), amount, groupName), 15844367)

    return true, string.format('Successfully washed $%s into society treasury.', amount), Society.GetBalance(groupName)
end

-- ESX Society compatibility event
RegisterNetEvent('esx_society:washMoney', function(societyName, amount)
    local src = source
    local groupName = tostring(societyName):gsub('^society_', '')
    MoneyWash.Wash(src, groupName, amount)
end)
