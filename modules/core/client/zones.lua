CreateThread(function()
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
            -- Distance prompt thread fallback
            CreateThread(function()
                local inZone = false
                while true do
                    local sleep = 1500
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local dist = #(playerCoords - data.coords)

                    if dist < 5.0 then
                        sleep = 0
                        if dist < 1.8 then
                            if not inZone then
                                inZone = true
                                Lib47.ShowTextUi({
                                    position = 'center-left',
                                    scale = 0.8,
                                    options = {
                                        {
                                            key = 38,
                                            keyName = 'E',
                                            label = data.label,
                                        }
                                    }
                                })
                            end
                            if IsControlJustReleased(0, 38) then -- E key
                                OpenBossMenu(groupName, data.type)
                            end
                        else
                            if inZone then
                                inZone = false
                                Lib47.HideTextUi()
                            end
                        end
                    elseif inZone then
                        inZone = false
                        Lib47.HideTextUi()
                    end

                    Wait(sleep)
                end
            end)
        end
    end
end)
