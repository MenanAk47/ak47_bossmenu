exports('OpenBossMenu', function(groupName, groupType)
    OpenBossMenu(groupName, groupType)
end)

exports('CloseBossMenu', function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
end)
