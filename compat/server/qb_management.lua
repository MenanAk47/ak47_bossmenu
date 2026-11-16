-- QBCore Management Drop-in Interoperability Layer

exports('GetAccount', function(job)
    return Society.GetBalance(job)
end)

exports('GetGangAccount', function(gang)
    return Society.GetBalance(gang)
end)

exports('AddMoney', function(job, amount, reason)
    return Lib47.AddSocietyMoney(job, amount, reason or 'QB Management Add')
end)

exports('RemoveMoney', function(job, amount, reason)
    return Lib47.RemoveSocietyMoney(job, amount, reason or 'QB Management Remove')
end)

-- Legacy QB Bossmenu Server Events & Callbacks
if Lib47.Framework == 'qb' or Lib47.Framework == 'qbx' then
    local QBCore = exports['qb-core']:GetCoreObject()

    if QBCore and QBCore.Functions then
        QBCore.Functions.CreateCallback('qb-bossmenu:server:GetEmployees', function(source, cb, jobname)
            cb(Employees.GetList(jobname, 'job'))
        end)

        QBCore.Functions.CreateCallback('qb-bossmenu:getplayers', function(source, cb)
            local players = {}
            local srcCoords = GetEntityCoords(GetPlayerPed(source))
            for _, v in pairs(QBCore.Functions.GetPlayers()) do
                if v ~= source then
                    local targetPed = GetPlayerPed(v)
                    if #(srcCoords - GetEntityCoords(targetPed)) < 10.0 then
                        local targetPlayer = QBCore.Functions.GetPlayer(v)
                        if targetPlayer then
                            table.insert(players, {
                                id = v,
                                name = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
                                citizenid = targetPlayer.PlayerData.citizenid,
                                sourceplayer = v,
                            })
                        end
                    end
                end
            end
            cb(players)
        end)

        QBCore.Functions.CreateCallback('qb-gangmenu:server:GetEmployees', function(source, cb, gangname)
            cb(Employees.GetList(gangname, 'gang'))
        end)

        QBCore.Functions.CreateCallback('qb-gangmenu:getplayers', function(source, cb)
            local players = {}
            local srcCoords = GetEntityCoords(GetPlayerPed(source))
            for _, v in pairs(QBCore.Functions.GetPlayers()) do
                if v ~= source then
                    local targetPed = GetPlayerPed(v)
                    if #(srcCoords - GetEntityCoords(targetPed)) < 10.0 then
                        local targetPlayer = QBCore.Functions.GetPlayer(v)
                        if targetPlayer then
                            table.insert(players, {
                                id = v,
                                name = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
                                citizenid = targetPlayer.PlayerData.citizenid,
                                sourceplayer = v,
                            })
                        end
                    end
                end
            end
            cb(players)
        end)
    end

    RegisterNetEvent('qb-bossmenu:server:HireEmployee', function(recruit)
        local src = source
        local job = Lib47.GetJob(src)
        if job and job.name then
            Employees.Hire(src, recruit, job.name, 'job')
        end
    end)

    RegisterNetEvent('qb-bossmenu:server:FireEmployee', function(targetCid)
        local src = source
        local job = Lib47.GetJob(src)
        if job and job.name then
            Employees.Fire(src, targetCid, job.name, 'job')
        end
    end)

    RegisterNetEvent('qb-bossmenu:server:GradeUpdate', function(data)
        local src = source
        local job = Lib47.GetJob(src)
        if job and job.name and data and data.cid and data.grade then
            Employees.UpdateGrade(src, data.cid, job.name, 'job', data.grade)
        end
    end)

    RegisterNetEvent('qb-gangmenu:server:HireMember', function(recruit)
        local src = source
        local gang = Lib47.GetGang(src)
        if gang and gang.name then
            Employees.Hire(src, recruit, gang.name, 'gang')
        end
    end)

    RegisterNetEvent('qb-gangmenu:server:FireMember', function(targetCid)
        local src = source
        local gang = Lib47.GetGang(src)
        if gang and gang.name then
            Employees.Fire(src, targetCid, gang.name, 'gang')
        end
    end)

    RegisterNetEvent('qb-gangmenu:server:GradeUpdate', function(data)
        local src = source
        local gang = Lib47.GetGang(src)
        if gang and gang.name and data and data.cid and data.grade then
            Employees.UpdateGrade(src, data.cid, gang.name, 'gang', data.grade)
        end
    end)
end
