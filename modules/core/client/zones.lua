CreateThread(function()
    local nonTargetMenus = {}

    for groupName, data in pairs(Config.Menus) do
        local zoneName = 'ak47_bossmenu_' .. groupName

        if Config.UseTarget and Lib47.Target and Lib47.Target.AddBoxZone then
            Lib47.Target.AddBoxZone(zoneName, data.coords, data.size.x, data.size.y, {
                name = zoneName,
                heading = data.rotation or 0.0,
                minZ = data.coords.z - 1.0,
                maxZ = data.coords.z + 1.5,
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-briefcase',
                        label = data.label,
                        action = function()
                            OpenBossMenu(groupName, data.type)
                        end,
                    },
                },
                distance = 2.0,
            })
        else
            table.insert(nonTargetMenus, { groupName = groupName, data = data })
        end
    end

    if #nonTargetMenus > 0 then
        local activeMenu = nil
        while true do
            local sleep = 1500
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local closest = nil
            local closestDist = 999.0

            for _, item in ipairs(nonTargetMenus) do
                local dist = #(playerCoords - item.data.coords)
                if dist < 5.0 and dist < closestDist then
                    closestDist = dist
                    closest = item
                end
            end

            if closest then
                sleep = 0
                if closestDist < 1.8 then
                    if activeMenu ~= closest.groupName then
                        activeMenu = closest.groupName
                        Lib47.ShowTextUi({
                            position = 'center-left',
                            scale = 0.8,
                            options = {
                                {
                                    key = 38,
                                    keyName = 'E',
                                    label = closest.data.label,
                                }
                            }
                        })
                    end
                    if IsControlJustReleased(0, 38) then -- E key
                        OpenBossMenu(closest.groupName, closest.data.type)
                    end
                else
                    if activeMenu then
                        activeMenu = nil
                        Lib47.HideTextUi()
                    end
                end
            elseif activeMenu then
                activeMenu = nil
                Lib47.HideTextUi()
            end

            Wait(sleep)
        end
    end
end)
